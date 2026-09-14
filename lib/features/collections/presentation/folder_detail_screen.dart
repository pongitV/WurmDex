import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/card_view_mode_provider.dart';
import '../../../../core/providers/grid_composition_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_sorting_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/folder_icon_helper.dart';
import '../../../../core/utils/marketplace_url_helper.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/app_action_fab.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_filter_modal.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../../core/widgets/app_screen_title.dart';
import '../../../../core/widgets/app_search_dialog.dart';
import '../../../../core/widgets/app_sort_button.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../../../core/widgets/card_grid_skeleton.dart';
import '../../../../core/widgets/card_shimmer_glow.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/language_flag_badge.dart';
import '../../catalog/models/catalog_filter_state.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../../catalog/presentation/widgets/card_grid_item.dart';
import 'widgets/virtual_binder_view.dart';

class FolderDetailScreen extends ConsumerStatefulWidget {
  final Folder? folder; // null if "General"

  const FolderDetailScreen({super.key, required this.folder});

  @override
  ConsumerState<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  late String _displayMode;
  CatalogSortOption _sortOption = CatalogSortOption.nameAsc;
  final GlobalKey<VirtualBinderViewState> _binderKey = GlobalKey<VirtualBinderViewState>();
  final ScrollController _gridScrollController = ScrollController();
  String? _highlightedCardId;
  String _searchQuery = '';
  String? _selectedCondition;
  String? _selectedLanguage;
  String? _selectedFinish;

  int get _activeFilterCount =>
      (_selectedCondition != null ? 1 : 0) +
      (_selectedLanguage != null ? 1 : 0) +
      (_selectedFinish != null ? 1 : 0);

