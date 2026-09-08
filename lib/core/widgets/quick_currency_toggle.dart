import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../providers/currency_provider.dart';

class QuickCurrencyToggle extends ConsumerWidget {
  final bool compact;

  const QuickCurrencyToggle({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final language = ref.watch(languageProvider);
    final isEn = language == AppLanguage.enUs;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUsd = currency == AppCurrency.usd;
    final label = isUsd ? 'USD (\$)' : 'BRL (R\$)';
    final tooltip = isUsd
        ? (isEn ? 'Switch currency to BRL (R\$)' : 'Mudar moeda para Real (R\$)')
        : (isEn ? 'Switch currency to USD (\$)' : 'Mudar moeda para Dólar (\$)');

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(currencyProvider.notifier).toggleCurrency();
        final newCurrency = ref.read(currencyProvider);
        final msg = newCurrency == AppCurrency.usd
            ? (isEn ? 'Currency changed to USD (\$) - Updating prices' : 'Moeda alterada para USD (\$) - Atualizando precos')
            : (isEn ? 'Currency changed to BRL (R\$) - Updating prices' : 'Moeda alterada para BRL (R\$) - Atualizando precos');

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.currency_exchange, size: 16, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  msg,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.primaryContainer,
            duration: const Duration(milliseconds: 1400),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.currency_exchange,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
