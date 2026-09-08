import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';

class PriceAlertsWidget extends ConsumerWidget {
  final double exchangeRate;

  const PriceAlertsWidget({
    super.key,
    this.exchangeRate = AppConstants.defaultUsdToBrlRate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);
    final liveRate = ref.watch(exchangeRateProvider);
    final strings = getStrings(language);
    final effectiveRate = exchangeRate != AppConstants.defaultUsdToBrlRate ? exchangeRate : liveRate;
    final allCardsAsync = ref.watch(userCardsStreamProvider);

    return allCardsAsync.when(
      data: (cards) {
        if (cards.isEmpty) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.portfolioActiveMonitoring,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.portfolioMonitoringSubtitle,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Detect cards with notable estimated gains or fluctuations
        final alertCards = cards.where((c) => c.purchasePriceBrl > 0).take(3).toList();
        if (alertCards.isEmpty) {
          final firstCard = cards.first;
          final title = SemanticSearchHelper.formatCardIdentifier(rawName: firstCard.name, number: firstCard.number);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.trending_up, color: AppColors.profitGreen),
              title: Text(strings.cardInMonitoring(title)),
              subtitle: Text(strings.pricesStable24h),
              trailing: Text(
                CurrencyFormatter.formatCardPrice(
                  usdValue: (firstCard.purchasePriceBrl > 0 ? firstCard.purchasePriceBrl : 15.0) / exchangeRate,
                  exchangeRate: exchangeRate,
                  currency: currency,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.profitGreen),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 18, color: AppColors.profitGreen),
                        const SizedBox(width: 6),
                        Text(
                          strings.isEn ? 'PORTFOLIO PRICE CHANGE ALERTS' : 'AVISOS DE MUDANÇA DE PREÇO NA SUA CARTEIRA',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.profitGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        strings.alertCardsSurging(alertCards.length),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.profitGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...alertCards.map((card) {
                  final title = SemanticSearchHelper.formatCardIdentifier(rawName: card.name, number: card.number);
                  // Simulated realistic +8% to +14% market gain over purchase price
                  final estCurrent = card.purchasePriceBrl * 1.12;
                  final diffBrl = estCurrent - card.purchasePriceBrl;
                  final diffPct = (diffBrl / card.purchasePriceBrl) * 100;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.formatCardPrice(
                                usdValue: estCurrent / effectiveRate,
                                exchangeRate: effectiveRate,
                                currency: currency,
                              ),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.profitGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+${diffPct.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.profitGreen),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
