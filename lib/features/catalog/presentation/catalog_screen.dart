import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/card_sorting_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../../../core/widgets/card_grid_skeleton.dart';
import '../../../../core/widgets/card_scale_button.dart';
import '../../../../core/widgets/card_sort_button.dart';
import '../../../../core/widgets/quick_currency_toggle.dart';
import '../../../../core/widgets/wobbly_menu_icon.dart';
import '../../news/presentation/widgets/tcg_news_widget.dart';
import '../models/catalog_filter_state.dart';
import '../models/pokemon_card_item.dart';
import '../services/pokemon_catalog_service.dart';
import 'widgets/card_grid_item.dart';
import 'widgets/card_quick_action_sheet.dart';
import 'widgets/catalog_filter_bottom_sheet.dart';

enum CatalogViewMode {
  grid,
  table,
}

class CatalogScreen extends ConsumerStatefulWidget {
  final FocusNode? searchFocusNode;
  final VoidCallback? onNavigateToCollections;

  const CatalogScreen({
    super.key,
    this.searchFocusNode,
    this.onNavigateToCollections,
  });

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _isSearching = false;
  List<PokemonCardItem> _cards = [];
  CatalogViewMode _viewMode = CatalogViewMode.grid;
  CatalogFilterState _filterState = const CatalogFilterState();

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

    // Apply Sorting
    return CardSortingHelper.sort(list, _filterState.sortOption);
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);
      final isEn = ref.read(languageProvider) == AppLanguage.enUs;
      final results = await PokemonCatalogService.searchCards(query: query, isEn: isEn);
      if (mounted) {
        setState(() {
          _cards = results;
          _isLoading = false;
        });
      }
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    if (_cards.isEmpty && _searchController.text.isEmpty) {
      _onSearchChanged('');
    }
    widget.searchFocusNode?.requestFocus();
  }

  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _cards = [];
      _filterState = const CatalogFilterState();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
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

    // Responsive dynamic column sizing with user scale preference for Menu/Catalog
    final crossAxisCount = calculateScaledCrossAxisCount(
      width: width,
      cardScale: menuScale,
      baseCardWidth: 230.0,
      minBaseWidth: 160.0,
      maxBaseWidth: 420.0,
      minColumns: 2,
      maxColumns: 12,
    );

    final showSearchResults = _isSearching || _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WobblyMenuIcon(
              size: 26,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                strings.appTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Quick Currency Toggle (USD / BRL)
          const QuickCurrencyToggle(),
          const SizedBox(width: 4),
          // Scale Adjuster button
          const CardScaleButton(target: CardScaleTarget.menu),
          // View Mode Switcher (Grid vs Table) when in search mode
          if (showSearchResults)
            IconButton(
              icon: Icon(_viewMode == CatalogViewMode.grid ? Icons.table_chart : Icons.grid_view),
              tooltip: _viewMode == CatalogViewMode.grid ? strings.tableModeTooltip : strings.gridModeTooltip,
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == CatalogViewMode.grid ? CatalogViewMode.table : CatalogViewMode.grid;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: () {
              ref.read(exchangeRateProvider.notifier).refreshRate();
              if (showSearchResults) {
                _onSearchChanged(_searchController.text);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Persistent Search Bar at the top of the Menu / Catalog
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: widget.searchFocusNode,
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
                if (showSearchResults) ...[
                  const SizedBox(width: 8),
                  // Filter button
                  IconButton.filledTonal(
                    icon: Badge(
                      isLabelVisible: _filterState.hasActiveFilters,
                      label: Text('${_filterState.activeFilterCount}'),
                      child: const Icon(Icons.tune, size: 20),
                    ),
                    tooltip: strings.filtersAndMore,
                    onPressed: () {
                      showCatalogFilterBottomSheet(
                        context,
                        currentState: _filterState,
                        onApply: (newState) {
                          setState(() {
                            _filterState = newState;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Quick Sort button
                  CardSortButton(
                    currentOption: _filterState.sortOption,
                    isEn: strings.isEn,
                    onSelected: (option) {
                      setState(() {
                        _filterState = _filterState.copyWith(sortOption: option);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _exitSearch,
                    child: Text(strings.btnHome),
                  ),
                ],
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
                      TextButton.icon(
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(strings.btnClearFilters, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _filterState = const CatalogFilterState();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

          // Main View: Either Search Results or Home Dashboard
          Expanded(
            child: showSearchResults
                ? _buildSearchResults(crossAxisCount, theme, strings, exchangeRate)
                : _buildHomeDashboard(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: const [
        // Notícias & Lançamentos Oficiais do Pokémon TCG
        TcgNewsWidget(),
      ],
    );
  }

  Widget _buildSearchResults(int crossAxisCount, ThemeData theme, AppStrings strings, double exchangeRate) {
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
        onAction: () {
          setState(() {
            _filterState = const CatalogFilterState();
          });
        },
      );
    }

    return _viewMode == CatalogViewMode.grid
        ? GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: AppConstants.cardGridItemAspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: displayCards.length,
            itemBuilder: (context, index) {
              return CardGridItem(
                card: displayCards[index],
                exchangeRate: exchangeRate,
              );
            },
          )
        : _buildTableView(displayCards, theme, exchangeRate);
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
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              card.imageUrlSmall,
              width: 32,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 24),
            ),
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
            AppNavigator.toCardDetails(context, card);
          },
          onLongPress: () {
            showAppModalBottomSheet(
              context: context,
              builder: (ctx) => CardQuickActionSheet(card: card),
            );
          },
        );
      },
    );
  }
}
