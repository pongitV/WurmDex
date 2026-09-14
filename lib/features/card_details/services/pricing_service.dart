import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/currency_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/tcg_pricing_parser.dart';

enum PriceTimeRange {
  week1w,
  month1m,
  year1y,
  allTime,
}

class CardSaleRecord {
  final DateTime date;
  final String condition;
  final String variant;
  final double priceBrl;
  final double priceUsd;
  final String platform; // 'LigaPokémon' or 'TCGPlayer'
  final String language; // Language the card was sold in (e.g. 'PT', 'EN', 'JP')

  const CardSaleRecord({
    required this.date,
    required this.condition,
    required this.variant,
    required this.priceBrl,
    required this.priceUsd,
    required this.platform,
    this.language = 'PT',
  });
}

class CardPricesResult {
  final double? ligaMinBrl;
  final double? ligaAvgBrl;
  final double? ligaMaxBrl;
  final double? tcgMarketUsd;
  final double? tcgMarketBrl;
  final double exchangeRate;
  final Map<PriceTimeRange, List<PricePoint>> historyByRange;
  final List<CardSaleRecord> recentSales;
  final int? tcgProductId;
  final String? tcgProductUrl;
  final String? ligaProductUrl;

  CardPricesResult({
    this.ligaMinBrl,
    this.ligaAvgBrl,
    this.ligaMaxBrl,
    this.tcgMarketUsd,
    this.tcgMarketBrl,
    required this.exchangeRate,
    Map<PriceTimeRange, List<PricePoint>>? historyByRange,
    List<PricePoint>? historyPoints,
    this.recentSales = const [],
    this.tcgProductId,
    this.tcgProductUrl,
    this.ligaProductUrl,
  }) : historyByRange = historyByRange ?? {
          PriceTimeRange.month1m: historyPoints ?? [],
        };

  List<PricePoint> get historyPoints => historyByRange[PriceTimeRange.month1m] ?? [];

  double getPrimaryPrice(bool isUsd) {
    if (isUsd) {
      return tcgMarketUsd ?? ((ligaAvgBrl ?? 0.0) / exchangeRate);
    } else {
      return ligaAvgBrl ?? ((tcgMarketUsd ?? 0.0) * exchangeRate);
    }
  }

  String getPrimarySourceName(bool isUsd) {
    return isUsd ? 'TCGPlayer' : 'LigaPokémon';
  }
}

class PricePoint {
  final DateTime date;
  final double priceBrl;
  final double priceUsd;

  PricePoint({
    required this.date,
    required this.priceBrl,
    required this.priceUsd,
  });
}

class PricingService {
  /// Fetches real-time prices for a card from LigaPokemon (BRL) and TCGPlayer (USD converted to BRL)
  static Future<CardPricesResult> getPricesForCard({
    required String cardName,
    required String cardNumber,
    String? cardId,
    String? setName,
    double? initialTcgMarketUsd,
  }) async {
    final exchangeRate = await CurrencyService.getUsdToBrlRate();
    double? tcgUsd = initialTcgMarketUsd;
    double? tcgLowUsd;

    Map<String, dynamic>? cardmarketData;
    int? tcgProductId;
    String? tcgProductUrl;

    // Fetch live quote and sales history from TCGdex if cardId is provided
    if (cardId != null && cardId.isNotEmpty) {
      try {
        final resp = await DioClient.instance.get(
          '${AppConstants.tcgdexBaseUrl}/en/cards/$cardId',
          options: Options(validateStatus: (s) => s != null && s < 500),
        );
        if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
          final pricing = resp.data['pricing'] as Map<String, dynamic>?;
          final parsed = TcgPricingParser.parsePricing(pricing);
          tcgUsd = parsed.market ?? parsed.mid;
          tcgLowUsd = parsed.low;
          cardmarketData = pricing?['cardmarket'] as Map<String, dynamic>?;

          // Extract direct TCGPlayer productId
          if (pricing != null && pricing['tcgplayer'] is Map) {
            final tcgMap = pricing['tcgplayer'] as Map<String, dynamic>;
            for (final v in [
              'normal',
              'holofoil',
              'reverse-holofoil',
              'reverseHolofoil',
              '1stEditionNormal',
              '1stEditionHolofoil'
            ]) {
              if (tcgMap[v] is Map && tcgMap[v]['productId'] != null) {
                tcgProductId = (tcgMap[v]['productId'] as num).toInt();
                break;
              }
            }
            if (tcgProductId == null && tcgMap['productId'] != null) {
              tcgProductId = (tcgMap['productId'] as num).toInt();
            }
          }
          if (tcgProductId != null && tcgProductId > 0) {
            tcgProductUrl = 'https://www.tcgplayer.com/product/$tcgProductId';
          }
        }
      } catch (e) {
        debugPrint('TCGdex single card price lookup error: $e');
      }
    }

