import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/constants/app_constants.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/core/theme/app_colors.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/core/utils/semantic_search_helper.dart';
import 'package:wurmdex/core/navigation/app_navigator.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/language_flag_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import 'card_quick_action_sheet.dart';

class CardGridItem extends ConsumerWidget {
  final PokemonCardItem card;
  final double? exchangeRate;
  final bool isOwned;
  final String? condition;
  final String? language;
  final Widget? topLeftBadge;
  final Widget? topRightBadge;
  final String? customPriceText;
  final bool showPrice;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CardGridItem({
    super.key,
    required this.card,
    this.exchangeRate,
    this.isOwned = false,
    this.condition,
    this.language,
    this.topLeftBadge,
    this.topRightBadge,
    this.customPriceText,
    this.showPrice = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final formattedTitle = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
      setTotal: card.setTotal,
    );

    final effectivePriceText = customPriceText ??
        CurrencyFormatter.formatCardPrice(
          usdValue: card.effectiveMidPriceUsd,
          exchangeRate: exchangeRate,
          currency: currency,
        );

    final effectiveLanguage = language != null && language!.isNotEmpty
        ? language!
        : (card.setName.toLowerCase().contains('japanese') ||
                card.setId.toLowerCase().contains('jp') ||
                RegExp(r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff]').hasMatch(card.name)
            ? 'JP'
            : (currency == AppCurrency.usd ? 'EN' : 'PT'));

    // Resolve top-left badge (custom or Master Set OK)
    Widget? effectiveTopLeft = topLeftBadge;
    if (effectiveTopLeft == null && isOwned) {
      effectiveTopLeft = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.profitGreen,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 10, color: Colors.white),
            SizedBox(width: 2),
            Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Resolve top-right badge (custom or more_vert quick action button)
    Widget? effectiveTopRight = topRightBadge;
    effectiveTopRight ??= Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onLongPress ?? () => CardQuickActionSheet.show(context, card),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.more_vert, size: 16, color: Colors.white),
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap ?? () => AppNavigator.toCardDetails(context, card),
      onLongPress: onLongPress ?? () => CardQuickActionSheet.show(context, card),
      onSecondaryTap: onLongPress ?? () => CardQuickActionSheet.show(context, card),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Image Container maintaining official 63:88 aspect ratio
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, left: 6, right: 6, bottom: 2),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: AppConstants.pokemonCardAspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        PokemonCardImage(
                          imageUrl: card.imageUrlSmall,
                          fallbackImageUrl: card.imageUrlLarge,
                          fit: BoxFit.contain,
                        ),
                        if (effectiveTopLeft != null)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: effectiveTopLeft,
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: effectiveTopRight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Card Details 3-tier layout:
            // 1. Nome e número encima
            // 2. Coleção no meio
            // 3. Qualidade, bandeira do país e preço(médio) embaixo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: theme.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Linha 1: Nome e número encima
                  Text(
                    formattedTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Linha 2: Coleção no meio
                  Text(
                    card.setName,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Linha 3: Qualidade, bandeira do país e preço(médio) embaixo
                  Row(
                    mainAxisAlignment: showPrice
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConditionBadge(
                            condition: condition ?? 'NM',
                            compact: true,
                          ),
                          const SizedBox(width: 4),
                          LanguageFlagBadge(
                            language: effectiveLanguage,
                            compact: true,
                          ),
                        ],
                      ),
                      if (showPrice)
                        Flexible(
                          child: Text(
                            effectivePriceText,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.profitGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
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
    );
  }
}
