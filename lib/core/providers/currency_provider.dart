import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../network/currency_service.dart';

enum AppCurrency {
  usd,
  brl,
}

class CurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() {
    // Default currency is USD
    return AppCurrency.usd;
  }

  void toggleCurrency() {
    state = state == AppCurrency.usd ? AppCurrency.brl : AppCurrency.usd;
  }

  void setCurrency(AppCurrency currency) {
    state = currency;
  }

  bool get isUsd => state == AppCurrency.usd;
  bool get isBrl => state == AppCurrency.brl;
}

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(CurrencyNotifier.new);

class ExchangeRateNotifier extends Notifier<double> {
  @override
  double build() {
    // Avoid triggering unmocked background HTTP requests during widget/unit tests
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _fetchLiveRate();
    }
    return AppConstants.defaultUsdToBrlRate;
  }

  Future<void> refreshRate() async => _fetchLiveRate();

  Future<void> _fetchLiveRate() async {
    try {
      final rate = await CurrencyService.getUsdToBrlRate();
      if (rate > 0) {
        state = rate;
      }
    } catch (_) {}
  }
}

final exchangeRateProvider =
    NotifierProvider<ExchangeRateNotifier, double>(ExchangeRateNotifier.new);

