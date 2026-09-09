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
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_sorting_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/marketplace_url_helper.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../../../core/widgets/card_grid_skeleton.dart';
import '../../../../core/widgets/card_scale_button.dart';
import '../../../../core/widgets/card_shimmer_glow.dart';
import '../../../../core/widgets/card_sort_button.dart';
import '../../../../core/widgets/quick_currency_toggle.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<VirtualBinderViewState> _binderKey = GlobalKey<VirtualBinderViewState>();
  final ScrollController _gridScrollController = ScrollController();
  String? _highlightedCardId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _displayMode = widget.folder?.displayMode ?? 'grid';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _gridScrollController.dispose();
    super.dispose();
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
        final crossAxisCount = calculateScaledCrossAxisCount(
          width: MediaQuery.of(context).size.width,
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
    final folderId = widget.folder?.id;
    final folderName = widget.folder?.name ?? strings.generalCollectionTitle;
    final cardsAsync = ref.watch(folderCardsProvider(folderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        actions: [
          // Share Folder Button
          cardsAsync.when(
            data: (cards) => IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: strings.tooltipShareFolder,
              onPressed: () => _shareFolder(cards, folderName, strings),
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          // Quick Currency Toggle
          const QuickCurrencyToggle(),
          // Scale Adjuster button
          const CardScaleButton(target: CardScaleTarget.collection),
          // Sort Button
          CardSortButton(
            currentOption: _sortOption,
            isEn: strings.isEn,
            onSelected: (option) {
              setState(() {
                _sortOption = option;
              });
            },
          ),
          // 1-Click Toggle between Grande (Grid) and Virtual Binder 3D
          IconButton(
            icon: Icon(_displayMode == 'grid' ? Icons.book : Icons.grid_view),
            tooltip: _displayMode == 'grid' ? strings.viewAsBinder : strings.viewAsGrid,
            onPressed: _toggleDisplayMode,
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
            );
          }

          final sortedCards = CardSortingHelper.sortUserCards(cards, _sortOption);

          // Matching cards for search suggestions / selection
          final matchingCards = _searchQuery.trim().isEmpty
              ? <UserCard>[]
              : sortedCards.where((c) {
                  final q = _searchQuery.toLowerCase().trim();
                  return c.name.toLowerCase().contains(q) ||
                      c.number.toLowerCase() == q ||
                      '#${c.number.toLowerCase()}' == q ||
                      c.setName.toLowerCase().contains(q);
                }).toList();

          return Column(
            children: [
              // Top Search Bar to locate and animate card reveal in binder or grid
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  children: [
                    AppSearchBar(
                      controller: _searchController,
                      padding: EdgeInsets.zero,
                      hintText: strings.isEn
                          ? 'Search card in folder by name or #...'
                          : 'Buscar carta na coleção por nome ou #...',
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      onSubmitted: (val) {
                        if (matchingCards.isNotEmpty) {
                          _onCardSelected(matchingCards.first, sortedCards);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      onClear: () {
                        setState(() => _searchQuery = '');
                      },
                    ),
                    // Quick suggestion pills when searching
                    if (matchingCards.isNotEmpty && _searchQuery.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: matchingCards.take(4).map((c) {
                            return ActionChip(
                              avatar: const Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                              label: Text('${c.name} #${c.number}'),
                              onPressed: () {
                                _onCardSelected(c, sortedCards);
                                FocusScope.of(context).unfocus();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // Content: 3D Binder or Grande (Grid) View ONLY
              Expanded(
                child: _displayMode == 'binder'
                    ? VirtualBinderView(
                        key: _binderKey,
                        cards: sortedCards,
                        folderName: folderName,
                        highlightedCardId: _highlightedCardId,
                        onAddCard: () => Navigator.pop(context),
                      )
                    : _buildGridView(context, sortedCards, strings, currency, exchangeRate),
              ),
            ],
          );
        },
        loading: () {
          final crossAxisCount = calculateScaledCrossAxisCount(
            width: MediaQuery.of(context).size.width,
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
    final crossAxisCount = calculateScaledCrossAxisCount(
      width: width,
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

        final deleteBadge = InkWell(
          onTap: () => _confirmDeleteCard(card, strings),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delete_outline,
              size: 15,
              color: AppColors.lossRed,
            ),
          ),
        );

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
            customPriceText: priceString,
            topLeftBadge: deleteBadge,
            topRightBadge: quantityBadge,
            onTap: () => _openCardDetails(context, card),
            onLongPress: () => _showCardContextMenu(context, card, strings),
          ),
        );
      },
    );
  }
}
