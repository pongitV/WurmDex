import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../providers/currency_provider.dart';

class CurrencyFormatter {
  static final NumberFormat _brlFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String toBrl(double? value) {
    if (value == null) return 'R\$ --';
    return _brlFormat.format(value);
  }

  static String toUsd(double? value) {
    if (value == null) return '\$ --';
    return _usdFormat.format(value);
  }

  static String formatPercent(double value) {
    final prefix = value >= 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  static String format(
    double? usdValue, {
    double? exchangeRate,
    AppCurrency currency = AppCurrency.usd,
  }) {
    if (usdValue == null || usdValue <= 0) {
      return currency == AppCurrency.brl ? 'R\$ --' : '\$ --';
    }

    if (currency == AppCurrency.usd) {
      return toUsd(usdValue);
    } else {
      final rate = exchangeRate ?? AppConstants.defaultUsdToBrlRate;
      return toBrl(usdValue * rate);
    }
  }

  static String formatCardPrice({
    double? usdValue,
    double? exchangeRate,
    AppCurrency currency = AppCurrency.usd,
  }) {
    return format(usdValue, exchangeRate: exchangeRate, currency: currency);
  }

  /// Universal currency parser that safely handles Brazilian (pt-BR) and international number formats
  /// e.g. "R$ 1.450,90", "1.450,90", "45,50", "$ 1,450.90", "12.50"
  static double? parseCurrency(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      var sanitized = trimmed
          .replaceAll('R\$', '')
          .replaceAll('r\$', '')
          .replaceAll('\$', '')
          .replaceAll(' ', '')
          .trim();

      if (sanitized.contains(',') && sanitized.contains('.')) {
        // e.g. 1.450,90 (BRL standard) vs 1,450.90 (US standard)
        final lastComma = sanitized.lastIndexOf(',');
        final lastDot = sanitized.lastIndexOf('.');
        if (lastComma > lastDot) {
          // BRL: dot is thousands, comma is decimal
          sanitized = sanitized.replaceAll('.', '').replaceAll(',', '.');
        } else {
          // US: comma is thousands, dot is decimal
          sanitized = sanitized.replaceAll(',', '');
        }
      } else if (sanitized.contains(',')) {
        // e.g. 45,50 -> 45.50
        sanitized = sanitized.replaceAll(',', '.');
      }

      return double.tryParse(sanitized);
    } catch (_) {
      return null;
    }
  }

  /// Convenience method that defaults to [defaultValue] (0.0) if parsing fails or input is empty
  static double parseCurrencyOrDefault(String? raw, [double defaultValue = 0.0]) {
    return parseCurrency(raw) ?? defaultValue;
  }
}
