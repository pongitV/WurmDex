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
}
