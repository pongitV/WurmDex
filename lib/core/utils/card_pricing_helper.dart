import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/card_details/services/pricing_service.dart';
import 'card_condition_helper.dart';

class CardPriceQuotes {
  final double avgBrl;
  final double? minBrl;
  final double? maxBrl;
  final Map<String, double> conditionPrices;

  const CardPriceQuotes({
    required this.avgBrl,
    this.minBrl,
    this.maxBrl,
    this.conditionPrices = const {},
  });
}

class CardPricingHelper {
  // In-memory cache for real fetched card prices (cardApiId / cardKey -> Preço Médio BRL)
  static final Map<String, double> _realPriceCache = {};
  // In-memory cache for full Liga price quotes (Menor, Médio, Maior e preços por qualidade)
  static final Map<String, CardPriceQuotes> _quoteCache = {};
  static final Set<String> _pendingFetches = {};

  /// Retrieves the authentic price from LigaPokémon for a specific card condition.
  /// No fixed multiplication rates or artificial percentage scaling are applied.
  /// - If Liga explicitly lists a price for this quality in the marketplace offers, it is used directly.
  /// - Otherwise uses LigaPokémon's native price metrics:
  ///   - 'Near Mint' (NM): Liga Preço Médio
  ///   - 'Slightly Played' (SP): Liga Preço Menor
  ///   - 'Mint' (M): Liga Preço Maior
  ///   - 'Moderately Played' (MP), 'Heavily Played' (HP), 'Damaged' (DMG): Liga Preço Menor
  /// - If Liga prices are not available, preserves basePriceBrl.
  static double getPriceForCondition({
    String? cardApiId,
    String? cardName,
    String? cardNumber,
    String? setName,
    required double basePriceBrl,
    double? minPriceBrl,
    double? maxPriceBrl,
    Map<String, double>? conditionPrices,
    required String condition,
  }) {
    if (basePriceBrl <= 0) return 0.0;

    final cacheKey = (cardApiId != null && cardApiId.isNotEmpty)
        ? cardApiId
        : (cardName != null && cardNumber != null ? '${cardName}_$cardNumber' : '');
    final cached = cacheKey.isNotEmpty ? _quoteCache[cacheKey] : null;

    final resolvedMin = minPriceBrl ?? cached?.minBrl;
    final resolvedMax = maxPriceBrl ?? cached?.maxBrl;
    final resolvedMap = conditionPrices ?? cached?.conditionPrices ?? const {};

    final short = CardConditionHelper.getShortCondition(condition).toUpperCase();

    // 1. Direct price from LigaPokémon marketplace offers table for this quality if present
    if (resolvedMap.containsKey(condition) && resolvedMap[condition]! > 0) {
      return resolvedMap[condition]!;
    }
    if (resolvedMap.containsKey(short) && resolvedMap[short]! > 0) {
      return resolvedMap[short]!;
    }

    // 2. Direct mapping to LigaPokémon's official prices without fixed multipliers:
    switch (short) {
      case 'MINT':
        if (resolvedMax != null && resolvedMax > 0) {
          return resolvedMax;
        }
        return basePriceBrl;

      case 'NM':
        return basePriceBrl;

      case 'SP':
      case 'MP':
      case 'HP':
      case 'DMG':
        if (resolvedMin != null && resolvedMin > 0) {
          return resolvedMin;
        }
        return basePriceBrl;

      default:
        return basePriceBrl;
    }
  }

  /// Price calculator for card quality/condition directly from LigaPokémon
  static double getPriceForQuality(double baseLigaPrice, String? condition) {
    if (baseLigaPrice <= 0) return 0.0;
    return getPriceForCondition(
      basePriceBrl: baseLigaPrice,
      condition: condition ?? 'Near Mint',
    );
  }

