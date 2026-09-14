import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/kpi_stat_card.dart';
import '../../../../core/widgets/kpi_value_banner.dart';

/// KPI summary for Wishlist:
/// 1. Preço total → shown as a full-width rectangular banner on top
/// 2. In Range (count of wishlist cards within target price)
/// 3. Atualizadas hoje (cards checked today)
/// 4. Quantidade de cartas (total number of cards in wishlist)
class WishlistKpiSummary extends StatelessWidget {
  final int inRangeCount;
  final double totalPrice;
  final int updatedToday;
  final int totalCards;
  final bool isInRangeSelected;
  final VoidCallback onToggleInRange;
  final bool isUsd;
  final double exchangeRate;
  final AppStrings strings;

  const WishlistKpiSummary({
    super.key,
    required this.inRangeCount,
    required this.totalPrice,
    required this.updatedToday,
    required this.totalCards,
    required this.isInRangeSelected,
    required this.onToggleInRange,
    required this.isUsd,
    required this.exchangeRate,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        children: [
          KpiValueBanner(
            label: strings.kpiTotalPrice,
            value: isUsd
                ? CurrencyFormatter.toUsd(totalPrice / exchangeRate)
                : CurrencyFormatter.toBrl(totalPrice),
            icon: Icons.payments_outlined,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: KpiStatCard(
                  label: strings.kpiInRangeTotal,
                  value: '$inRangeCount',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  selected: isInRangeSelected,
                  onTap: onToggleInRange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KpiStatCard(
                  label: strings.kpiUpdatedToday,
                  value: '$updatedToday',
                  icon: Icons.schedule,
                  color: theme.colorScheme.primary,
                  selected: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KpiStatCard(
                  label: strings.kpiQuantityCards,
                  value: '$totalCards',
                  icon: Icons.style_outlined,
                  color: Colors.orange,
                  selected: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}