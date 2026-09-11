import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/utils/card_sorting_helper.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/card_grid_skeleton.dart';
import '../../../core/widgets/card_sort_button.dart';
import '../../catalog/models/catalog_filter_state.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../../catalog/presentation/widgets/card_grid_item.dart';
import '../data/tcg_sets_data.dart';
import '../models/set_product_item.dart';
import '../models/tcg_set_item.dart';
import '../services/set_completion_helper.dart';
import '../services/tcg_sets_service.dart';
import 'widgets/set_product_card.dart';

class SetDetailScreen extends ConsumerStatefulWidget {
  final TcgSetItem set;

  const SetDetailScreen({
    super.key,
    required this.set,
  });

  @override
  ConsumerState<SetDetailScreen> createState() => _SetDetailScreenState();
}

class _SetDetailScreenState extends ConsumerState<SetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<PokemonCardItem> _cards = [];
  List<SetProductItem> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  CatalogSortOption _sortOption = CatalogSortOption.numberAsc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cards = await TcgSetsService.fetchCardsForSet(widget.set.id);
      final products = TcgSetsService.fetchProductsForSet(widget.set);

      if (mounted) {
        setState(() {
          _cards = cards;
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<PokemonCardItem> _getFilteredAndSortedCards() {
    var list = _cards;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.number.toLowerCase() == q ||
            '#${c.number.toLowerCase()}' == q;
      }).toList();
    }
    return CardSortingHelper.sort(list, _sortOption);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLanguage = ref.watch(languageProvider);
    final strings = getStrings(currentLanguage);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final isEn = strings.isEn;

    final userCards = ref.watch(userCardsStreamProvider).asData?.value ?? [];
    final ownedCount = SetCompletionHelper.getOwnedDistinctCount(userCards, widget.set);
    final ratio = SetCompletionHelper.getCompletionRatio(ownedCount, widget.set);
    final totalCards = widget.set.totalCards > 0 ? widget.set.totalCards : widget.set.officialCards;

    return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.set.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              AppOverflowMenu(
                scaleTarget: CardScaleTarget.menu,
                showCurrency: true,
                showRefresh: true,
                onRefresh: _loadData,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.style, size: 20),
                  text: isEn ? 'Cards (${_cards.length})' : 'Cartas (${_cards.length})',
                ),
                Tab(
                  icon: const Icon(Icons.inventory_2_outlined, size: 20),
                  text: isEn ? 'Products (${_products.length})' : 'Produtos (${_products.length})',
                ),
              ],
            ),
          ),
          body: _isLoading
              ? CardGridSkeleton(
                  crossAxisCount: resolveCardGridCrossAxisCount(
                    context: context,
                    ref: ref,
                  ),
                  padding: const EdgeInsets.all(16),
                )
              : _errorMessage != null
                  ? AppEmptyState(
                      icon: Icons.error_outline,
                      iconColor: colorScheme.error,
                      title: _errorMessage!,
                      buttonLabel: strings.btnTryAgain,
                      buttonIcon: Icons.refresh,
                      onAction: _loadData,
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Cards
                        _buildCardsTab(
                          theme,
                          colorScheme,
                          strings,
                          exchangeRate,
                          userCards,
                          ownedCount,
                          totalCards,
                          ratio,
                          isEn,
                        ),

                        // Tab 2: Sealed Products
                        _buildProductsTab(theme, colorScheme, exchangeRate, isEn),
                      ],
                    ),
    );
  }

  Widget _buildCardsTab(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
    double exchangeRate,
    List<UserCard> userCards,
    int ownedCount,
    int totalCards,
    double ratio,
    bool isEn,
  ) {
    final filteredCards = _getFilteredAndSortedCards();
    final initialReleaseDate = TcgSetsData.getInitialReleaseDate(
      widget.set.id,
      apiReleaseDate: widget.set.releaseDate,
      year: widget.set.year,
      isEn: isEn,
    );
    final reprintDates = TcgSetsData.getReprintDates(widget.set.id, isEn: isEn);

    return Column(
      children: [
        // Set Header & Progress Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.set.logoUrl != null && widget.set.logoUrl!.isNotEmpty)
                    AppNetworkImage(
                      imageUrl: widget.set.logoUrl!,
                      height: 36,
                      fit: BoxFit.contain,
                      errorWidget: const SizedBox.shrink(),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.set.displayNameWithCount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.set.year} • $ownedCount / $totalCards ${(ratio * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ratio >= 1.0 ? Colors.green : colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Dates section: Initial Release & Reprints
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Initial Release Row
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 13, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${strings.firstReleaseDateLabel}: ',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            initialReleaseDate,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Reprints Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.repeat_rounded, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        Text(
                          '${strings.reprintDatesLabel}: ',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: reprintDates.map((rDate) {
                              final isSoon = rDate.toLowerCase().contains('soon');
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isSoon ? Colors.amber : Colors.orange).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (isSoon ? Colors.amber : Colors.orange).withValues(alpha: 0.4),
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  rDate,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSoon ? Colors.amber.shade800 : Colors.orange.shade800,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search and Sort Bar (DRY)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  controller: _searchController,
                  hintText: isEn ? 'Search card in set...' : 'Buscar carta na coleção...',
                  padding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(width: 8),
              CardSortButton(
                currentOption: _sortOption,
                isEn: isEn,
                onSelected: (opt) => setState(() => _sortOption = opt),
              ),
            ],
          ),
        ),

        // Grid of Cards
        Expanded(
          child: filteredCards.isEmpty
              ? AppEmptyState(
                  icon: Icons.search_off,
                  title: isEn ? 'No cards found' : 'Nenhuma carta encontrada',
                  message: _searchQuery.isNotEmpty
                      ? (isEn ? 'Try adjusting your search term' : 'Tente ajustar o termo da busca')
                      : null,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = resolveCardGridCrossAxisCount(
                      context: context,
                      ref: ref,
                      availableWidth: constraints.maxWidth,
                    );

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: AppConstants.cardGridItemAspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = filteredCards[index];
                        final isOwned = SetCompletionHelper.isCardOwned(userCards, card);

                        return CardGridItem(
                          card: card,
                          exchangeRate: exchangeRate,
                          isOwned: isOwned,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductsTab(
    ThemeData theme,
    ColorScheme colorScheme,
    double exchangeRate,
    bool isEn,
  ) {
    if (_products.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: isEn ? 'No sealed products listed' : 'Nenhum produto selado disponível',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return SetProductCard(
          product: _products[index],
          exchangeRate: exchangeRate,
          isEn: isEn,
        );
      },
    );
  }
}