/// Structured representation of market, mid, and low prices for a card.
class TcgPrices {
  final double? market;
  final double? mid;
  final double? low;

  const TcgPrices({this.market, this.mid, this.low});

  bool get hasPrices => market != null || mid != null || low != null;
}

/// Centralized parser for TCGdex and Cardmarket pricing payloads.
///
/// Eliminates duplicate price-extraction boilerplate across the catalog,
/// sets service, and card details pricing features.
class TcgPricingParser {
  TcgPricingParser._();

  /// Supported printing variants in order of priority.
  static const List<String> variantKeys = [
    'holofoil',
    'normal',
    'reverseHolofoil',
    'reverse-holofoil',
    '1stEditionNormal',
    '1stEditionHolofoil',
  ];

  /// Standard EUR to USD conversion multiplier when using Cardmarket fallback data.
  static const double eurToUsdMultiplier = 1.08;

  /// Extracts standard USD market, mid, and low prices from a TCGdex card JSON payload.
  ///
  /// Checks TCGPlayer variant tables first, and falls back to Cardmarket sales history if needed.
  static TcgPrices parsePricing(Map<String, dynamic>? pricing) {
    if (pricing == null) return const TcgPrices();

    double? market;
    double? mid;
    double? low;

    final tcg = pricing['tcgplayer'] as Map<String, dynamic>?;
    if (tcg != null) {
      for (final v in variantKeys) {
        final p = tcg[v] as Map<String, dynamic>?;
        if (p != null) {
          if (market == null && p['marketPrice'] != null) {
            market = (p['marketPrice'] as num).toDouble();
          }
          if (mid == null && p['midPrice'] != null) {
            mid = (p['midPrice'] as num).toDouble();
          }
          if (low == null && p['lowPrice'] != null) {
            low = (p['lowPrice'] as num).toDouble();
          }
        }
      }
      if (market == null && tcg['marketPrice'] != null) {
        market = (tcg['marketPrice'] as num).toDouble();
      }
    }

    // Cardmarket sales history fallback (EUR converted to USD ~1.08)
    if (market == null) {
      final cm = pricing['cardmarket'] as Map<String, dynamic>?;
      if (cm != null) {
        final rawSales = cm['avg30'] ?? cm['avg7'] ?? cm['trend'] ?? cm['avg'] ?? cm['lowPrice'];
        if (rawSales != null) {
          market = (rawSales as num).toDouble() * eurToUsdMultiplier;
        }
        if (low == null && cm['lowPrice'] != null) {
          low = (cm['lowPrice'] as num).toDouble() * eurToUsdMultiplier;
        }
      }
    }

    return TcgPrices(market: market, mid: mid, low: low);
  }

  /// Convenience method to quickly extract just the primary market price in USD.
  static double? extractMarketPriceUsd(Map<String, dynamic>? pricing) {
    return parsePricing(pricing).market;
  }
}
