import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/set_product_item.dart';

class SetProductCard extends ConsumerWidget {
  final SetProductItem product;
  final double exchangeRate;
  final bool isEn;

  const SetProductCard({
    super.key,
    required this.product,
    required this.exchangeRate,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = ref.watch(currencyProvider);

    final brlEstimated = product.msrpUsd != null ? product.msrpUsd! * exchangeRate : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image / photo container
                Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2_outlined,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title and Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.productType,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.packCount != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.layers_outlined, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${product.packCount} Booster Packs',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              product.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            // Price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MSRP / Preço Sugerido',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (product.msrpUsd != null)
                  Builder(
                    builder: (context) {
                      final isUsd = currency == AppCurrency.usd;
                      final primaryText = isUsd
                          ? CurrencyFormatter.toUsd(product.msrpUsd)
                          : CurrencyFormatter.toBrl(brlEstimated);
                      final secondaryText = isUsd
                          ? (brlEstimated != null ? '~ ${CurrencyFormatter.toBrl(brlEstimated)}' : null)
                          : '~ ${CurrencyFormatter.toUsd(product.msrpUsd)}';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            primaryText,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (secondaryText != null)
                            Text(
                              secondaryText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      );
                    },
                  )
                else
                  Text(
                    'TBA',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
