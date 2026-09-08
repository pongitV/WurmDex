import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'dio_client.dart';

class CurrencyService {
  static double _cachedExchangeRate = AppConstants.defaultUsdToBrlRate;
  static DateTime? _lastFetched;

  static Future<double> getUsdToBrlRate() async {
    // Cache using AppConstants duration
    if (_lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < AppConstants.exchangeRateCacheDuration) {
      return _cachedExchangeRate;
    }

    try {
      final response = await DioClient.instance.get(
        AppConstants.awesomeApiUsdBrlUrl,
      );
      if (response.statusCode == 200 && response.data != null) {
        final usdData = response.data['USDBRL'];
        if (usdData != null && usdData['bid'] != null) {
          final bid = double.tryParse(usdData['bid'].toString());
          if (bid != null && bid > 0) {
            _cachedExchangeRate = bid;
            _lastFetched = DateTime.now();
            return _cachedExchangeRate;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching exchange rate, using fallback: $e');
    }

    return _cachedExchangeRate;
  }
}
