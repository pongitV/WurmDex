import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/utils/card_sorting_helper.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/card_grid_skeleton.dart';
import '../../../core/widgets/card_sort_button.dart';
import '../../../core/widgets/grid_composition_button.dart';
import '../../../core/widgets/quick_currency_toggle.dart';
import '../../catalog/models/catalog_filter_state.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../../catalog/presentation/widgets/card_grid_item.dart';
import '../../catalog/services/pokemon_catalog_service.dart';
import '../models/pokedex_entry.dart';

class PokemonCardsGalleryScreen extends ConsumerStatefulWidget {
  final PokedexEntry pokemon;

  const PokemonCardsGalleryScreen({
    super.key,
    required this.pokemon,
  });

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
        title: Row(
          children: [
            Hero(
              tag: 'pokemon_art_${widget.pokemon.id}',
              child: AppNetworkImage(
                imageUrl: widget.pokemon.artworkUrl,
                fallbackImageUrl: widget.pokemon.spriteUrl,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                fallbackIcon: Icons.catching_pokemon,
                fallbackIconSize: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.pokemon.formattedNumber} ${widget.pokemon.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          const QuickCurrencyToggle(),
          GridCompositionButton(scaleTarget: CardScaleTarget.menu),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.btnTryAgain,
            onPressed: _loadData,
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
    if (_isLoading) {
      final crossAxisCount = resolveCardGridCrossAxisCount(
        context: context,
        ref: ref,
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

    final isEn = strings.isEn;
    final sortedCards = CardSortingHelper.sort(_cards, _sortOption);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_vintage,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${strings.pokedexCardsFor(widget.pokemon.name)} (${_cards.length})',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  CardSortButton(
                    currentOption: _sortOption,
                    isEn: isEn,
                    onSelected: (newOption) {
                      setState(() => _sortOption = newOption);
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = resolveCardGridCrossAxisCount(
                  context: context,
                  ref: ref,
                  availableWidth: constraints.crossAxisExtent,
                );

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: AppConstants.cardGridItemAspectRatio,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final card = sortedCards[index];
                      return CardGridItem(
                        card: card,
                        exchangeRate: exchangeRate,
                      );
                    },
                    childCount: sortedCards.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
