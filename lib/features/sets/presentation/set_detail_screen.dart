import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/card_sorting_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/semantic_search_helper.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/card_grid_skeleton.dart';
import '../../../core/widgets/card_sort_button.dart';
import '../../../core/widgets/pokemon_card_image.dart';
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
    final cardScale = ref.watch(menuCardScaleProvider);
    final viewMode = ref.watch(cardViewModeProvider);
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
                    cardScale: cardScale,
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
                          cardScale,
                          viewMode,
                        ),

                        // Tab 2: Sealed Products
                        _buildProductsTab(
                          theme,
                          colorScheme,
                          strings,
                          exchangeRate,
                          isEn,
                          cardScale,
                          viewMode,
                        ),
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
    double cardScale,
    CardViewMode viewMode,
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

        // Grid or List of Cards
        Expanded(
          child: filteredCards.isEmpty
              ? AppEmptyState(
                  icon: Icons.search_off,
                  title: isEn ? 'No cards found' : 'Nenhuma carta encontrada',
                  message: _searchQuery.isNotEmpty
                      ? (isEn ? 'Try adjusting your search term' : 'Tente ajustar o termo da busca')
                      : null,
                )
              : viewMode == CardViewMode.list
                  ? _buildCardsListView(filteredCards, userCards, exchangeRate)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = resolveCardGridCrossAxisCount(
                          context: context,
                          ref: ref,
                          availableWidth: constraints.maxWidth,
                          cardScale: cardScale,
                        );

                        // Scale grows the whole tile (art + text) by increasing the
                        // card's height so content fills the tile without clipping.
                        final adjustedAspect =
                            (AppConstants.cardGridItemAspectRatio * (1.15 / cardScale))
                                .clamp(0.55, 1.2)
                                .toDouble();

                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: adjustedAspect,
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

  Widget _buildCardsListView(
    List<PokemonCardItem> cards,
    List<UserCard> userCards,
    double exchangeRate,
  ) {
    final currency = ref.watch(currencyProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: cards.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final card = cards[index];
        final title = SemanticSearchHelper.formatCardIdentifier(
          rawName: card.name,
          number: card.number,
          setTotal: card.setTotal,
        );
        final priceText = CurrencyFormatter.formatCardPrice(
          usdValue: card.effectiveMidPriceUsd,
          exchangeRate: exchangeRate,
          currency: currency,
        );
        final isOwned = SetCompletionHelper.isCardOwned(userCards, card);

        return ListTile(
          dense: true,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              PokemonCardImage(
                imageUrl: card.imageUrlSmall,
                fallbackImageUrl: card.imageUrlLarge,
                width: 42,
                height: 58,
                fit: BoxFit.contain,
              ),
              if (isOwned)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.profitGreen,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${card.setName} • ${card.rarity}',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            priceText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.profitGreen,
            ),
          ),
          onTap: () => AppNavigator.toCardDetails(context, card),
        );
      },
    );
  }

  Widget _buildProductsTab(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
    double exchangeRate,
    bool isEn,
    double cardScale,
    CardViewMode viewMode,
  ) {
    if (_products.isEmpty) {
      return AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: isEn ? 'No sealed products listed' : 'Nenhum produto selado disponível',
      );
    }

    final currency = ref.watch(currencyProvider);

    if (viewMode == CardViewMode.list) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = resolveCardGridCrossAxisCount(
          context: context,
          ref: ref,
          availableWidth: constraints.maxWidth,
          cardScale: cardScale,
        );

        // Scale grows the product tile so the change is visible even when the
        // column count stays the same on small widths.
        final adjustedAspect = (0.82 * (1.15 / cardScale)).clamp(0.62, 1.15).toDouble();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: adjustedAspect,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return _ProductGridTile(
              product: _products[index],
              exchangeRate: exchangeRate,
              currency: currency,
              isEn: isEn,
            );
          },
        );
      },
    );
  }
}

class _ProductGridTile extends StatelessWidget {
  final SetProductItem product;
  final double exchangeRate;
  final AppCurrency currency;
  final bool isEn;

  const _ProductGridTile({
    required this.product,
    required this.exchangeRate,
    required this.currency,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final brlEstimated = product.msrpUsd != null ? product.msrpUsd! * exchangeRate : null;
    final isUsd = currency == AppCurrency.usd;
    final primaryText = product.msrpUsd == null
        ? 'TBA'
        : (isUsd
            ? CurrencyFormatter.toUsd(product.msrpUsd)
            : CurrencyFormatter.toBrl(brlEstimated));

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: AppNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(8),
                fallbackIcon: Icons.inventory_2_outlined,
                fallbackIconSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.name,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.productType,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Text(
              primaryText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}