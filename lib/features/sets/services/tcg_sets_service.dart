import '../../../core/utils/tcg_pricing_parser.dart';
import '../data/tcg_sets_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../models/set_product_item.dart';
import '../models/tcg_set_item.dart';

class TcgSetsService {
  static List<TcgSetItem>? _cachedSets;
  static final Map<String, List<PokemonCardItem>> _setCardsCache = {};
  static final Map<String, double> _cardPriceCache = {};


  /// Fetches all Pokémon TCG sets, maps their year and prints/card count
  static Future<List<TcgSetItem>> fetchAllSets() async {
    if (_cachedSets != null && _cachedSets!.isNotEmpty) {
      return _cachedSets!;
    }

    try {
      final response = await DioClient.instance.get(
        '${AppConstants.tcgdexBaseUrl}/en/sets',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data as List;
        final List<TcgSetItem> items = [];

        for (final raw in list) {
          if (raw is Map<String, dynamic>) {
            final id = raw['id']?.toString() ?? '';
            final inferredYear = TcgSetsData.setYearMap[id] ?? _inferYearFromId(id);
            final isUpcoming = TcgSetsData.upcomingSetIds.contains(id) || inferredYear >= 2026;

            items.add(
              TcgSetItem.fromJson(
                raw,
                inferredYear: inferredYear,
                isUpcoming: isUpcoming,
              ),
            );
          }
        }

        // Sort descending by year, then name
        items.sort((a, b) {
          final yearComp = b.year.compareTo(a.year);
          if (yearComp != 0) return yearComp;
          return a.name.compareTo(b.name);
        });

        _cachedSets = items;
        return items;
      }
    } catch (e) {
      debugPrint('Error loading sets: $e');
    }

    return _fallbackSets;
  }

  static int _inferYearFromId(String id) {
    if (id.startsWith('me') || id.startsWith('B')) return 2026;
    if (id.startsWith('sv09') || id.startsWith('sv10') || id.startsWith('A3') || id.startsWith('A4')) return 2025;
    if (id.startsWith('sv05') || id.startsWith('sv06') || id.startsWith('sv07') || id.startsWith('sv08') || id.startsWith('A1')) return 2024;
    if (id.startsWith('sv')) return 2023;
    if (id.startsWith('swsh')) return 2021;
    if (id.startsWith('sm')) return 2018;
    if (id.startsWith('xy')) return 2015;
    if (id.startsWith('bw')) return 2012;
    if (id.startsWith('dp') || id.startsWith('pl') || id.startsWith('hgss')) return 2009;
    if (id.startsWith('ex')) return 2005;
    if (id.startsWith('neo') || id.startsWith('gym') || id.startsWith('base')) return 2000;
    return 2024;
  }

  /// Fetches cards belonging to a specific set
  static Future<List<PokemonCardItem>> fetchCardsForSet(String setId) async {
    if (_setCardsCache.containsKey(setId)) {
      return _setCardsCache[setId]!;
    }

    try {
      final response = await DioClient.instance.get(
        '${AppConstants.tcgdexBaseUrl}/en/sets/$setId',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final rawCards = data['cards'];
        final setName = data['name']?.toString() ?? setId;
        final totalCount = (data['cardCount'] is Map)
            ? (data['cardCount']['total'] as num?)?.toInt() ?? 0
            : 0;

        if (rawCards is List) {
          final List<PokemonCardItem> cards = [];
          for (final c in rawCards) {
            if (c is Map) {
              final cid = c['id']?.toString() ?? '';
              final cname = c['name']?.toString() ?? '';
              final localId = c['localId']?.toString() ?? '';
              var img = c['image']?.toString();
              if (img != null && !img.endsWith('.png') && !img.endsWith('.webp')) {
                img = '$img/high.png';
              }

              final parsedPrices = TcgPricingParser.parsePricing(c['pricing'] as Map<String, dynamic>?);
              double? marketPrice = parsedPrices.market;
              double? midPrice = parsedPrices.mid;
              double? lowPrice = parsedPrices.low;

              if (marketPrice == null && _cardPriceCache.containsKey(cid)) {
                marketPrice = _cardPriceCache[cid];
              }

              cards.add(
                PokemonCardItem(
                  id: cid,
                  name: cname,
                  supertype: 'Pokémon',
                  number: localId,
                  setId: setId,
                  setName: setName,
                  rarity: c['rarity']?.toString() ?? 'Common',
                  artist: 'Unknown',
                  types: const ['Colorless'],
                  imageUrlSmall: img ?? '',
                  imageUrlLarge: img ?? '',
                  setTotal: totalCount > 0 ? totalCount.toString() : null,
                  tcgMarketUsd: marketPrice,
                  tcgMidUsd: midPrice,
                  tcgLowUsd: lowPrice,
                ),
              );
            }
          }

          _setCardsCache[setId] = cards;
          return cards;
        }
      }
    } catch (e) {
      debugPrint('Error loading cards for set $setId: $e');
    }

    return [];
  }

