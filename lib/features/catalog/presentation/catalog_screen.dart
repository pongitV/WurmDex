import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/card_view_mode_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/providers/grid_composition_provider.dart';
import '../../../../core/utils/card_sorting_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/app_action_fab.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_filter_modal.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../../core/widgets/app_screen_title.dart';
import '../../../../core/widgets/app_search_dialog.dart';
import '../../../../core/widgets/card_grid_skeleton.dart';
import '../../../../core/widgets/app_sort_button.dart';
import '../../news/models/news_filter_state.dart';
import '../../news/presentation/widgets/tcg_news_widget.dart';
import '../models/catalog_filter_state.dart';
import '../models/pokemon_card_item.dart';
import '../services/pokemon_catalog_service.dart';
import 'widgets/card_grid_item.dart';
import 'widgets/card_quick_action_sheet.dart';
import 'widgets/catalog_filter_bottom_sheet.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  final FocusNode? searchFocusNode;
  final VoidCallback? onNavigateToCollections;
  final Folder? targetFolder;
  final bool autoFocusSearch;

  const CatalogScreen({
    super.key,
    this.searchFocusNode,
    this.onNavigateToCollections,
    this.targetFolder,
    this.autoFocusSearch = false,
  });

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.searchFocusNode ?? _internalFocusNode;

  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _isSearching = false;
  List<PokemonCardItem> _cards = [];
  String? _searchLanguage;
  CatalogFilterState _filterState = const CatalogFilterState();
  NewsFilterState _newsFilterState = const NewsFilterState();
  final GlobalKey<TcgNewsWidgetState> _newsKey = GlobalKey<TcgNewsWidgetState>();

  List<PokemonCardItem> get _filteredAndSortedCards {
    List<PokemonCardItem> list = List.from(_cards);

    // Apply Energy Type / Supertype filter
    if (_filterState.selectedType != null) {
      final t = _filterState.selectedType!.toLowerCase();
      list = list.where((card) {
        final typesMatch = card.types.any((type) => type.toLowerCase() == t);
        final supertypeMatch = card.supertype.toLowerCase() == t;
        return typesMatch || supertypeMatch;
      }).toList();
    }

    // Apply Rarity filter
    if (_filterState.selectedRarity != null) {
      final r = _filterState.selectedRarity!.toLowerCase();
      list = list.where((card) {
        return card.rarity.toLowerCase().contains(r) ||
            (r == 'ultra rare' &&
                (card.name.contains('-ex') ||
                    card.name.contains(' V') ||
                    card.name.contains(' VSTAR') ||
                    card.name.contains(' VMAX')));
      }).toList();
    }

    // Apply Card Language filter
    if (_filterState.selectedLanguage != null) {
      final lang = _filterState.selectedLanguage!.toLowerCase();
      list = list.where((card) => card.language.toLowerCase() == lang).toList();
    }

    // Apply Sorting
    return CardSortingHelper.sort(list, _filterState.sortOption);
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);
      final isEn = ref.read(languageProvider) == AppLanguage.enUs;
      final results = await PokemonCatalogService.searchCards(
        query: query,
        isEn: isEn,
        language: _searchLanguage,
      );
      if (mounted) {
        setState(() {
          _cards = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    if (widget.targetFolder != null || widget.autoFocusSearch) {
      _isSearching = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSearchChanged('');
        _effectiveFocusNode.requestFocus();
      });
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    if (_cards.isEmpty && _searchController.text.isEmpty) {
      _onSearchChanged('');
    }
    _effectiveFocusNode.requestFocus();
  }

  Future<void> _openSearchDialog() async {
    final strings = getStrings(ref.read(languageProvider));
    final query = await AppSearchDialog.show(
      context,
      initialQuery: _searchController.text,
      strings: strings,
    );
    if (query == null || !mounted) return;
    _searchController.text = query;
    setState(() => _isSearching = query.isNotEmpty);
    _onSearchChanged(query);
  }

  void _applyFilter(CatalogFilterState newState, AppStrings strings) {
    final nextLang = newState.selectedLanguage;
    String? newSearchLanguage;
    if (nextLang != null) {
      final currentEffective = _searchLanguage ?? (strings.isEn ? 'en' : 'pt');
      newSearchLanguage = nextLang != currentEffective ? nextLang : _searchLanguage;
    } else {
      newSearchLanguage = null;
    }
    final needsResearch = newSearchLanguage != _searchLanguage;
    setState(() {
      _filterState = newState;
      _searchLanguage = newSearchLanguage;
    });
    if (needsResearch) {
      _onSearchChanged(_searchController.text);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filterState = const CatalogFilterState();
      _searchLanguage = null;
    });
    _onSearchChanged(_searchController.text);
  }

  void _showNewsFilterDialog(AppStrings strings) {
    String tempSource = _newsFilterState.selectedSource;
    String tempCategory = _newsFilterState.selectedCategory;

    AppFilterModalDialog.show(
      context: context,
      title: strings.newsFilterTitle,
      hasActiveFilters: _newsFilterState.hasActiveFilters,
      strings: strings,
      onClear: () {
        setState(() {
          _newsFilterState = _newsFilterState.copyWith(
            selectedSource: 'ALL',
            selectedCategory: 'ALL',
          );
        });
      },
      onApply: () {
        setState(() {
          _newsFilterState = _newsFilterState.copyWith(
            selectedSource: tempSource,
            selectedCategory: tempCategory,
          );
        });
      },
      children: [
        StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.newsSourcesSection,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(strings.chipAll),
                      selected: tempSource == 'ALL',
                      onSelected: (_) => setModalState(() => tempSource = 'ALL'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.verified_outlined, size: 14, color: Color(0xFFEF4444)),
                      label: Text(strings.chipPokemonOfficial),
                      selected: tempSource == 'Pokemon.com',
                      onSelected: (_) => setModalState(() => tempSource = 'Pokemon.com'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF8B5CF6)),
                      label: Text(strings.chipBillsArchive),
                      selected: tempSource == "Bill's Archive",
                      onSelected: (_) => setModalState(() => tempSource = "Bill's Archive"),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.emoji_events_outlined, size: 14, color: Color(0xFFF59E0B)),
                      label: Text(strings.chipTcgScene),
                      selected: tempSource == 'Scene',
                      onSelected: (_) => setModalState(() => tempSource = 'Scene'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.forum_outlined, size: 14, color: Color(0xFF06B6D4)),
                      label: const Text('TCGTalk'),
                      selected: tempSource == 'TCGTalk',
                      onSelected: (_) => setModalState(() => tempSource = 'TCGTalk'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  strings.newsCategoriesSection,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(strings.newsCategoryAll),
                      selected: tempCategory == 'ALL',
                      onSelected: (_) => setModalState(() => tempCategory = 'ALL'),
                    ),
                    FilterChip(
                      label: Text(strings.newsCategorySets),
                      selected: tempCategory == 'SETS_PRODUCTS',
                      onSelected: (_) => setModalState(() => tempCategory = 'SETS_PRODUCTS'),
                    ),
                    FilterChip(
                      label: Text(strings.newsCategoryCompetitive),
                      selected: tempCategory == 'COMPETITIVE',
                      onSelected: (_) => setModalState(() => tempCategory = 'COMPETITIVE'),
                    ),
                    FilterChip(
                      label: Text(strings.newsCategoryCommunity),
                      selected: tempCategory == 'COMMUNITY',
                      onSelected: (_) => setModalState(() => tempCategory = 'COMMUNITY'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _exitSearch() {
    if (widget.targetFolder != null) {
      _searchController.clear();
      _onSearchChanged('');
      return;
    }
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _cards = [];
      _searchLanguage = null;
      _filterState = const CatalogFilterState();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final menuScale = ref.watch(menuCardScaleProvider);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final viewMode = ref.watch(cardViewModeProvider);
    final isListView = viewMode == CardViewMode.list;

    // Responsive dynamic column sizing respecting universal grid composition
    final crossAxisCount = resolveCardGridCrossAxisCount(
      context: context,
      ref: ref,
      availableWidth: width,
      cardScale: menuScale,
    );

    final showSearchResults = _isSearching || _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: widget.targetFolder != null
            ? AppScreenTitle(title: '${strings.selectCard} - ${widget.targetFolder!.name}')
            : AppScreenTitle(title: strings.appTitle),
        actions: [
          if (showSearchResults) ...[
            AppFilterButton(
              activeFilterCount: _filterState.activeFilterCount,
              tooltip: strings.filtersAndMore,
              isFilledTonal: false,
              onPressed: () {
                showCatalogFilterDialog(
                  context,
                  currentState: _filterState,
                  strings: strings,
                  onApply: (newState) => _applyFilter(newState, strings),
                );
              },
            ),
            AppSortButton<CatalogSortOption>(
              currentOption: _filterState.sortOption,
              isCompact: true,
              tooltip: strings.isEn ? 'Sort Cards' : 'Ordenar Cartas',
              onSelected: (option) {
                setState(() {
                  _filterState = _filterState.copyWith(sortOption: option);
                });
              },
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
          ] else ...[
            AppFilterButton(
              activeFilterCount: _newsFilterState.activeFilterCount,
              tooltip: strings.newsFilterTitle,
              isFilledTonal: false,
              onPressed: () => _showNewsFilterDialog(strings),
            ),
            AppSortButton<NewsSortOption>(
              currentOption: _newsFilterState.sortOption,
              isCompact: true,
              tooltip: strings.newsSortTitle,
              onSelected: (val) => setState(() => _newsFilterState = _newsFilterState.copyWith(sortOption: val)),
              options: [
                SortOptionItem(
                  value: NewsSortOption.newest,
                  label: strings.newsSortNewest,
                  icon: Icons.access_time,
                ),
                SortOptionItem(
                  value: NewsSortOption.oldest,
                  label: strings.newsSortOldest,
                  icon: Icons.history,
                ),
                SortOptionItem(
                  value: NewsSortOption.titleAsc,
                  label: strings.newsSortTitleAsc,
                  icon: Icons.sort_by_alpha,
                ),
                SortOptionItem(
                  value: NewsSortOption.source,
                  label: strings.newsSortSource,
                  icon: Icons.newspaper,
                ),
              ],
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: () {
              ref.read(exchangeRateProvider.notifier).refreshRate();
              if (showSearchResults) {
                _onSearchChanged(_searchController.text);
              } else {
                _newsKey.currentState?.refreshNews();
              }
            },
          ),
          const AppOverflowMenu(
            scaleTarget: CardScaleTarget.menu,
            showCurrency: true,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Persistent Search Bar at the top of the Menu / Catalog (full width,
          // above the action buttons so it never gets squeezed)
          if (widget.targetFolder != null)
            Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _effectiveFocusNode,
              autofocus: widget.autoFocusSearch || widget.targetFolder != null,
              onTap: () {
                if (!_isSearching) {
                  _startSearch();
                }
              },
              onChanged: (val) {
                if (!_isSearching && val.isNotEmpty) {
                  setState(() => _isSearching = true);
                }
                _onSearchChanged(val);
              },
              decoration: InputDecoration(
                hintText: strings.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Toolbar with active Query and Filter Chips
          if (showSearchResults)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  if (_searchController.text.isNotEmpty) ...[
                    InputChip(
                      avatar: const Icon(Icons.search, size: 14),
                      label: Text(
                        _searchController.text,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: _exitSearch,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_filterState.activeFilterCount > 0)
                    Chip(
                      label: Text('${_filterState.activeFilterCount} ${strings.filtersAndMore}'),
                      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: _exitSearch,
                    child: Text(strings.btnHome),
                  ),
                ],
              ),
            ),
          if (widget.targetFolder != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.tapCardToAddToFolder(widget.targetFolder!.name),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Filters horizontal chips bar
            if (_filterState.hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_filterState.selectedType != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text('${strings.filterTypeLabel}${_filterState.selectedType}'),
                            onDeleted: () {
                              setState(() {
                                _filterState = _filterState.copyWith(clearType: true);
                              });
                            },
                          ),
                        ),
                      if (_filterState.selectedRarity != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text('${strings.filterRarityLabel}${_filterState.selectedRarity}'),
                            onDeleted: () {
                              setState(() {
                                _filterState = _filterState.copyWith(clearRarity: true);
                              });
                            },
                          ),
                        ),
                      if (_filterState.selectedLanguage != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text('${strings.languageLabel}${strings.languageDisplayName(_filterState.selectedLanguage!)}'),
                            onDeleted: () {
                              setState(() {
                                _filterState = _filterState.copyWith(clearLanguage: true);
                                _searchLanguage = null;
                              });
                              _onSearchChanged(_searchController.text);
                            },
                          ),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(strings.btnClearFilters, style: const TextStyle(fontSize: 11)),
                        onPressed: _clearAllFilters,
                      ),
                    ],
                  ),
                ),
              ),

          // Main View: Either Search Results or Home Dashboard
          Expanded(
            child: showSearchResults
                ? _buildSearchResults(crossAxisCount, theme, strings, exchangeRate, isListView)
                : _buildHomeDashboard(theme),
          ),
        ],
      ),
      floatingActionButton: widget.targetFolder == null
          ? AppActionFab(
              tooltip: strings.searchActionTitle,
              sheetTitle: strings.navCatalog,
              actions: [
                AppFabAction(
                  icon: Icons.search,
                  title: strings.searchActionTitle,
                  subtitle: strings.searchHint,
                  onTap: _openSearchDialog,
                ),
                if (showSearchResults)
                  AppFabAction(
                    icon: Icons.newspaper,
                    title: strings.sectionNews,
                    subtitle: strings.btnHome,
                    onTap: _exitSearch,
                  ),
                if (_searchController.text.isNotEmpty || _filterState.activeFilterCount > 0)
                  AppFabAction(
                    icon: Icons.clear_all,
                    title: strings.btnClearFilters,
                    subtitle: strings.reset,
                    isDestructive: true,
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _filterState = const CatalogFilterState();
                      });
                      _exitSearch();
                    },
                  ),
              ],
            )
          : null,
    );
  }

  Widget _buildHomeDashboard(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Notícias & Lançamentos Oficiais do Pokémon TCG
        TcgNewsWidget(
          key: _newsKey,
          filterState: _newsFilterState,
        ),
      ],
    );
  }

  Widget _buildSearchResults(int crossAxisCount, ThemeData theme, AppStrings strings, double exchangeRate, bool isListView) {
    if (_isLoading) {
      return CardGridSkeleton(
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.all(12),
      );
    }

    if (_cards.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off,
        title: strings.noCardsFound,
        message: strings.tryAnotherSearch,
      );
    }

    final displayCards = _filteredAndSortedCards;

    if (displayCards.isEmpty) {
      return AppEmptyState(
        icon: Icons.filter_alt_off,
        title: strings.noFilterMatch,
        buttonLabel: strings.btnClearFilters,
        buttonIcon: Icons.filter_alt,
        onAction: _clearAllFilters,
      );
    }

    if (isListView) {
      return _buildTableView(displayCards, theme, exchangeRate);
    }

    return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: AppConstants.cardGridItemAspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: displayCards.length,
            itemBuilder: (context, index) {
              final card = displayCards[index];
              return CardGridItem(
                card: card,
                exchangeRate: exchangeRate,
                onTap: widget.targetFolder != null
                    ? () {
                        CardQuickActionSheet.showAddToFolderDialog(
                          context: context,
                          ref: ref,
                          card: card,
                          preselectedFolderId: widget.targetFolder!.id,
                        );
                      }
                    : null,
                onLongPress: () => CardQuickActionSheet.show(context, card),
              );
            },
          );
  }

  Widget _buildTableView(List<PokemonCardItem> displayCards, ThemeData theme, double exchangeRate) {
    return ListView.separated(
      itemCount: displayCards.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final card = displayCards[index];
        final title = SemanticSearchHelper.formatCardIdentifier(
          rawName: card.name,
          number: card.number,
          setTotal: card.setTotal,
        );
        final currency = ref.watch(currencyProvider);
        final priceText = CurrencyFormatter.formatCardPrice(
          usdValue: card.effectiveMidPriceUsd,
          exchangeRate: exchangeRate,
          currency: currency,
        );

        return ListTile(
          dense: true,
          leading: AppNetworkImage(
            imageUrl: card.imageUrlSmall,
            width: 32,
            height: 44,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(4),
            fallbackIcon: Icons.broken_image,
            fallbackIconSize: 24,
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(
            '${card.setName} • ${card.rarity}',
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          trailing: Text(
            priceText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
          ),
          onTap: () {
            if (widget.targetFolder != null) {
              CardQuickActionSheet.showAddToFolderDialog(
                context: context,
                ref: ref,
                card: card,
                preselectedFolderId: widget.targetFolder!.id,
              );
            } else {
              AppNavigator.toCardDetails(context, card);
            }
          },
          onLongPress: () {
            CardQuickActionSheet.show(context, card);
          },
        );
      },
    );
  }

}
