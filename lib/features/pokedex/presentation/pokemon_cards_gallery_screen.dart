import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/utils/card_sorting_helper.dart';
import '../../../core/utils/semantic_search_helper.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/card_grid_skeleton.dart';
import '../../../core/widgets/card_sort_button.dart';
import '../../catalog/models/catalog_filter_state.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../../catalog/presentation/widgets/card_grid_item.dart';
import '../../catalog/presentation/widgets/card_quick_action_sheet.dart';
import '../../catalog/services/pokemon_catalog_service.dart';
import '../models/pokedex_entry.dart';
import '../models/pokemon_cards_filter.dart';
import 'widgets/pokemon_cards_filter_bottom_sheet.dart';

class PokemonCardsGalleryScreen extends ConsumerStatefulWidget {
  final PokedexEntry pokemon;

  const PokemonCardsGalleryScreen({super.key, required this.pokemon});

  @override
  ConsumerState<PokemonCardsGalleryScreen> createState() =>
      _PokemonCardsGalleryScreenState();
}

class _PokemonCardsGalleryScreenState
    extends ConsumerState<PokemonCardsGalleryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<PokemonCardItem> _cards = [];
  CatalogSortOption _sortOption = CatalogSortOption.popularityDesc;
  PokemonCardsFilter _filter = const PokemonCardsFilter();

  List<String> get _availableSets =>
      _cards.map((c) => c.setName).where((s) => s.isNotEmpty).toSet().toList()
        ..sort();

  List<String> get _availableLanguages =>
      _cards.map((c) => c.language).where((s) => s.isNotEmpty).toSet().toList()
        ..sort();

  List<String> get _availableTypes =>
      _cards.expand((c) => c.types).where((s) => s.isNotEmpty).toSet().toList()
        ..sort();

  List<PokemonCardItem> get _filteredCards {
    var list = List<PokemonCardItem>.of(_cards);
    if (_filter.selectedSet != null) {
      list = list.where((c) => c.setName == _filter.selectedSet).toList();
    }
    if (_filter.selectedLanguage != null) {
      final lang = _filter.selectedLanguage!.toLowerCase();
      list = list.where((c) => c.language.toLowerCase() == lang).toList();
    }
    if (_filter.selectedType != null) {
      final t = _filter.selectedType!.toLowerCase();
      list = list.where((c) {
        final typesMatch = c.types.any((type) => type.toLowerCase() == t);
        final supertypeMatch = c.supertype.toLowerCase() == t;
        return typesMatch || supertypeMatch;
      }).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isEn = ref.read(languageProvider) == AppLanguage.enUs;
      final cards = await PokemonCatalogService.searchCards(
        query: widget.pokemon.name,
        isEn: isEn,
      );
      final cleanCards = cards.where((c) => !c.isDigital).toList();

      if (mounted) {
        setState(() {
          _cards = cleanCards;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLanguage = ref.watch(languageProvider);
    final strings = getStrings(currentLanguage);
    final exchangeRate = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          IconButton.filledTonal(
            icon: Badge(
              isLabelVisible: _filter.hasActiveFilters,
              label: Text('${_filter.activeFilterCount}'),
              child: const Icon(Icons.tune, size: 20),
            ),
            tooltip: strings.filtersAndMore,
            onPressed: () {
              showPokemonCardsFilterBottomSheet(
                context,
                currentFilter: _filter,
                sets: _availableSets,
                languages: _availableLanguages,
                types: _availableTypes,
                strings: strings,
                onApply: (newFilter) {
                  setState(() => _filter = newFilter);
                },
              );
            },
          ),
          const SizedBox(width: 4),
          CardSortButton(
            currentOption: _sortOption,
            isEn: strings.isEn,
            onSelected: (newOption) {
              setState(() => _sortOption = newOption);
            },
          ),
          AppOverflowMenu(
            scaleTarget: CardScaleTarget.menu,
            showCurrency: true,
            showRefresh: true,
            onRefresh: _loadData,
          ),
        ],
      ),
      body: _buildBody(theme, colorScheme, strings, exchangeRate),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
    double exchangeRate,
  ) {
    // Watch during build so the grid responds to scale/grid changes.
    final cardScale = ref.watch(menuCardScaleProvider);
    ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);
    // Scale grows the whole tile (photo + text) by increasing the card's height.
    // Keeps the default 0.58 ratio at the default scale (1.15).
    final adjustedAspect =
        (AppConstants.cardGridItemAspectRatio * (1.15 / cardScale))
            .clamp(0.55, 1.2)
            .toDouble();
    // Bigger artwork that also responds to the card scale.
    final artSize = (130.0 * cardScale).clamp(110.0, 220.0).toDouble();

    if (_isLoading) {
      final crossAxisCount = resolveCardGridCrossAxisCount(
        context: context,
        ref: ref,
        cardScale: cardScale,
      );
      return CardGridSkeleton(
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.all(16),
      );
    }

    if (_errorMessage != null) {
      return AppEmptyState(
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        title: strings.errorLoadingNews,
        buttonLabel: strings.btnTryAgain,
        buttonIcon: Icons.refresh,
        onAction: _loadData,
      );
    }

    if (_cards.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off,
        title: strings.noCardsFound,
        message: strings.pokedexCardsFor(widget.pokemon.name),
      );
    }

    final displayCards = CardSortingHelper.sort(_filteredCards, _sortOption);
    final hasFilters = _filter.hasActiveFilters;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'pokemon_art_${widget.pokemon.id}',
                    child: AppNetworkImage(
                      imageUrl: widget.pokemon.artworkUrl,
                      fallbackImageUrl: widget.pokemon.spriteUrl,
                      width: artSize,
                      height: artSize,
                      fit: BoxFit.contain,
                      fallbackIcon: Icons.catching_pokemon,
                      fallbackIconSize: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.pokemon.formattedNumber} ${widget.pokemon.name}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.cardsCount(_cards.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: _buildActiveFilterChips(theme, strings),
              ),
            ),
          if (displayCards.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppEmptyState(
                  icon: Icons.filter_alt_off,
                  title: strings.noFilterMatch,
                  buttonLabel: strings.btnClearFilters,
                  buttonIcon: Icons.filter_alt,
                  onAction: () {
                    setState(() => _filter = const PokemonCardsFilter());
                  },
                ),
              ),
            )
          else if (viewMode == CardViewMode.list)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList.separated(
                itemCount: displayCards.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final card = displayCards[index];
                  final title = SemanticSearchHelper.formatCardIdentifier(
                    rawName: card.name,
                    number: card.number,
                    setTotal: card.setTotal,
                  );
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: AppNetworkImage(
                      imageUrl: card.imageUrlSmall,
                      fallbackImageUrl: card.imageUrlLarge,
                      width: 40,
                      height: 56,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.circular(4),
                      fallbackIcon: Icons.style_outlined,
                      fallbackIconSize: 24,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${card.setName} • ${card.rarity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    onTap: () => AppNavigator.toCardDetails(context, card),
                    onLongPress: () => CardQuickActionSheet.show(context, card),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = resolveCardGridCrossAxisCount(
                    context: context,
                    ref: ref,
                    availableWidth: constraints.crossAxisExtent,
                    cardScale: cardScale,
                  );

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: adjustedAspect,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final card = displayCards[index];
                      return CardGridItem(
                        card: card,
                        exchangeRate: exchangeRate,
                        showPrice: false,
                      );
                    }, childCount: displayCards.length),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(ThemeData theme, AppStrings strings) {
    final chips = <Widget>[];
    if (_filter.selectedSet != null) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            label: Text(
              '${strings.filterByCollection}: ${_filter.selectedSet}',
            ),
            onDeleted: () =>
                setState(() => _filter = _filter.copyWith(clearSet: true)),
          ),
        ),
      );
    }
    if (_filter.selectedLanguage != null) {
      final langLabel = strings.languageDisplayName(_filter.selectedLanguage!);
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            label: Text('${strings.languageLabel}: $langLabel'),
            onDeleted: () =>
                setState(() => _filter = _filter.copyWith(clearLanguage: true)),
          ),
        ),
      );
    }
    if (_filter.selectedType != null) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InputChip(
            label: Text('${strings.filterByType}: ${_filter.selectedType}'),
            onDeleted: () =>
                setState(() => _filter = _filter.copyWith(clearType: true)),
          ),
        ),
      );
    }
    chips.add(
      TextButton.icon(
        icon: const Icon(Icons.close, size: 16),
        label: Text(
          strings.btnClearFilters,
          style: const TextStyle(fontSize: 11),
        ),
        onPressed: () => setState(() => _filter = const PokemonCardsFilter()),
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
  }
}