  /// Converts a TCGPlayer USD quote directly to BRL without artificial markups.
  static double convertUsdToRealisticBrl(double usdPrice, double exchangeRate) {
    final effectiveRate = exchangeRate > 0 ? exchangeRate : 5.5;
    return (usdPrice * effectiveRate).clamp(0.0, 999999.0);
  }

  /// Fetches the real LigaPokémon/catalog market quotes (Menor, Médio, Maior e por qualidade) and caches them.
  static Future<CardPriceQuotes> getOrFetchPriceQuotes({
    required String cardApiId,
    required String cardName,
    required String cardNumber,
    String? setName,
    double? knownMarketUsd,
    required double exchangeRate,
    bool forceRefresh = false,
  }) async {
    final cacheKey = cardApiId.isNotEmpty ? cardApiId : '${cardName}_$cardNumber';
    if (!forceRefresh && cacheKey.isNotEmpty && _quoteCache.containsKey(cacheKey)) {
      return _quoteCache[cacheKey]!;
    }

    // If explicit market USD provided
    if (knownMarketUsd != null && knownMarketUsd > 0 && !forceRefresh) {
      final brl = convertUsdToRealisticBrl(knownMarketUsd, exchangeRate);
      final quotes = CardPriceQuotes(
        avgBrl: brl,
      );
      _quoteCache[cacheKey] = quotes;
      _realPriceCache[cacheKey] = brl;
      return quotes;
    }

    try {
      final result = await PricingService.getPricesForCard(
        cardName: cardName,
        cardNumber: cardNumber,
        cardId: cardApiId.isNotEmpty ? cardApiId : null,
        setName: setName,
      );

      final primaryPrice = result.getPrimaryPrice(false);
      final quotes = CardPriceQuotes(
        avgBrl: primaryPrice,
        minBrl: result.ligaMinBrl,
        maxBrl: result.ligaMaxBrl,
        conditionPrices: result.pricesByCondition,
      );
      if (primaryPrice > 0) {
        _quoteCache[cacheKey] = quotes;
        _realPriceCache[cacheKey] = primaryPrice;
        return quotes;
      }
    } catch (e) {
      debugPrint('Error fetching real Liga price quotes for $cardName ($cardNumber): $e');
    }

    final fallback = CardPriceQuotes(avgBrl: _realPriceCache[cacheKey] ?? 0.0);
    return fallback;
  }

  /// Force-refreshes quotes from live market bypassing cache
  static Future<CardPriceQuotes> forceRefreshCardQuotes({
    required String cardApiId,
    required String cardName,
    required String cardNumber,
    String? setName,
    required double exchangeRate,
  }) async {
    final cacheKey = cardApiId.isNotEmpty ? cardApiId : '${cardName}_$cardNumber';
    _realPriceCache.remove(cacheKey);
    _quoteCache.remove(cacheKey);
    return getOrFetchPriceQuotes(
      cardApiId: cardApiId,
      cardName: cardName,
      cardNumber: cardNumber,
      setName: setName,
      exchangeRate: exchangeRate,
      forceRefresh: true,
    );
  }

  /// Fetches the real LigaPokémon/catalog market price (Preço Médio) for a card and caches it.
  static Future<double> getOrFetchCardPriceBrl({
    required String cardApiId,
    required String cardName,
    required String cardNumber,
    String? setName,
    double? knownMarketUsd,
    required double exchangeRate,
  }) async {
    final quotes = await getOrFetchPriceQuotes(
      cardApiId: cardApiId,
      cardName: cardName,
      cardNumber: cardNumber,
      setName: setName,
      knownMarketUsd: knownMarketUsd,
      exchangeRate: exchangeRate,
    );
    return quotes.avgBrl;
  }