  /// Enriches real market prices for cards in a set by querying TCGdex live pricing in parallel batches
  static Future<bool> enrichPricesForCards(
    List<PokemonCardItem> cards, {
    int limit = 120,
    void Function()? onBatchUpdated,
  }) async {
    bool anyUpdated = false;
    final toFetch = cards
        .where((c) => (c.tcgMarketUsd == null || c.tcgMarketUsd == 0) && !_cardPriceCache.containsKey(c.id))
        .take(limit)
        .toList();

    const batchSize = 10;
    for (int i = 0; i < toFetch.length; i += batchSize) {
      final batch = toFetch.skip(i).take(batchSize).toList();
      bool batchUpdated = false;

      await Future.wait(
        batch.map((card) async {
          try {
            final resp = await DioClient.instance.get(
              '${AppConstants.tcgdexBaseUrl}/en/cards/${card.id}',
              options: Options(validateStatus: (s) => s != null && s < 500),
            );
            if (resp.statusCode == 200 && resp.data is Map) {
              final pricing = (resp.data as Map)['pricing'] as Map<String, dynamic>?;
              final parsedPrices = TcgPricingParser.parsePricing(pricing);
              final price = parsedPrices.market;
              final mid = parsedPrices.mid;
              final low = parsedPrices.low;
              if (price != null && price > 0) {
                _cardPriceCache[card.id] = price;
                final idx = cards.indexWhere((c) => c.id == card.id);
                if (idx >= 0) {
                  cards[idx] = cards[idx].copyWith(
                    tcgMarketUsd: price,
                    tcgMidUsd: mid,
                    tcgLowUsd: low,
                  );
                  batchUpdated = true;
                  anyUpdated = true;
                }
              }
            }
          } catch (e) {
            debugPrint('Error enriching price for ${card.id}: $e');
          }
        }),
      );

      if (batchUpdated && onBatchUpdated != null) {
        onBatchUpdated();
      }
    }
    return anyUpdated;
  }


