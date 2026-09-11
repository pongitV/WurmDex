import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../monitoring/services/price_monitoring_service.dart';
import 'top_cards_widget.dart';

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
      totalInvestedBrl += (card.purchasePriceBrl * qty);

      final item = monitoredItems[i];
      estimatedCurrentValueBrl += (item.estimatedCurrentPriceBrl * qty);

      final finishKey = card.finish.isNotEmpty ? card.finish : 'Regular';
      finishCounts[finishKey] = (finishCounts[finishKey] ?? 0) + qty;

      final langKey = card.language.isNotEmpty ? card.language : 'PT';
      languageCounts[langKey] = (languageCounts[langKey] ?? 0) + qty;
    }

    final double profitLossBrl = estimatedCurrentValueBrl - totalInvestedBrl;
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
    final topMonitored = sortedMonitored.take(10).toList();

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
                    subtitle: isProfit ? strings.profitText : strings.lossText,
                    icon: isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                    iconColor: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                    textColor: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Price Monitor & Currency buttons below the metrics
            Row(
              children: [
                Expanded(
                  child: _buildPriceMonitorButton(context, strings),
                ),
                const SizedBox(width: 10),
                _buildCurrencyComparisonChip(context, ref, strings),
              ],
            ),

            // Top 10 Most Valuable Cards Section
            if (topMonitored.isNotEmpty) ...[
              TopCardsWidget(
                topMonitored: topMonitored,
                isUsd: isUsd,
                effectiveRate: effectiveRate,
                strings: strings,
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
Widget _buildPriceMonitorButton(BuildContext context, AppStrings strings) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppNavigator.toPriceMonitoring(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 34,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  strings.priceMonitor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildCurrencyComparisonChip(BuildContext context, WidgetRef ref, AppStrings strings) {
    final theme = Theme.of(context);
    final isUsd = ref.watch(currencyProvider) == AppCurrency.usd;
    final rate = ref.watch(exchangeRateProvider);
    final primary = theme.colorScheme.primary;

    final String brlText;
    final String usdText;
    if (isUsd) {
      brlText = rate.toStringAsFixed(2);
      usdText = '1,00';
    } else {
      brlText = '1,00';
      usdText = (1 / rate).toStringAsFixed(2);
    }

    return ActionChip(
      avatar: const Icon(Icons.currency_exchange, size: 16),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'R\$ $brlText',
              style: TextStyle(
                fontWeight: isUsd ? FontWeight.normal : FontWeight.bold,
                color: isUsd ? null : primary,
              ),
            ),
            const TextSpan(text: ' = '),
            TextSpan(
              text: 'US\$ $usdText',
              style: TextStyle(
                fontWeight: isUsd ? FontWeight.bold : FontWeight.normal,
                color: isUsd ? primary : null,
              ),
            ),
          ],
        ),
      ),
      tooltip: isUsd ? strings.switchToBrl : strings.switchToUsd,
      onPressed: () => ref.read(currencyProvider.notifier).toggleCurrency(),
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

