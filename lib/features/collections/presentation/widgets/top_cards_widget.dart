import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../catalog/models/pokemon_card_item.dart';
import '../../../monitoring/models/monitored_card_item.dart';

double cardDisplayPriceBrl(MonitoredCardItem item) {
  return item.card.purchasePriceBrl > 0 ? item.card.purchasePriceBrl : 15.0;
}

String formatCardDisplayPrice(
  MonitoredCardItem item, {
  required bool isUsd,
  required double effectiveRate,
}) {
  final priceBrl = cardDisplayPriceBrl(item);
  return isUsd
      ? CurrencyFormatter.toUsd(priceBrl / effectiveRate)
      : CurrencyFormatter.toBrl(priceBrl);
}

PokemonCardItem userCardToCatalogCard(
  UserCard card,
  MonitoredCardItem item, {
  required double effectiveRate,
}) {
  final priceBrl = cardDisplayPriceBrl(item);
  return PokemonCardItem(
    id: card.cardApiId,
    name: card.name,
    number: card.number,
    setId: card.setName.toLowerCase().replaceAll(' ', '-'),
    setName: card.setName,
    rarity: card.rarity,
    imageUrlSmall: card.imageUrl,
    imageUrlLarge: card.imageUrl,
    types: const ['Colorless'],
    supertype: 'Pokémon',
    artist: '',
    tcgMarketUsd: priceBrl / effectiveRate,
  );
}

class TopCardsWidget extends StatelessWidget {
  final List<MonitoredCardItem> topMonitored;
  final bool isUsd;
  final double effectiveRate;
  final AppStrings strings;

  const TopCardsWidget({
    super.key,
    required this.topMonitored,
    required this.isUsd,
    required this.effectiveRate,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    if (topMonitored.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 6),
                Text(
                  strings.top10ValuableCards,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Text(
              strings.cardsCount(topMonitored.length),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTopOneCard(context, topMonitored.first),
      ],
    );
  }

  Widget _buildTopOneCard(BuildContext context, MonitoredCardItem item) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => AppNavigator.toTopCardsPodium(context, topMonitored: topMonitored),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.amber.shade600.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                PokemonCardImage(
                  imageUrl: item.card.imageUrl,
                  width: 86,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, size: 11, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          '#1',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.card.name,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.card.setName} (#${item.card.number})',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ConditionBadge(condition: item.card.condition, compact: true),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          formatCardDisplayPrice(item, isUsd: isUsd, effectiveRate: effectiveRate),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.profitGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.card.quantity}x',
                    style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.viewPodium,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
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