  /// Generates the curated sealed products for a set (ETB, Booster Box, Bundle, UPC, etc.)
  static List<SetProductItem> fetchProductsForSet(TcgSetItem set) {
    final defaultImg = set.logoUrl ?? 'https://assets.tcgdex.net/en/sv/sv08/logo.png';
    final productMap = TcgSetsData.productImages[set.id] ?? {};

    final etbImg = productMap['etb'] ?? defaultImg;
    final bbImg = productMap['booster_box'] ?? defaultImg;
    final bundleImg = productMap['bundle'] ?? defaultImg;
    final upcImg = productMap['upc'] ?? defaultImg;
    final blisterImg = productMap['blister'] ?? defaultImg;
    final isUpcoming = set.isUpcoming;

    return [
      SetProductItem(
        id: '${set.id}_etb',
        name: '${set.name} Elite Trainer Box',
        productType: 'Elite Trainer Box',
        imageUrl: etbImg,
        msrpUsd: 54.99,
        packCount: 9,
        description:
            'Includes 9 ${set.name} booster packs, 1 full-art foil promo card, 65 card sleeves, 45 Energy cards, a player\'s guide, 6 damage-counter dice, 1 competition-legal coin-flip die, and a collector\'s box with 4 dividers.',
        releaseDate: set.releaseDate ?? '${set.year}',
      ),
      SetProductItem(
        id: '${set.id}_booster_box',
        name: '${set.name} Booster Display Box',
        productType: 'Booster Box',
        imageUrl: bbImg,
        msrpUsd: 161.64,
        packCount: 36,
        description:
            'Full factory-sealed booster display box containing 36 booster packs (10 cards per pack + 1 Basic Energy).',
        releaseDate: set.releaseDate ?? '${set.year}',
      ),
      SetProductItem(
        id: '${set.id}_booster_bundle',
        name: '${set.name} Booster Bundle',
        productType: 'Booster Bundle',
        imageUrl: bundleImg,
        msrpUsd: 26.94,
        packCount: 6,
        description:
            'A compact booster bundle with 6 booster packs of ${set.name} - perfect for opening on the go.',
        releaseDate: set.releaseDate ?? '${set.year}',
      ),
      if (isUpcoming || set.totalCards > 180 || productMap.containsKey('upc'))
        SetProductItem(
          id: '${set.id}_upc',
          name: '${set.name} Ultra-Premium Collection',
          productType: 'Ultra-Premium Collection',
          imageUrl: upcImg,
          msrpUsd: 119.99,
          packCount: 16,
          description:
              'The pinnacle collection featuring 16 booster packs, exclusive metal damage counters, special etched foil promo cards, playmat, and deck box.',
          releaseDate: set.releaseDate ?? '${set.year}',
        ),
      SetProductItem(
        id: '${set.id}_blister',
        name: '${set.name} 3-Pack Blister',
        productType: 'Blister Pack',
        imageUrl: blisterImg,
        msrpUsd: 14.99,
        packCount: 3,
        description:
            'Includes 3 booster packs, 1 foil promo card, and a metallic Pokémon coin.',
        releaseDate: set.releaseDate ?? '${set.year}',
      ),
    ];
  }

  /// Curated fallback sets if offline
  static final List<TcgSetItem> _fallbackSets = [
    const TcgSetItem(
      id: 'sv08',
      name: 'Surging Sparks',
      totalCards: 252,
      officialCards: 191,
      year: 2024,
      releaseDate: '2024-11-08',
      logoUrl: 'https://assets.tcgdex.net/en/sv/sv08/logo.png',
    ),
    const TcgSetItem(
      id: 'sv07',
      name: 'Stellar Crown',
      totalCards: 175,
      officialCards: 142,
      year: 2024,
      releaseDate: '2024-09-13',
      logoUrl: 'https://assets.tcgdex.net/en/sv/sv07/logo.png',
    ),
    const TcgSetItem(
      id: 'sv06',
      name: 'Twilight Masquerade',
      totalCards: 226,
      officialCards: 167,
      year: 2024,
      releaseDate: '2024-05-24',
      logoUrl: 'https://assets.tcgdex.net/en/sv/sv06/logo.png',
    ),
    const TcgSetItem(
      id: 'sv03.5',
      name: '151',
      totalCards: 207,
      officialCards: 165,
      year: 2023,
      releaseDate: '2023-09-22',
      logoUrl: 'https://assets.tcgdex.net/en/sv/sv03.5/logo.png',
    ),
    const TcgSetItem(
      id: 'base1',
      name: 'Base Set',
      totalCards: 102,
      officialCards: 102,
      year: 1999,
      releaseDate: '1999-01-09',
      logoUrl: 'https://assets.tcgdex.net/en/base/base1/logo.png',
    ),
  ];
}
