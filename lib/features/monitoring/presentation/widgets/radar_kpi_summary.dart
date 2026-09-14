import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/kpi_stat_card.dart';
import '../../../../core/widgets/kpi_value_banner.dart';

/// KPI summary for LigaRadar:
/// 1. Valor total → shown as a full-width rectangular banner on top
/// 2. In Range (count of monitored items within price limits)
/// 3. Atualizados hoje (products/cards checked today)
/// 4. Quantidade de produtos (total number of monitored products)
class RadarKpiSummary extends StatelessWidget {
  final int totalInRange;
  final double totalPrice;
  final int updatedToday;
  final int totalProducts;
  final bool isInRangeSelected;
  final bool isProductsSelected;
  final VoidCallback onToggleInRange;
  final VoidCallback onToggleProducts;
  final bool isUsd;
  final double exchangeRate;
  final AppStrings strings;

  const RadarKpiSummary({
    super.key,
    required this.totalInRange,
    required this.totalPrice,
    required this.updatedToday,
    required this.totalProducts,
    required this.isInRangeSelected,
    this.isProductsSelected = false,
    required this.onToggleInRange,
    required this.onToggleProducts,
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
                  value: '$totalInRange',
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
                  label: strings.kpiQuantityProducts,
                  value: '$totalProducts',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.orange,
                  selected: isProductsSelected,
                  onTap: onToggleProducts,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}