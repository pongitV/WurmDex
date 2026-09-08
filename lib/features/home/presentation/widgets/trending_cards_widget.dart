import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../catalog/models/pokemon_card_item.dart';
import '../../services/home_feed_service.dart';

enum TrendingSource {
  ligaPokemon,
  tcgPlayer,
}

class TrendingCardsWidget extends ConsumerStatefulWidget {
  final double exchangeRate;

  const TrendingCardsWidget({
    super.key,
    this.exchangeRate = AppConstants.defaultUsdToBrlRate,
  });

  @override
  ConsumerState<TrendingCardsWidget> createState() => _TrendingCardsWidgetState();
}

class _TrendingCardsWidgetState extends ConsumerState<TrendingCardsWidget> {
  TrendingSource _source = TrendingSource.ligaPokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLiga = _source == TrendingSource.ligaPokemon;
    final trending = isLiga
        ? HomeFeedService.getLigaPokemonTrendingCards()
        : HomeFeedService.getTcgPlayerTrendingCards();
    final menuScale = ref.watch(menuCardScaleProvider);
    final currency = ref.watch(currencyProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    final cardWidth = (230.0 * menuScale).clamp(190.0, 420.0);
    final cardHeight = cardWidth / (63.0 / 88.0);
    final listHeight = cardHeight + 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.sectionTrending,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLiga
                          ? (strings.isEn ? 'LigaPokémon Market (BR)' : 'Mercado LigaPokémon (BR)')
                          : (strings.isEn ? 'TCGPlayer Market (Global)' : 'Mercado TCGPlayer (Global)'),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Segmented market selector
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _marketPill(
                      title: 'LigaPokémon',
                      badge: 'BRL',
                      isSelected: isLiga,
                      accentColor: const Color(0xFF10B981),
                      onTap: () => setState(() => _source = TrendingSource.ligaPokemon),
                    ),
                    const SizedBox(width: 4),
                    _marketPill(
                      title: 'TCGPlayer',
                      badge: 'USD',
                      isSelected: !isLiga,
                      accentColor: Colors.orange,
                      onTap: () => setState(() => _source = TrendingSource.tcgPlayer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            key: ValueKey(_source),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: trending.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final card = trending[index];
              return _buildTrendingCard(context, card, theme, cardWidth, cardHeight, currency, exchangeRate);
            },
          ),
        ),
      ],
    );
  }

  Widget _marketPill({
    required String title,
    required String badge,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isSelected ? Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? accentColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(
    BuildContext context,
    PokemonCardItem card,
    ThemeData theme,
    double cardWidth,
    double cardHeight,
    AppCurrency currency,
    double exchangeRate,
  ) {
    final title = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
      setTotal: card.setTotal,
    );
    final effectivePrice = card.effectiveMidPriceUsd ?? card.tcgMarketUsd;
    final brlEstimated = effectivePrice != null ? (effectivePrice * exchangeRate) : null;
    final imageUrl = card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall;
    final isUsd = currency == AppCurrency.usd;
    final primaryPriceText = isUsd
        ? CurrencyFormatter.toUsd(effectivePrice)
        : CurrencyFormatter.toBrl(brlEstimated);
    final secondaryPriceText = isUsd
        ? (brlEstimated != null ? '~ ${CurrencyFormatter.toBrl(brlEstimated)}' : null)
        : (effectivePrice != null ? '~ ${CurrencyFormatter.toUsd(effectivePrice)}' : null);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        onTap: () {
          AppNavigator.toCardDetails(context, card);
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full Card Image - Complete, without cutting
              PokemonCardImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),

              // Gradient shading overlay behind the text
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 18, 10, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                          shadows: [
                            Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.setName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                          shadows: const [
                            Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.profitGreen.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.profitGreen.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              primaryPriceText,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.profitGreen,
                              ),
                            ),
                          ),
                          if (secondaryPriceText != null)
                            Text(
                              secondaryPriceText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.75),
                                shadows: const [
                                  Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
