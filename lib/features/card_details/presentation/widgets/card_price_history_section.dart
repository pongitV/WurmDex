import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/theme/app_colors.dart';
import 'package:wurmdex/features/card_details/services/pricing_service.dart';

/// Which marketplace the chart is displaying.
enum CardChartSource { liga, tcg }

class CardPriceHistorySection extends StatefulWidget {
  final CardPricesResult? prices;
  final bool isUsd;
  final AppStrings strings;

  const CardPriceHistorySection({
    super.key,
    required this.prices,
    required this.isUsd,
    required this.strings,
  });

  @override
  State<CardPriceHistorySection> createState() => _CardPriceHistorySectionState();
}

class _CardPriceHistorySectionState extends State<CardPriceHistorySection> {
  PriceTimeRange _selectedRange = PriceTimeRange.month1m;
  late CardChartSource _source;

  @override
  void initState() {
    super.initState();
    _source = widget.isUsd ? CardChartSource.tcg : CardChartSource.liga;
  }

  Color _sourceColor(ThemeData theme) {
    return _source == CardChartSource.liga ? theme.colorScheme.primary : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;
    final isLiga = _source == CardChartSource.liga;

    final historyMap = widget.prices?.historyByRange ?? {};
    final currentPoints = historyMap[_selectedRange] ?? widget.prices?.historyPoints ?? [];

    if (currentPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final pricesList =
        currentPoints.map((p) => isLiga ? p.priceBrl : p.priceUsd).toList();
    final double rawMin = pricesList.reduce((a, b) => a < b ? a : b);
    final double rawMax = pricesList.reduce((a, b) => a > b ? a : b);
    final double chartMinY = (rawMin * 0.92).clamp(0.0, 999999.0);
    final double chartMaxY = (rawMax * 1.08).clamp(0.1, 999999.0);

    final spots = <FlSpot>[];
    for (int i = 0; i < currentPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), pricesList[i]));
    }

    final accent = _sourceColor(theme);
    final currencySymbol = isLiga ? 'R\$' : '\$';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 18,
                  color: isLiga ? AppColors.profitGreen : Colors.amberAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.priceHistory30Days,
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.bold,
                      color: isLiga ? null : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Time range dropdown (compact, never overflows the screen)
                DropdownButtonHideUnderline(
                  child: DropdownButton<PriceTimeRange>(
                    value: _selectedRange,
                    borderRadius: BorderRadius.circular(10),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: PriceTimeRange.week1w,
                        child: Text(strings.timeRangeWeek),
                      ),
                      DropdownMenuItem(
                        value: PriceTimeRange.month1m,
                        child: Text(strings.timeRangeMonth),
                      ),
                      DropdownMenuItem(
                        value: PriceTimeRange.year1y,
                        child: Text(strings.timeRangeYear),
                      ),
                      DropdownMenuItem(
                        value: PriceTimeRange.allTime,
                        child: Text(strings.timeRangeAll),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRange = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Platform toggle: LigaPokémon (BRL) vs TCGPlayer (USD)
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<CardChartSource>(
                segments: const [
                  ButtonSegment(
                    value: CardChartSource.liga,
                    label: Text('LigaPokémon', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.storefront, size: 16),
                  ),
                  ButtonSegment(
                    value: CardChartSource.tcg,
                    label: Text('TCGPlayer', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.store, size: 16),
                  ),
                ],
                selected: {_source},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setState(() => _source = selection.first);
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableW = constraints.maxWidth;
                final idealW = math.max(availableW, math.min(currentPoints.length * 24.0, 720.0));
                final isScrollable = idealW > availableW;
                final maxLabels = (idealW / 65).floor().clamp(3, 8);
                final double intervalX = math.max(1.0, (currentPoints.length / maxLabels).ceilToDouble());

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isScrollable)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.swipe, size: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                            const SizedBox(width: 4),
                            Text(
                              strings.isEn ? 'Slide to view history' : 'Deslize para ver histórico',
                              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: idealW,
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minY: chartMinY,
                            maxY: chartMaxY,
                            clipData: const FlClipData.all(),
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final formattedPrice =
                                        '$currencySymbol ${spot.y.toStringAsFixed(2).replaceAll('.', ',')}';
                                    final dateIndex = spot.x.toInt();
                                    String dateText = '';
                                    if (dateIndex >= 0 && dateIndex < currentPoints.length) {
                                      dateText = DateFormat('dd/MM/yyyy').format(currentPoints[dateIndex].date);
                                    }
                                    return LineTooltipItem(
                                      dateText.isNotEmpty ? '$dateText\n$formattedPrice' : formattedPrice,
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.5,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: (chartMaxY - chartMinY) > 0 ? (chartMaxY - chartMinY) / 4 : 1.0,
                              getDrawingHorizontalLine: (val) => FlLine(
                                color: theme.dividerColor.withValues(alpha: 0.2),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 58,
                                  getTitlesWidget: (val, meta) {
                                    if (val == meta.min || val == meta.max) {
                                      return const SizedBox.shrink();
                                    }
                                    final formatted = val.toStringAsFixed(2).replaceAll('.', ',');
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 6,
                                      child: Text(
                                        '$currencySymbol$formatted',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: intervalX,
                                  getTitlesWidget: (val, meta) {
                                    final index = val.toInt();
                                    if (index >= 0 && index < currentPoints.length && (val - index).abs() < 0.01) {
                                      final date = currentPoints[index].date;
                                      final String label;
                                      if (_selectedRange == PriceTimeRange.year1y || _selectedRange == PriceTimeRange.allTime) {
                                        label = DateFormat('MM/yy').format(date);
                                      } else {
                                        label = DateFormat('dd/MM').format(date);
                                      }
                                      return SideTitleWidget(
                                        meta: meta,
                                        space: 6,
                                        child: Text(
                                          label,
                                          style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                preventCurveOverShooting: true,
                                color: accent,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: accent.withValues(alpha: 0.15),
                                ),
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                    radius: 3,
                                    color: accent,
                                    strokeWidth: 1.5,
                                    strokeColor: theme.cardColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}