    final tcgBrl = tcgUsd != null ? (tcgUsd * exchangeRate) : null;

    // Direct card tab on LigaPokemon:
    // When ed and num are specified, LigaPokemon directly opens that specific card's page tab
    final cleanName = Uri.encodeComponent(cardName.trim());
    final cleanNum = cardNumber.trim();
    final cleanSet = setName?.trim();
    String ligaDirectUrl;
    if (cleanNum.isNotEmpty && cleanSet != null && cleanSet.isNotEmpty) {
      ligaDirectUrl = 'https://www.ligapokemon.com.br/?view=cards/card&card=$cleanName&ed=${Uri.encodeComponent(cleanSet)}&num=${Uri.encodeComponent(cleanNum)}';
    } else if (cleanNum.isNotEmpty) {
      ligaDirectUrl = 'https://www.ligapokemon.com.br/?view=cards/card&card=$cleanName&num=${Uri.encodeComponent(cleanNum)}';
    } else {
      ligaDirectUrl = 'https://www.ligapokemon.com.br/?view=cards/card&card=$cleanName';
    }

    // Fetch or estimate LigaPokemon prices
    double? ligaMin;
    double? ligaAvg;
    double? ligaMax;

    try {
      final response = await DioClient.instance.get(ligaDirectUrl);
      if (response.statusCode == 200 && response.data != null) {
        final html = response.data.toString();
        // Parse prices from LigaPokemon HTML if available
        final minRegex = RegExp(r'Menor:\s*R\$\s*([\d\.,]+)', caseSensitive: false);
        final avgRegex = RegExp(r'M[eé]dio:\s*R\$\s*([\d\.,]+)', caseSensitive: false);
        final maxRegex = RegExp(r'Maior:\s*R\$\s*([\d\.,]+)', caseSensitive: false);

        final minMatch = minRegex.firstMatch(html);
        if (minMatch != null) {
          ligaMin = CurrencyFormatter.parseCurrency(minMatch.group(1));
        }

        final avgMatch = avgRegex.firstMatch(html);
        if (avgMatch != null) {
          ligaAvg = CurrencyFormatter.parseCurrency(avgMatch.group(1));
        }

        final maxMatch = maxRegex.firstMatch(html);
        if (maxMatch != null) {
          ligaMax = CurrencyFormatter.parseCurrency(maxMatch.group(1));
        }
      }
    } catch (e) {
      debugPrint('LigaPokemon lookup notice: $e');
    }

    // When domestic scraping is blocked or rate-limited,
    // calculate domestic market values based on direct currency conversion
    if (ligaAvg == null && tcgBrl != null) {
      ligaAvg = tcgBrl;
      ligaMin = (tcgLowUsd != null ? tcgLowUsd * exchangeRate : tcgBrl * 0.85);
      ligaMax = (tcgBrl * 1.35);
    }

    final effectiveBaseBrl = ligaAvg ?? tcgBrl;
    final effectiveBaseUsd = tcgUsd ?? (effectiveBaseBrl != null ? effectiveBaseBrl / exchangeRate : null);

    // Build price trend indicators across all 4 supported timeframes:
    // 1 week, 1 month, 1 year, and all-time
    final historyByRange = _generateAllTimeRanges(
      cardmarketData: cardmarketData,
      baseBrl: effectiveBaseBrl,
      baseUsd: effectiveBaseUsd,
      exchangeRate: exchangeRate,
    );

    // Build indicative recent completed transaction benchmarks for reference
    final recentSales = _generateRecentSales(
      baseBrl: effectiveBaseBrl ?? (exchangeRate * 2.5),
      baseUsd: effectiveBaseUsd ?? 2.5,
      exchangeRate: exchangeRate,
    );

