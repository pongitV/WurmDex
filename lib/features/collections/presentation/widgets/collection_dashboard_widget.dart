import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../catalog/models/pokemon_card_item.dart';
import '../../../monitoring/services/price_monitoring_service.dart';

class CollectionDashboardWidget extends ConsumerWidget {
  final List<UserCard> cards;
  final double? exchangeRate;

  const CollectionDashboardWidget({
    super.key,
    required this.cards,
    this.exchangeRate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);
    final liveExchangeRate = ref.watch(exchangeRateProvider);
    final effectiveRate = exchangeRate ?? liveExchangeRate;
    final strings = getStrings(language);
    final isUsd = currency == AppCurrency.usd;

    int totalCount = 0;
    double totalInvestedBrl = 0.0;
    double estimatedCurrentValueBrl = 0.0;

    final Map<String, int> finishCounts = {};
    final Map<String, int> languageCounts = {};

    final monitoredItems = PriceMonitoringService.generateMonitoredItems(
      cards: cards,
      folders: const [],
    );

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final qty = card.quantity;
      totalCount += qty;
      totalInvestedBrl += (card.purchasePriceBrl * qty);

      final item = monitoredItems[i];
      estimatedCurrentValueBrl += (item.estimatedCurrentPriceBrl * qty);

      final finishKey = card.finish.isNotEmpty ? card.finish : 'Regular';
      finishCounts[finishKey] = (finishCounts[finishKey] ?? 0) + qty;

      final langKey = card.language.isNotEmpty ? card.language : 'PT';
      languageCounts[langKey] = (languageCounts[langKey] ?? 0) + qty;
    }

    final double profitLossBrl = estimatedCurrentValueBrl - totalInvestedBrl;
    final double profitLossPct = totalInvestedBrl > 0 ? ((profitLossBrl / totalInvestedBrl) * 100) : 0.0;
    final bool isProfit = profitLossBrl >= 0;

    // Dual currency calculations
    final currentValPrimary = isUsd
        ? CurrencyFormatter.toUsd(estimatedCurrentValueBrl / effectiveRate)
        : CurrencyFormatter.toBrl(estimatedCurrentValueBrl);
    final currentValSecondary = isUsd
        ? '~ ${CurrencyFormatter.toBrl(estimatedCurrentValueBrl)}'
        : '~ ${CurrencyFormatter.toUsd(estimatedCurrentValueBrl / effectiveRate)}';

    final investedValPrimary = isUsd
        ? CurrencyFormatter.toUsd(totalInvestedBrl / effectiveRate)
        : CurrencyFormatter.toBrl(totalInvestedBrl);
    final investedValSecondary = isUsd
        ? '~ ${CurrencyFormatter.toBrl(totalInvestedBrl)}'
        : '~ ${CurrencyFormatter.toUsd(totalInvestedBrl / effectiveRate)}';

    final profitLossPrimary = isUsd
        ? CurrencyFormatter.toUsd(profitLossBrl.abs() / effectiveRate)
        : CurrencyFormatter.toBrl(profitLossBrl.abs());

    // Sort Top 10 most valuable cards
    final sortedMonitored = List.of(monitoredItems)
      ..sort((a, b) => b.estimatedCurrentPriceBrl.compareTo(a.estimatedCurrentPriceBrl));
    final topCards = sortedMonitored.take(10).map((m) => m.card).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      strings.sectionPortfolioMetrics,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (totalCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '($totalCount ${strings.isEn ? "cards" : "cartas"})',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isProfit ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isProfit ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isProfit ? "+" : "-"}${profitLossPct.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => AppNavigator.toPriceMonitoring(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                strings.isEn ? 'Price Monitor' : 'Monitor de Preços',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Metrics Row (Invested, Current Value, Profit/Loss)
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: strings.labelInvested,
                    value: investedValPrimary,
                    subtitle: investedValSecondary,
                    icon: Icons.shopping_bag_outlined,
                    iconColor: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: strings.labelMarketValue,
                    value: currentValPrimary,
                    subtitle: currentValSecondary,
                    icon: Icons.trending_up,
                    iconColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: strings.labelProfitLoss,
                    value: '${isProfit ? "+" : "-"}$profitLossPrimary',
                    subtitle: isProfit ? '+ lucro' : '- perda',
                    icon: isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                    iconColor: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                    textColor: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                  ),
                ),
              ],
            ),

            // Top 10 Most Valuable Cards Section
            if (topCards.isNotEmpty) ...[
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
                    '${topCards.length} ${strings.isEn ? "cards" : "cartas"}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal list of top cards
              SizedBox(
                height: 124,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: topCards.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final card = topCards[index];
                    final rank = index + 1;
                    final cardPriceBrl = card.purchasePriceBrl > 0 ? card.purchasePriceBrl : 15.0;
                    final priceDisplay = isUsd
                        ? CurrencyFormatter.toUsd(cardPriceBrl / effectiveRate)
                        : CurrencyFormatter.toBrl(cardPriceBrl);

                    Color rankColor = theme.colorScheme.primary;
                    if (rank == 1) rankColor = Colors.amber.shade700;
                    if (rank == 2) rankColor = Colors.blueGrey;
                    if (rank == 3) rankColor = Colors.brown.shade400;

                    return InkWell(
                      onTap: () {
                        final catalogCard = PokemonCardItem(
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
                          tcgMarketUsd: cardPriceBrl / effectiveRate,
                        );
                        AppNavigator.toCardDetails(
                          context,
                          catalogCard,
                          userCardId: card.id,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 190,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: rank == 1
                                ? Colors.amber.withValues(alpha: 0.6)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: rank == 1 ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Card Thumbnail with Rank Overlay
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                PokemonCardImage(
                                  imageUrl: card.imageUrl,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.contain,
                                ),
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: rankColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '#$rank',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    card.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${card.setName} (${card.number})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      ConditionBadge(
                                        condition: card.condition,
                                        compact: true,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          priceDisplay,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.profitGreen,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${card.quantity}x',
                                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Finishes and languages badges
            if (finishCounts.isNotEmpty || languageCounts.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...finishCounts.entries.map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${e.key}: ${e.value}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      )),
                  ...languageCounts.entries.map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${e.key}: ${e.value}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? textColor;

  const _MetricCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: textColor ?? theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 9.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