  /// Synchronously returns a cached real Liga Preço Médio if available,
  /// otherwise returns purchasePriceBrl or triggers background fetch to warm the cache.
  static double getCachedOrEstimatedPriceBrl({
    required String cardApiId,
    String? cardName,
    String? cardNumber,
    String? setName,
    double purchasePriceBrl = 0.0,
    required String rarity,
    String condition = 'Near Mint',
    double exchangeRate = 5.5,
    bool triggerFetchIfMissing = true,
  }) {
    if (purchasePriceBrl > 0) {
      return purchasePriceBrl;
    }

    final cacheKey = cardApiId.isNotEmpty ? cardApiId : '${cardName ?? ""}_${cardNumber ?? ""}';
    if (cacheKey.isNotEmpty && _realPriceCache.containsKey(cacheKey)) {
      return _realPriceCache[cacheKey]!;
    }

    if (triggerFetchIfMissing && cardApiId.isNotEmpty && !_pendingFetches.contains(cardApiId)) {
      warmPriceCache(
        cardApiId: cardApiId,
        cardName: cardName ?? '',
        cardNumber: cardNumber ?? '',
        setName: setName,
        exchangeRate: exchangeRate,
      );
    }

    return 0.0;
  }

  /// Asynchronously warms the price cache for a single card in the background
  static void warmPriceCache({
    required String cardApiId,
    required String cardName,
    required String cardNumber,
    String? setName,
    required double exchangeRate,
  }) {
    final cacheKey = cardApiId.isNotEmpty ? cardApiId : '${cardName}_$cardNumber';
    if (cacheKey.isEmpty || _quoteCache.containsKey(cacheKey) || _pendingFetches.contains(cacheKey)) {
      return;
    }

    _pendingFetches.add(cacheKey);
    getOrFetchPriceQuotes(
      cardApiId: cardApiId,
      cardName: cardName,
      cardNumber: cardNumber,
      setName: setName,
      exchangeRate: exchangeRate,
    ).then((quotes) {
      if (quotes.avgBrl > 0) {
        _realPriceCache[cacheKey] = quotes.avgBrl;
        _quoteCache[cacheKey] = quotes;
      }
    }).catchError((_) {}).whenComplete(() {
      _pendingFetches.remove(cacheKey);
    });
  }

  /// Bulk-warm price cache for a list of collection cards in the background
  static void warmMultipleCards(List<dynamic> cards, double exchangeRate) {
    for (final c in cards) {
      try {
        final cardApiId = (c.cardApiId ?? '') as String;
        final name = (c.name ?? '') as String;
        final number = (c.number ?? '') as String;
        final setName = (c.setName ?? '') as String;
        if (cardApiId.isNotEmpty) {
          warmPriceCache(
            cardApiId: cardApiId,
            cardName: name,
            cardNumber: number,
            setName: setName,
            exchangeRate: exchangeRate,
          );
        }
      } catch (_) {}
    }
  }

  /// Returns the realistic market price (Preço Médio) in BRL for a card.
  /// If [purchasePriceBrl] is recorded and greater than zero, it is used.
  /// Otherwise returns the cached LigaPokémon Preço Médio.
  static double getRealisticMarketPriceBrl({
    String? cardApiId,
    String? cardName,
    String? cardNumber,
    String? setName,
    double purchasePriceBrl = 0.0,
    String rarity = '',
    String condition = 'Near Mint',
    double exchangeRate = 5.5,
  }) {
    if (purchasePriceBrl > 0) {
      return purchasePriceBrl;
    }
    if (cardApiId != null && cardApiId.isNotEmpty) {
      final base = getCachedOrEstimatedPriceBrl(
        cardApiId: cardApiId,
        cardName: cardName,
        cardNumber: cardNumber,
        setName: setName,
        purchasePriceBrl: purchasePriceBrl,
        rarity: rarity,
        condition: condition,
        exchangeRate: exchangeRate,
      );
      return getPriceForCondition(
        cardApiId: cardApiId,
        cardName: cardName,
        cardNumber: cardNumber,
        setName: setName,
        basePriceBrl: base,
        condition: condition,
      );
    }
    return 0.0;
  }
}
