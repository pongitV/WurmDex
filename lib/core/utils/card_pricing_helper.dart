import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/card_details/services/pricing_service.dart';

class CardPricingHelper {
  // In-memory cache for real fetched card prices (cardApiId / cardKey -> Preço Médio BRL)
  static final Map<String, double> _realPriceCache = {};
  static final Set<String> _pendingFetches = {};

  /// The universal card value is always the LigaPokémon Preço Médio (average price).
  /// Multipliers are removed per user specification.
  static double getPriceForQuality(double baseLigaPrice, String? condition) {
    if (baseLigaPrice <= 0) return 0.0;
    return baseLigaPrice.clamp(0.0, 999999.0);
  }

  /// Converts a TCGPlayer USD quote directly to BRL without artificial markups.
  static double convertUsdToRealisticBrl(double usdPrice, double exchangeRate) {
    final effectiveRate = exchangeRate > 0 ? exchangeRate : 5.5;
    return (usdPrice * effectiveRate).clamp(0.0, 999999.0);
  }

  /// Fetches the real LigaPokémon/catalog market price (Preço Médio) for a card and caches it.
  /// If [knownMarketUsd] is provided, converts directly with exchange rate.
  /// Otherwise queries [PricingService] for live card quotes.
  static Future<double> getOrFetchCardPriceBrl({
    required String cardApiId,
    required String cardName,
    required String cardNumber,
    String? setName,
    double? knownMarketUsd,
    required double exchangeRate,
  }) async {
    final cacheKey = cardApiId.isNotEmpty ? cardApiId : '${cardName}_$cardNumber';
    if (_realPriceCache.containsKey(cacheKey)) {
      return _realPriceCache[cacheKey]!;
    }

    // 1. If knownMarketUsd was already supplied from explicit catalog pricing
    if (knownMarketUsd != null && knownMarketUsd > 0) {
      final brl = convertUsdToRealisticBrl(knownMarketUsd, exchangeRate);
      _realPriceCache[cacheKey] = brl;
      return brl;
    }

    // 2. Fetch live quote via PricingService
    try {
      final result = await PricingService.getPricesForCard(
        cardName: cardName,
        cardNumber: cardNumber,
        cardId: cardApiId.isNotEmpty ? cardApiId : null,
        setName: setName,
      );

      final primaryPrice = result.getPrimaryPrice(false); // returns BRL (Preço Médio)
      if (primaryPrice > 0) {
        _realPriceCache[cacheKey] = primaryPrice;
        return primaryPrice;
      }
    } catch (e) {
      debugPrint('Error fetching real Liga price for $cardName ($cardNumber): $e');
    }

    return 0.0;
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
    if (cacheKey.isEmpty || _realPriceCache.containsKey(cacheKey) || _pendingFetches.contains(cacheKey)) {
      return;
    }

    _pendingFetches.add(cacheKey);
    PricingService.getPricesForCard(
      cardName: cardName,
      cardNumber: cardNumber,
      cardId: cardApiId.isNotEmpty ? cardApiId : null,
      setName: setName,
    ).then((res) {
      final brl = res.getPrimaryPrice(false);
      if (brl > 0) {
        _realPriceCache[cacheKey] = brl;
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
      return getCachedOrEstimatedPriceBrl(
        cardApiId: cardApiId,
        cardName: cardName,
        cardNumber: cardNumber,
        setName: setName,
        purchasePriceBrl: purchasePriceBrl,
        rarity: rarity,
        condition: condition,
        exchangeRate: exchangeRate,
      );
    }
    return 0.0;
  }
}

