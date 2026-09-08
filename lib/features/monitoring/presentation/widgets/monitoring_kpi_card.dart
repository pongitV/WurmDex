import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class MonitoringKpiCard extends StatelessWidget {
  final double totalInvestedBrl;
  final double totalCurrentValueBrl;
  final double exchangeRate;
  final AppCurrency currency;
  final AppStrings strings;
  final int totalCards;
  final int surgingCount;
  final int droppingCount;

  const MonitoringKpiCard({
    super.key,
    required this.totalInvestedBrl,
    required this.totalCurrentValueBrl,
    required this.exchangeRate,
    required this.currency,
    required this.strings,
    required this.totalCards,
    required this.surgingCount,
    required this.droppingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUsd = currency == AppCurrency.usd;
    final rate = exchangeRate > 0 ? exchangeRate : 5.60;

    final double profitLossBrl = totalCurrentValueBrl - totalInvestedBrl;
    final double profitLossPct = totalInvestedBrl > 0
        ? ((profitLossBrl / totalInvestedBrl) * 100)
        : 0.0;
    final bool isProfit = profitLossBrl >= 0;

    final investedFormatted = isUsd
        ? CurrencyFormatter.toUsd(totalInvestedBrl / rate)
        : CurrencyFormatter.toBrl(totalInvestedBrl);

    final currentFormatted = isUsd
        ? CurrencyFormatter.toUsd(totalCurrentValueBrl / rate)
        : CurrencyFormatter.toBrl(totalCurrentValueBrl);

    final profitLossFormatted = isUsd
        ? CurrencyFormatter.toUsd(profitLossBrl.abs() / rate)
        : CurrencyFormatter.toBrl(profitLossBrl.abs());

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Total Invested
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.kpiTotalInvested.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        investedFormatted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Current Market Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.kpiCurrentValue.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentFormatted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Net Result & ROI
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        strings.kpiNetProfit.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isProfit ? Icons.trending_up : Icons.trending_down,
                            size: 16,
                            color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${isProfit ? '+' : '-'}$profitLossFormatted (${isProfit ? '+' : ''}${profitLossPct.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isProfit ? AppColors.profitGreen : AppColors.lossRed,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Bottom stats badges: Total cards, Surging, Dropping
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalCards ${strings.txtCardsCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.profitGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '▲ $surgingCount em alta',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.profitGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lossRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '▼ $droppingCount em baixa',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lossRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