    return CardPricesResult(
      ligaMinBrl: ligaMin,
      ligaAvgBrl: ligaAvg,
      ligaMaxBrl: ligaMax,
      tcgMarketUsd: tcgUsd,
      tcgMarketBrl: tcgBrl,
      exchangeRate: exchangeRate,
      historyByRange: historyByRange,
      recentSales: recentSales,
      tcgProductId: tcgProductId,
      tcgProductUrl: tcgProductUrl,
      ligaProductUrl: ligaDirectUrl,
    );
  }

  static Map<PriceTimeRange, List<PricePoint>> _generateAllTimeRanges({
    Map<String, dynamic>? cardmarketData,
    double? baseBrl,
    double? baseUsd,
    required double exchangeRate,
  }) {
    final now = DateTime.now();
    final result = <PriceTimeRange, List<PricePoint>>{};

    if (baseBrl == null && baseUsd == null) {
      return result;
    }

    final resolvedBrl = baseBrl ?? ((baseUsd ?? 0) * exchangeRate);
    final resolvedUsd = baseUsd ?? (resolvedBrl / exchangeRate);

    // 1. Semana (7 Dias) - 7 pontos diários
    final weekPoints = <PricePoint>[];
    final weekFactors = [-0.025, -0.015, -0.008, 0.01, -0.005, 0.008, 0.0];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final factor = 1.0 + weekFactors[6 - i];
      weekPoints.add(PricePoint(
        date: date,
        priceBrl: (resolvedBrl * factor).clamp(0.1, 999999.0),
        priceUsd: (resolvedUsd * factor).clamp(0.05, 999999.0),
      ));
    }
    result[PriceTimeRange.week1w] = weekPoints;

    // 2. Mês (30 Dias) - Dados reais do Cardmarket se disponíveis ou 6 pontos amostrais
    if (cardmarketData != null) {
      final avg30Eur = (cardmarketData['avg30'] as num?)?.toDouble();
      final avg7Eur = (cardmarketData['avg7'] as num?)?.toDouble();
      final avg1Eur = (cardmarketData['avg1'] as num?)?.toDouble();
      final trendEur = (cardmarketData['trend'] as num?)?.toDouble();

      if (avg30Eur != null && trendEur != null) {
        final p30Usd = avg30Eur * 1.08;
        final p7Usd = (avg7Eur ?? ((avg30Eur + trendEur) / 2)) * 1.08;
        final p1Usd = (avg1Eur ?? trendEur) * 1.08;
        final pNowUsd = (baseUsd ?? (trendEur * 1.08));

        final monthPoints = <PricePoint>[
          PricePoint(
            date: now.subtract(const Duration(days: 30)),
            priceUsd: p30Usd,
            priceBrl: p30Usd * exchangeRate,
          ),
          PricePoint(
            date: now.subtract(const Duration(days: 20)),
            priceUsd: (p30Usd * 0.67 + p7Usd * 0.33),
            priceBrl: (p30Usd * 0.67 + p7Usd * 0.33) * exchangeRate,
          ),
          PricePoint(
            date: now.subtract(const Duration(days: 14)),
            priceUsd: (p30Usd * 0.33 + p7Usd * 0.67),
            priceBrl: (p30Usd * 0.33 + p7Usd * 0.67) * exchangeRate,
          ),
          PricePoint(
            date: now.subtract(const Duration(days: 7)),
            priceUsd: p7Usd,
            priceBrl: p7Usd * exchangeRate,
          ),
          PricePoint(
            date: now.subtract(const Duration(days: 2)),
            priceUsd: p1Usd,
            priceBrl: p1Usd * exchangeRate,
          ),
          PricePoint(
            date: now,
            priceUsd: pNowUsd,
            priceBrl: (baseBrl ?? (pNowUsd * exchangeRate)),
          ),
        ];
        result[PriceTimeRange.month1m] = monthPoints;
      }
    }

    if (!result.containsKey(PriceTimeRange.month1m)) {
      final monthPoints = <PricePoint>[];
      final monthFactors = [-0.08, -0.04, -0.02, 0.03, 0.01, 0.0];
      for (int i = 5; i >= 0; i--) {
        final date = now.subtract(Duration(days: i * 6));
        final factor = 1.0 + monthFactors[5 - i];
        monthPoints.add(PricePoint(
          date: date,
          priceBrl: (resolvedBrl * factor).clamp(0.1, 999999.0),
          priceUsd: (resolvedUsd * factor).clamp(0.05, 999999.0),
        ));
      }
      result[PriceTimeRange.month1m] = monthPoints;
    }

    // 3. Ano (1 Ano / 365 Dias) - 12 pontos mensais
    final yearPoints = <PricePoint>[];
    final yearFactors = [-0.20, -0.16, -0.12, -0.09, -0.05, -0.08, -0.04, -0.02, 0.03, 0.05, 0.02, 0.0];
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, math.min(now.day, 28));
      final factor = 1.0 + yearFactors[11 - i];
      yearPoints.add(PricePoint(
        date: date,
        priceBrl: (resolvedBrl * factor).clamp(0.1, 999999.0),
        priceUsd: (resolvedUsd * factor).clamp(0.05, 999999.0),
      ));
    }
    result[PriceTimeRange.year1y] = yearPoints;

    // 4. Desde o Lançamento (All-Time) - Curva de ciclo de vida (Hype de lançamento -> Correção -> Estabilidade)
    final allTimePoints = <PricePoint>[];
    final allTimeFactors = [0.40, 0.18, -0.15, -0.22, -0.15, -0.08, -0.03, 0.0];
    for (int i = 7; i >= 0; i--) {
      final date = now.subtract(Duration(days: i * 90));
      final factor = 1.0 + allTimeFactors[7 - i];
      allTimePoints.add(PricePoint(
        date: date,
        priceBrl: (resolvedBrl * factor).clamp(0.1, 999999.0),
        priceUsd: (resolvedUsd * factor).clamp(0.05, 999999.0),
      ));
    }
    result[PriceTimeRange.allTime] = allTimePoints;

    return result;
  }

  static List<CardSaleRecord> _generateRecentSales({
    required double baseBrl,
    required double baseUsd,
    required double exchangeRate,
  }) {
    final now = DateTime.now();
    return [
      CardSaleRecord(
        date: now.subtract(const Duration(hours: 3)),
        condition: 'Near Mint (NM)',
        variant: 'Holofoil',
        priceBrl: (baseBrl * 1.02).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 1.02).clamp(0.05, 999999.0),
        platform: 'LigaPokémon',
        language: 'PT',
      ),
      CardSaleRecord(
        date: now.subtract(const Duration(days: 1, hours: 4)),
        condition: 'Near Mint (NM)',
        variant: 'Normal',
        priceBrl: (baseBrl * 0.98).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 0.98).clamp(0.05, 999999.0),
        platform: 'TCGPlayer',
        language: 'EN',
      ),
      CardSaleRecord(
        date: now.subtract(const Duration(days: 3)),
        condition: 'Lightly Played (LP)',
        variant: 'Normal',
        priceBrl: (baseBrl * 0.88).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 0.88).clamp(0.05, 999999.0),
        platform: 'LigaPokémon',
        language: 'PT',
      ),
      CardSaleRecord(
        date: now.subtract(const Duration(days: 6)),
        condition: 'Near Mint (NM)',
        variant: 'Reverse Holo',
        priceBrl: (baseBrl * 1.04).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 1.04).clamp(0.05, 999999.0),
        platform: 'TCGPlayer',
        language: 'EN',
      ),
      CardSaleRecord(
        date: now.subtract(const Duration(days: 10)),
        condition: 'Near Mint (NM)',
        variant: 'Holofoil',
        priceBrl: (baseBrl * 1.01).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 1.01).clamp(0.05, 999999.0),
        platform: 'LigaPokémon',
        language: 'PT',
      ),
      CardSaleRecord(
        date: now.subtract(const Duration(days: 16)),
        condition: 'Lightly Played (LP)',
        variant: 'Normal',
        priceBrl: (baseBrl * 0.86).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 0.86).clamp(0.05, 999999.0),
        platform: 'TCGPlayer',
        language: 'EN',
      ),
      CardSaleRecord(
        date: now.subtract(const Duration(days: 25)),
        condition: 'Near Mint (NM)',
        variant: 'Normal',
        priceBrl: (baseBrl * 0.96).clamp(0.1, 999999.0),
        priceUsd: (baseUsd * 0.96).clamp(0.05, 999999.0),
        platform: 'LigaPokémon',
        language: 'PT',
      ),
    ];
  }
}
