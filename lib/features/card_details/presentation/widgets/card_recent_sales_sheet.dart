import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/theme/app_colors.dart';
import 'package:wurmdex/core/utils/marketplace_url_helper.dart';
import 'package:wurmdex/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/card_details/services/pricing_service.dart';

class CardRecentSalesSheet {
  static void show(
    BuildContext context, {
    required PokemonCardItem card,
    required CardPricesResult? prices,
    required bool isUsd,
    required AppStrings strings,
  }) {
    final allSales = prices?.recentSales ?? [];

    showAppModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        String selectedPlatform = isUsd ? 'TCGPlayer' : 'LigaPokémon';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSales = allSales.where((s) => s.platform == selectedPlatform).toList();
            final isTcg = selectedPlatform == 'TCGPlayer';

            double avgPrice = 0;
            double minPrice = 0;
            double maxPrice = 0;
            if (filteredSales.isNotEmpty) {
              final vals = filteredSales.map((s) => isTcg ? s.priceUsd : s.priceBrl).toList();
              avgPrice = vals.reduce((a, b) => a + b) / vals.length;
              minPrice = vals.reduce(math.min);
              maxPrice = vals.reduce(math.max);
            }

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BottomSheetDragHandle(),
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: AppColors.profitGreen, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.salesHistoryTitle,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              strings.salesHistorySubtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Platform selector: LigaPokemon (BRL) vs TCGPlayer (USD)
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'LigaPokémon',
                        label: Text('LigaPokémon (BRL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        icon: Icon(Icons.storefront, size: 16, color: Colors.blue),
                      ),
                      ButtonSegment(
                        value: 'TCGPlayer',
                        label: Text('TCGPlayer (USD)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        icon: Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.orange),
                      ),
                    ],
                    selected: {selectedPlatform},
                    onSelectionChanged: (set) {
                      setModalState(() {
                        selectedPlatform = set.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary stats row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isTcg ? Colors.orange : Colors.blue).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isTcg ? Colors.orange : Colors.blue).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _saleMetricItem(
                          strings.salesAveragePaid,
                          isTcg
                              ? '\$ ${avgPrice.toStringAsFixed(2).replaceAll('.', ',')}'
                              : 'R\$ ${avgPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          Colors.amber,
                        ),
                        _saleMetricItem(
                          strings.salesLowestPaid,
                          isTcg
                              ? '\$ ${minPrice.toStringAsFixed(2).replaceAll('.', ',')}'
                              : 'R\$ ${minPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          AppColors.profitGreen,
                        ),
                        _saleMetricItem(
                          strings.salesHighestPaid,
                          isTcg
                              ? '\$ ${maxPrice.toStringAsFixed(2).replaceAll('.', ',')}'
                              : 'R\$ ${maxPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          Colors.redAccent,
                        ),
                        _saleMetricItem(
                          strings.salesTotalRecorded,
                          '${filteredSales.length}',
                          Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Completed sales records list
                  Flexible(
                    child: filteredSales.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Nenhuma compra registrada.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredSales.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = filteredSales[index];
                              final priceStr = isTcg
                                  ? '\$ ${item.priceUsd.toStringAsFixed(2).replaceAll('.', ',')}'
                                  : 'R\$ ${item.priceBrl.toStringAsFixed(2).replaceAll('.', ',')}';

                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.profitGreen.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 16, color: AppColors.profitGreen),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(item.date),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.variant,
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    const Text('Estado: ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text(
                                      item.condition,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  priceStr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.profitGreen,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: Text(strings.openSalesLiga, style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => MarketplaceUrlHelper.openLigaPokemon(
                            context,
                            cardName: card.name,
                            cardNumber: card.number,
                            setName: card.setName,
                            directUrl: prices?.ligaProductUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: Text(strings.openSalesTcg, style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => MarketplaceUrlHelper.openTcgPlayer(
                            context,
                            cardName: card.name,
                            cardNumber: card.number,
                            setName: card.setName,
                            productId: prices?.tcgProductId,
                            directUrl: prices?.tcgProductUrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _saleMetricItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