  void _clearFilters() {
    setState(() {
      _selectedCondition = null;
      _selectedLanguage = null;
      _selectedFinish = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _displayMode = widget.folder?.displayMode ?? 'grid';
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  Future<void> _showSearchDialog(List<UserCard> cards) async {
    final strings = getStrings(ref.read(languageProvider));
    final query = await AppSearchDialog.show(
      context,
      initialQuery: _searchQuery,
      hintText: strings.searchCardInFolderHint,
      strings: strings,
      suggestions: cards.take(8).map((c) => c.name).toSet().toList(),
    );
    if (query != null && mounted) {
      setState(() => _searchQuery = query.trim());
      final matching = cards.where((c) {
        final q = query.toLowerCase().trim();
        return c.name.toLowerCase().contains(q) ||
            c.number.toLowerCase() == q ||
            '#${c.number.toLowerCase()}' == q ||
            c.setName.toLowerCase().contains(q);
      }).toList();
      if (matching.isNotEmpty) {
        _onCardSelected(matching.first, cards);
      }
    }
  }

  void _showFilterDialog(AppStrings strings) {
    String? tempCondition = _selectedCondition;
    String? tempLanguage = _selectedLanguage;
    String? tempFinish = _selectedFinish;

    AppFilterModalDialog.show(
      context: context,
      title: strings.filtersAndMore,
      hasActiveFilters: _activeFilterCount > 0,
      strings: strings,
      onClear: () {
        _clearFilters();
      },
      onApply: () {
        setState(() {
          _selectedCondition = tempCondition;
          _selectedLanguage = tempLanguage;
          _selectedFinish = tempFinish;
        });
      },
      children: [
        StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.isEn ? 'Condition' : 'Estado de Conservação',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['NM', 'SP', 'MP', 'HP', 'DMG'].map((cond) {
                    final isSelected = tempCondition == cond;
                    return FilterChip(
                      label: Text(cond),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempCondition = selected ? cond : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.isEn ? 'Language' : 'Idioma',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ('EN', strings.isEn ? 'English (EN)' : 'Inglês (EN)'),
                    ('PT', strings.isEn ? 'Portuguese (PT)' : 'Português (PT)'),
                    ('JP', strings.isEn ? 'Japanese (JP)' : 'Japonês (JP)'),
                  ].map((lang) {
                    final isSelected = tempLanguage == lang.$1;
                    return FilterChip(
                      label: Text(lang.$2),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempLanguage = selected ? lang.$1 : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.cardFinishes,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Regular', 'Foil', 'Reverse Foil'].map((finish) {
                    final isSelected = tempFinish == finish;
                    return FilterChip(
                      label: Text(finish),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempFinish = selected ? finish : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _toggleDisplayMode() {
    setState(() {
      _displayMode = _displayMode == 'grid' ? 'binder' : 'grid';
    });

    if (widget.folder != null) {
      final db = ref.read(databaseProvider);
      db.updateFolder(
        widget.folder!.toCompanion(true).copyWith(
              displayMode: drift.Value(_displayMode),
            ),
      );
    }
  }

  void _shareFolder(List<UserCard> cards, String folderName, AppStrings strings) async {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.folderEmptyToShare)),
      );
      return;
    }

    int totalQty = 0;
    double totalInvested = 0.0;
    for (final c in cards) {
      totalQty += c.quantity;
      totalInvested += (c.purchasePriceBrl * c.quantity);
    }

    final buffer = StringBuffer();
    final headerName = strings.binderHeaderDefault;
    buffer.writeln('=== $headerName: $folderName (WurmDex) ===');
    buffer.writeln('${strings.cardsCount(totalQty)} • ${strings.labelInvested}: ${CurrencyFormatter.toBrl(totalInvested)}\n');
    for (final c in cards) {
      final line = '• ${c.name} (#${c.number}) - ${c.condition} [${c.finish}] x${c.quantity}'
          '${c.purchasePriceBrl > 0 ? ' • ${CurrencyFormatter.toBrl(c.purchasePriceBrl)}' : ''}';
      buffer.writeln(line);
    }
    buffer.writeln('\nOrganized with WurmDex');

    final text = buffer.toString();
    await Clipboard.setData(ClipboardData(text: text));

    try {
      // ignore: deprecated_member_use
      await Share.share(text, subject: '$folderName - WurmDex');
    } catch (_) {
      // Fallback if system share is not supported
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.folderCopiedReadyShare)),
      );
    }
  }

  void _onCardSelected(UserCard card, List<UserCard> sortedCards) {
    setState(() {
      _highlightedCardId = card.id;
    });

    if (_displayMode == 'binder') {
      _binderKey.currentState?.revealCard(card.id);
    } else {
      final index = sortedCards.indexOf(card);
      if (index >= 0 && _gridScrollController.hasClients) {
        final cardScale = ref.read(collectionCardScaleProvider);
        final baseWidth = (210.0 * cardScale).clamp(130.0, 380.0);
        final crossAxisCount = resolveCardGridCrossAxisCount(
          context: context,
          ref: ref,
          availableWidth: MediaQuery.of(context).size.width,
          cardScale: cardScale,
        );
        final row = index ~/ crossAxisCount;
        final targetOffset = row * (baseWidth / 0.62);
        _gridScrollController.animateTo(
          targetOffset.clamp(0.0, _gridScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    }

    // Auto-clear highlight after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _highlightedCardId == card.id) {
        setState(() => _highlightedCardId = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final currency = ref.watch(currencyProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final viewMode = ref.watch(cardViewModeProvider);
    final folderId = widget.folder?.id;
    final folderName = widget.folder?.name ?? strings.generalCollectionTitle;
    final cardsAsync = ref.watch(folderCardsProvider(folderId));
    final cards = cardsAsync.asData?.value ?? const <UserCard>[];

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: folderName),
        actions: [
          AppFilterButton(
            activeFilterCount: _activeFilterCount,
            tooltip: strings.filtersAndMore,
            isFilledTonal: false,
            onPressed: () => _showFilterDialog(strings),
          ),
          AppSortButton<CatalogSortOption>(
            currentOption: _sortOption,
            isCompact: true,
            tooltip: strings.isEn ? 'Sort Cards' : 'Ordenar Cartas',
            onSelected: (option) => setState(() => _sortOption = option),
            options: [
              SortOptionItem(
                value: CatalogSortOption.nameAsc,
                label: strings.isEn ? 'Name (A → Z)' : 'Nome (A → Z)',
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: CatalogSortOption.nameDesc,
                label: strings.isEn ? 'Name (Z → A)' : 'Nome (Z → A)',
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: CatalogSortOption.numberAsc,
                label: strings.isEn ? 'Card Number' : 'Número da Carta',
                icon: Icons.tag,
              ),
              SortOptionItem(
                value: CatalogSortOption.priceAsc,
                label: strings.isEn ? 'Lowest Price' : 'Menor Preço',
                icon: Icons.arrow_upward,
              ),
              SortOptionItem(
                value: CatalogSortOption.priceDesc,
                label: strings.isEn ? 'Highest Price' : 'Maior Preço',
                icon: Icons.arrow_downward,
              ),
              SortOptionItem(
                value: CatalogSortOption.releaseDateDesc,
                label: strings.isEn ? 'Release Date: Newest' : 'Lançamento: Mais Recentes',
                icon: Icons.event,
              ),
              SortOptionItem(
                value: CatalogSortOption.popularityDesc,
                label: strings.isEn ? 'Popularity' : 'Popularidade',
                icon: Icons.local_fire_department,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: () {
              ref.invalidate(folderCardsProvider(folderId));
              ref.read(exchangeRateProvider.notifier).refreshRate();
            },
          ),
          AppOverflowMenu(
            scaleTarget: CardScaleTarget.collection,
            showCurrency: true,
            extraEntries: [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share_outlined, size: 20),
                    const SizedBox(width: 10),
                    Text(strings.tooltipShareFolder),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(
                      _displayMode == 'grid' ? Icons.book : Icons.grid_view,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _displayMode == 'grid'
                          ? strings.viewAsBinder
                          : strings.viewAsGrid,
                    ),
                  ],
                ),
              ),
            ],
            onExtraSelected: (val) {
              if (val == 'share') {
                _shareFolder(cards, folderName, strings);
              } else if (val == 'view') {
                _toggleDisplayMode();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: AppActionFab(
        tooltip: strings.searchActionTitle,
        sheetTitle: folderName,
        actions: [
          AppFabAction(
            icon: Icons.search,
            title: strings.searchActionTitle,
            subtitle: strings.searchCardInFolderHint,
            onTap: () => _showSearchDialog(cards),
          ),
          AppFabAction(
            icon: Icons.add_card_outlined,
            title: strings.btnAddCard,
            subtitle: strings.searchCardsPlaceholder,
            onTap: () => AppNavigator.toCatalog(context, targetFolder: widget.folder),
          ),
          AppFabAction(
            icon: Icons.share_outlined,
            title: strings.tooltipShareFolder,
            subtitle: strings.btnShareBinder,
            onTap: () => _shareFolder(cards, folderName, strings),
          ),
          AppFabAction(
            icon: _displayMode == 'grid' ? Icons.book : Icons.grid_view,
            title: _displayMode == 'grid'
                ? strings.viewAsBinder
                : strings.viewAsGrid,
            subtitle: strings.scaleLayoutTooltip,
            onTap: _toggleDisplayMode,
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: strings.folderEmptyTitle,
              message: strings.folderEmptySubtitle,
              buttonLabel: strings.btnSearchCards,
              buttonIcon: Icons.search,
              onAction: () => AppNavigator.toCatalog(
                context,
                targetFolder: widget.folder,
                autoFocusSearch: true,
              ),
            );
          }

          final sortedCards = CardSortingHelper.sortUserCards(cards, _sortOption);

          final displayedCards = sortedCards.where((c) {
            if (_selectedCondition != null && c.condition != _selectedCondition) return false;
            if (_selectedLanguage != null && c.language != _selectedLanguage) return false;
            if (_selectedFinish != null && c.finish != _selectedFinish) return false;
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase().trim();
              return c.name.toLowerCase().contains(q) ||
                  c.number.toLowerCase() == q ||
                  '#${c.number.toLowerCase()}' == q ||
                  c.setName.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Collection title header: shows the full name (no ellipsis)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        FolderIconHelper.getIcon(widget.folder?.iconName),
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folderName,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.cardsCount(displayedCards.length),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Active Filters & Search chips bar (compact, dismissible)
              if (_searchQuery.isNotEmpty || _activeFilterCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                  child: SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              avatar: const Icon(Icons.search, size: 14),
                              label: Text(_searchQuery, style: const TextStyle(fontSize: 12)),
                              onDeleted: () => setState(() => _searchQuery = ''),
                            ),
                          ),
                        if (_selectedCondition != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text('Condition: $_selectedCondition', style: const TextStyle(fontSize: 12)),
                              onDeleted: () => setState(() => _selectedCondition = null),
                            ),
                          ),
                        if (_selectedLanguage != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text('Language: $_selectedLanguage', style: const TextStyle(fontSize: 12)),
                              onDeleted: () => setState(() => _selectedLanguage = null),
                            ),
                          ),
                        if (_selectedFinish != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text('Finish: $_selectedFinish', style: const TextStyle(fontSize: 12)),
                              onDeleted: () => setState(() => _selectedFinish = null),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Content: 3D Binder, List or Grid (Card) View
              Expanded(
                child: displayedCards.isEmpty
                    ? AppEmptyState(
                        icon: Icons.filter_alt_off,
                        title: strings.noFilterMatch,
                        buttonLabel: strings.btnClearFilters,
                        buttonIcon: Icons.filter_alt,
                        onAction: () {
                          setState(() {
                            _searchQuery = '';
                            _clearFilters();
                          });
                        },
                      )
                    : _displayMode == 'binder'
                        ? VirtualBinderView(
                            key: _binderKey,
                            cards: displayedCards,
                            folderName: folderName,
                            highlightedCardId: _highlightedCardId,
                            onAddCard: () {
                              FocusScope.of(context).unfocus();
                              AppNavigator.toCatalog(
                                context,
                                targetFolder: widget.folder,
                                autoFocusSearch: true,
                              );
                            },
                          )
                        : viewMode == CardViewMode.list
                            ? _buildListView(context, displayedCards, strings, currency, exchangeRate)
                            : _buildGridView(context, displayedCards, strings, currency, exchangeRate),
              ),
            ],
          );
        },
        loading: () {
          final crossAxisCount = resolveCardGridCrossAxisCount(
            context: context,
            ref: ref,
            availableWidth: MediaQuery.of(context).size.width,
            cardScale: ref.watch(collectionCardScaleProvider),
          );
          return CardGridSkeleton(
            crossAxisCount: crossAxisCount,
            padding: const EdgeInsets.all(12),
          );
        },
        error: (err, _) => AppEmptyState(
          icon: Icons.error_outline,
          title: strings.errorLoadingWithMsg(err),
        ),
      ),
    );
  }

  void _openCardDetails(BuildContext context, UserCard card) {
    final liveRate = ref.read(exchangeRateProvider);
    final strings = getStrings(ref.read(languageProvider));
    final item = PokemonCardItem(
      id: card.cardApiId,
      name: card.name,
      number: card.number,
      setId: card.setName.toLowerCase().replaceAll(' ', '-'),
      setName: card.setName,
      rarity: card.rarity.isNotEmpty ? card.rarity : strings.defaultRarity,
      imageUrlSmall: card.imageUrl,
      imageUrlLarge: card.imageUrl,
      types: const [],
      supertype: 'Pokémon',
      artist: '',
      tcgMarketUsd: card.purchasePriceBrl > 0 ? (card.purchasePriceBrl / liveRate) : 0.0,
    );
    AppNavigator.toCardDetails(context, item, userCardId: card.id);
  }

  void _showCardContextMenu(BuildContext context, UserCard card, AppStrings strings) {
    final theme = Theme.of(context);
    final title = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
    );

    showAppModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragHandle(bottomPadding: 8),
              ListTile(
                leading: AppNetworkImage(
                  imageUrl: card.imageUrl,
                  width: 36,
                  height: 50,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(4),
                  fallbackIcon: Icons.style,
                  fallbackIconSize: 24,
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${card.setName} • ${card.condition} • x${card.quantity}'),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                title: Text(strings.viewQuoteAndHistory),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCardDetails(context, card);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.blue),
                title: Text(strings.openInLiga),
                onTap: () {
                  Navigator.pop(ctx);
                  MarketplaceUrlHelper.openLigaPokemon(context, cardName: card.name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.orange),
                title: Text(strings.openInTcgPlayer),
                onTap: () {
                  Navigator.pop(ctx);
                  MarketplaceUrlHelper.openTcgPlayer(context, cardName: card.name, cardNumber: card.number);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.lossRed),
                title: Text(strings.deleteFromCollection, style: const TextStyle(color: AppColors.lossRed, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteCard(card, strings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCard(UserCard card, AppStrings strings) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteCardTitle),
        content: Text(strings.confirmRemoveFromFolderMsg(card.name, card.number)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.lossRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.remove),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(databaseProvider).deleteCard(card.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.cardRemovedFromCollection(card.name))),
      );
    }
  }

  Widget _buildGridView(BuildContext context, List<UserCard> cards, AppStrings strings, AppCurrency currency, double exchangeRate) {
    final width = MediaQuery.of(context).size.width;
    final cardScale = ref.watch(collectionCardScaleProvider);

    // Responsive dynamic column sizing with user scale preference
    final crossAxisCount = resolveCardGridCrossAxisCount(
      context: context,
      ref: ref,
      availableWidth: width,
      cardScale: cardScale,
    );

    return GridView.builder(
      controller: _gridScrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: AppConstants.cardGridItemAspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final catalogCard = PokemonCardItem(
          id: card.cardApiId.isNotEmpty ? card.cardApiId : card.id,
          name: card.name,
          number: card.number,
          setId: card.setName.toLowerCase().replaceAll(' ', '-'),
          setName: card.setName,
          rarity: card.rarity.isNotEmpty ? card.rarity : strings.defaultRarity,
          imageUrlSmall: card.imageUrl,
          imageUrlLarge: card.imageUrl,
          types: const [],
          supertype: 'Pokémon',
          artist: '',
          tcgMarketUsd: card.purchasePriceBrl > 0 ? (card.purchasePriceBrl / exchangeRate) : null,
        );

        final priceString = card.purchasePriceBrl > 0
            ? (currency == AppCurrency.usd
                ? CurrencyFormatter.toUsd(card.purchasePriceBrl / exchangeRate)
                : CurrencyFormatter.toBrl(card.purchasePriceBrl))
            : CurrencyFormatter.formatCardPrice(
                usdValue: catalogCard.effectiveMidPriceUsd,
                exchangeRate: exchangeRate,
                currency: currency,
              );

        final isGlowing = _highlightedCardId != null &&
            (_highlightedCardId == card.id || _highlightedCardId == card.cardApiId);

        final quantityBadge = card.quantity > 1
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Text(
                  'x${card.quantity}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )
            : null;

        return CardShimmerGlow(
          isGlowing: isGlowing,
          child: CardGridItem(
            card: catalogCard,
            condition: card.condition,
            language: card.language,
            customPriceText: priceString,
            topLeftBadge: quantityBadge,
            onTap: () => _openCardDetails(context, card),
            onLongPress: () => _showCardContextMenu(context, card, strings),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List<UserCard> cards, AppStrings strings, AppCurrency currency, double exchangeRate) {
    final theme = Theme.of(context);

    return ListView.separated(
      controller: _gridScrollController,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final card = cards[index];
        final quantityBadge = card.quantity > 1
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
                child: Text(
                  'x${card.quantity}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )
            : null;

        final priceString = card.purchasePriceBrl > 0
            ? (currency == AppCurrency.usd
                ? CurrencyFormatter.toUsd(card.purchasePriceBrl / exchangeRate)
                : CurrencyFormatter.toBrl(card.purchasePriceBrl))
            : null;

        return Card(
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openCardDetails(context, card),
            onLongPress: () => _showCardContextMenu(context, card, strings),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppNetworkImage(
                        imageUrl: card.imageUrl,
                        width: 48,
                        height: 68,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(6),
                        fallbackIcon: Icons.style,
                        fallbackIconSize: 28,
                      ),
                      if (quantityBadge != null)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: quantityBadge,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${SemanticSearchHelper.formatCardIdentifier(rawName: card.name, number: card.number)} • ${card.setName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ConditionBadge(condition: card.condition, compact: true),
                            LanguageFlagBadge(language: card.language, compact: true),
                            if (priceString != null)
                              Text(
                                priceString,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
