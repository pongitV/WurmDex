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

  /// Predefined mapping of set IDs to release years for accurate chronological grouping
  static const Map<String, int> _setYearMap = {
    // 2026 / Future Mega Evolution
    'me01': 2026,
    'me02': 2026,
    'me02.5': 2026,
    'me03': 2026,
    'me04': 2026,
    'me05': 2026,
    'mee': 2026,
    'mep': 2026,
    'B1': 2026,
    'B1a': 2026,
    'B2': 2026,
    'B2a': 2026,

    // 2025
    'sv08.5': 2025,
    'sv09': 2025,
    'sv10': 2025,
    'sv10.5b': 2025,
    'sv10.5w': 2025,
    'A2': 2025,
    'A2a': 2025,
    'A2b': 2025,
    'A3': 2025,
    'A3a': 2025,
    'A3b': 2025,
    'A4': 2025,
    'A4a': 2025,

    // 2024
    'sv04.5': 2024,
    'sv05': 2024,
    'sv06': 2024,
    'sv06.5': 2024,
    'sv07': 2024,
    'sv08': 2024,
    '2024sv': 2024,
    'P-A': 2024,
    'A1': 2024,
    'A1a': 2024,

    // 2023
    'sv01': 2023,
    'sve': 2023,
    'svp': 2023,
    'sv02': 2023,
    '2023sv': 2023,
    'sv03': 2023,
    'sv03.5': 2023,
    'mfb': 2023,
    'sv04': 2023,
    'swsh12.5': 2023,
    'swsh12.5gg': 2023,

    // 2022
    'swsh9': 2022,
    'swsh9tg': 2022,
    'swsh10': 2022,
    'swsh10tg': 2022,
    'swsh10.5': 2022,
    '2022swsh': 2022,
    'swsh11': 2022,
    'swsh11tg': 2022,
    'swsh12': 2022,
    'swsh12tg': 2022,

    // 2021
    'swsh4.5': 2021,
    'swsh4.5sv': 2021,
    'swsh5': 2021,
    'swsh6': 2021,
    'swsh7': 2021,
    'cel25': 2021,
    'cel25cc': 2021,
    'swsh8': 2021,
    '2021swsh': 2021,

    // 2020
    'swsh1': 2020,
    'swsh2': 2020,
    'swsh3': 2020,
    'fut2020': 2020,
    'swsh3.5': 2020,
    'swsh4': 2020,
    'swshp': 2020,

    // 2019
    'sm9': 2019,
    'det1': 2019,
    'sm10': 2019,
    'sm11': 2019,
    'sma': 2019,
    'sm115': 2019,
    '2019sm': 2019,
    'sm12': 2019,

    // 2018
    'sm5': 2018,
    'sm6': 2018,
    'sm7': 2018,
    'sm7.5': 2018,
    '2018sm': 2018,
    'sm8': 2018,

    // 2017
    'sm1': 2017,
    'smp': 2017,
    'tk-sm-r': 2017,
    'tk-sm-l': 2017,
    'sm2': 2017,
    '2017sm': 2017,
    'sm3': 2017,
    'sm3.5': 2017,
    'sm4': 2017,

    // 2016
    'xy9': 2016,
    'g1': 2016,
    'tk-xy-p': 2016,
    'tk-xy-su': 2016,
    'xy10': 2016,
    'xy11': 2016,
    '2016xy': 2016,
    'xy12': 2016,

    // 2015
    'xy5': 2015,
    'dc1': 2015,
    'tk-xy-latio': 2015,
    'tk-xy-latia': 2015,
    'xy6': 2015,
    'xy7': 2015,
    'xy8': 2015,
    '2015xy': 2015,

    // 2014
    'xy0': 2014,
    'xy1': 2014,
    'xya': 2014,
    'tk-xy-n': 2014,
    'tk-xy-sy': 2014,
    'xy2': 2014,
    '2014xy': 2014,
    'xy3': 2014,
    'tk-xy-b': 2014,
    'tk-xy-w': 2014,
    'xy4': 2014,
    'xyp': 2014,

    // 2013
    'bw8': 2013,
    'bw9': 2013,
    'bw10': 2013,
    'bw11': 2013,
    'rc': 2013,

    // 2012
    'bw4': 2012,
    'bw5': 2012,
    '2012bw': 2012,
    'bw6': 2012,
    'dv1': 2012,
    'bw7': 2012,

    // 2011
    'col1': 2011,
    'bw1': 2011,
    'bwp': 2011,
    '2011bw': 2011,
    'bw2': 2011,
    'tk-bw-e': 2011,
    'tk-bw-z': 2011,
    'bw3': 2011,

    // 2010
    'hgss1': 2010,
    'hgssp': 2010,
    'tk-hs-r': 2010,
    'tk-hs-g': 2010,
    'hgss2': 2010,
    'hgss3': 2010,
    'hgss4': 2010,

    // 2009
    'pl1': 2009,
    'pop9': 2009,
    'pl2': 2009,
    'pl3': 2009,
    'pl4': 2009,
    'ru1': 2009,

    // 2008
    'dp4': 2008,
    'pop7': 2008,
    'dp5': 2008,
    'dp6': 2008,
    'pop8': 2008,
    'dp7': 2008,

    // 2007
    'dpp': 2007,
    'dp1': 2007,
    'dp2': 2007,
    'pop6': 2007,
    'tk-dp-l': 2007,
    'tk-dp-m': 2007,
    'dp3': 2007,

    // 2006
    'ex11': 2006,
    'ex12': 2006,
    'tk-ex-m': 2006,
    'tk-ex-p': 2006,
    'pop3': 2006,
    'ex13': 2006,
    'pop4': 2006,
    'ex14': 2006,
    'ex15': 2006,
    'ex16': 2006,
    'pop5': 2006,

    // 2005
    'pop2': 2005,
    'ex8': 2005,
    'ex9': 2005,
    'ex10': 2005,
    'exu': 2005,

    // 2004
    'ex4': 2004,
    'ex5': 2004,
    'ex5.5': 2004,
    'tk-ex-latia': 2004,
    'tk-ex-latio': 2004,
    'ex6': 2004,
    'pop1': 2004,
    'ex7': 2004,

    // 2003
    'ex1': 2003,
    'ex2': 2003,
    'np': 2003,
    'ex3': 2003,

    // 2002
    'lc': 2002,
    'sp': 2002,
    'ecard1': 2002,
    'bog': 2002,
    'ecard2': 2002,
    'ecard3': 2002,

    // 2001
    'neo3': 2001,
    'neo4': 2001,

    // 2000
    'base4': 2000,
    'base5': 2000,
    'gym1': 2000,
    'gym2': 2000,
    'neo1': 2000,
    'neo2': 2000,
    'si1': 2000,

    // 1999
    'base1': 1999,
    'base2': 1999,
    'basep': 1999,
    'wp': 1999,
    'base3': 1999,
    'jumbo': 1999,
    'miscp': 1999,
  };

  /// Set IDs that are upcoming/unreleased in physical English TCG
  static const Set<String> _upcomingSetIds = {
    'sv10',
    'sv10.5b',
    'sv10.5w',
    'me01',
    'me02',
    'me02.5',
    'me03',
    'me04',
    'me05',
    'mee',
    'mep',
    'B1',
    'B1a',
    'B2',
    'B2a',
    'A3',
    'A3a',
    'A3b',
    'A4',
    'A4a',
  };

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
            final inferredYear = _setYearMap[id] ?? _inferYearFromId(id);
            final isUpcoming = _upcomingSetIds.contains(id) || inferredYear >= 2026;

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

              // Real market pricing lookup from TCGPlayer and Cardmarket sales history via TCGdex
              double? marketPrice;
              double? midPrice;
              double? lowPrice;
              final pricing = c['pricing'] as Map?;
              final tcg = pricing?['tcgplayer'] as Map?;
              if (tcg != null) {
                for (final v in ['holofoil', 'normal', 'reverseHolofoil', 'reverse-holofoil', '1stEditionNormal', '1stEditionHolofoil']) {
                  final p = tcg[v] as Map?;
                  if (p != null) {
                    if (marketPrice == null && p['marketPrice'] != null) {
                      marketPrice = (p['marketPrice'] as num).toDouble();
                    }
                    if (midPrice == null && p['midPrice'] != null) {
                      midPrice = (p['midPrice'] as num).toDouble();
                    }
                    if (lowPrice == null && p['lowPrice'] != null) {
                      lowPrice = (p['lowPrice'] as num).toDouble();
                    }
                  }
                }
                if (marketPrice == null && tcg['marketPrice'] != null) {
                  marketPrice = (tcg['marketPrice'] as num).toDouble();
                }
              }

              // Cardmarket sales history fallback (EUR converted to USD ~1.08)
              if (marketPrice == null) {
                final cm = pricing?['cardmarket'] as Map?;
                if (cm != null) {
                  final rawSales = cm['avg30'] ?? cm['avg7'] ?? cm['trend'] ?? cm['avg'] ?? cm['lowPrice'];
                  if (rawSales != null) {
                    marketPrice = (rawSales as num).toDouble() * 1.08;
                  }
                  if (lowPrice == null && cm['lowPrice'] != null) {
                    lowPrice = (cm['lowPrice'] as num).toDouble() * 1.08;
                  }
                }
              }

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
              final pricing = (resp.data as Map)['pricing'] as Map?;
              final tcg = pricing?['tcgplayer'] as Map?;
              double? price;
              double? mid;
              double? low;
              if (tcg != null) {
                for (final v in ['holofoil', 'normal', 'reverseHolofoil', 'reverse-holofoil', '1stEditionNormal', '1stEditionHolofoil']) {
                  final p = tcg[v] as Map?;
                  if (p != null) {
                    if (price == null && p['marketPrice'] != null) {
                      price = (p['marketPrice'] as num).toDouble();
                    }
                    if (mid == null && p['midPrice'] != null) {
                      mid = (p['midPrice'] as num).toDouble();
                    }
                    if (low == null && p['lowPrice'] != null) {
                      low = (p['lowPrice'] as num).toDouble();
                    }
                  }
                }
                if (price == null && tcg['marketPrice'] != null) {
                  price = (tcg['marketPrice'] as num).toDouble();
                }
              }
              if (price == null) {
                final cm = pricing?['cardmarket'] as Map?;
                if (cm != null) {
                  final raw = cm['avg30'] ?? cm['avg7'] ?? cm['trend'] ?? cm['avg'] ?? cm['lowPrice'];
                  if (raw != null) {
                    price = (raw as num).toDouble() * 1.08;
                  }
                }
              }
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

  /// High-definition sealed product photos for released and upcoming expansions
  static const Map<String, Map<String, String>> _productImages = {
    // 2024 - 2025 Scarlet & Violet
    'sv08': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/581898_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/581902_200w.jpg',
    },
    'sv07': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/562143_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/562142_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/562145_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/562147_200w.jpg',
    },
    'sv06': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/545934_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/545933_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/545936_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/545938_200w.jpg',
    },
    'sv06.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/552174_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/552176_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/552177_200w.jpg',
    },
    'sv05': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/535174_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/535173_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/535176_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/535178_200w.jpg',
    },
    'sv04.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/527581_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/527583_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/527585_200w.jpg',
    },
    'sv04': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/517173_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/517172_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/517175_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/517177_200w.jpg',
    },
    'sv03.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/500694_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/500698_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/500696_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/500700_200w.jpg',
    },
    'sv03': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/497678_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/497677_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/497680_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/497682_200w.jpg',
    },
    'sv02': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/491326_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/491325_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/491328_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/491330_200w.jpg',
    },
    'sv01': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/476839_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/476838_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/476841_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/476843_200w.jpg',
    },
    // Upcoming Releases (2025 - 2026)
    'sv08.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/594017_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/594020_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/594019_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/594022_200w.jpg',
    },
    'sv09': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605123_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/605122_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/605125_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/605127_200w.jpg',
    },
    'sv10': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605124_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/605122_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/605125_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/594019_200w.jpg',
    },
    'sv10.5w': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605124_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
    },
    'sv10.5b': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605124_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
    },
    'me01': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/581898_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/500696_200w.jpg',
    },
    'me02': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/581898_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
    },
    'me02.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/594017_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/594020_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/594019_200w.jpg',
    },
    // Sword & Shield
    'swsh12.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/452909_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/452912_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/452914_200w.jpg',
    },
    'swsh12': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/285268_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/285267_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/285270_200w.jpg',
    },
    'swsh11': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/276844_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/276843_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/276846_200w.jpg',
    },
    'swsh10': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/265888_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/265887_200w.jpg',
    },
    'swsh9': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/257271_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/257270_200w.jpg',
    },
    'cel25': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/246445_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/246447_200w.jpg',
    },
    'swsh8': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/247074_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/247073_200w.jpg',
    },
    'swsh7': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/242436_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/242435_200w.jpg',
    },
    'swsh6': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/239016_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/239015_200w.jpg',
    },
    'swsh5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/232047_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/232046_200w.jpg',
    },
    'swsh4.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/231439_200w.jpg',
    },
    'swsh4': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/223292_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/223291_200w.jpg',
    },
    'swsh3.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/218765_200w.jpg',
    },
    'swsh3': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/215443_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/215442_200w.jpg',
    },
    'swsh2': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/211029_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/211028_200w.jpg',
    },
    'swsh1': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/206411_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/206410_200w.jpg',
    },
    // Vintage
    'base1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205934_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/205934_200w.jpg',
    },
    'base2': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205943_200w.jpg',
    },
    'base3': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205942_200w.jpg',
    },
    'base5': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205947_200w.jpg',
    },
    'gym1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205945_200w.jpg',
    },
    'neo1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205948_200w.jpg',
    },
    'xy12': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/124314_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/124316_200w.jpg',
    },
    'sm1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/127607_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/127609_200w.jpg',
    },
    'sm5': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/157297_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/157299_200w.jpg',
    },
    'sm9': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/183604_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/183606_200w.jpg',
    },
    'sm10': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/188358_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/188360_200w.jpg',
    },
    'sm11': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/194488_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/194490_200w.jpg',
    },
    'sm12': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/199923_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/199925_200w.jpg',
    },
  };

  /// Generates the curated sealed products for a set (ETB, Booster Box, Bundle, UPC, etc.)
  static List<SetProductItem> fetchProductsForSet(TcgSetItem set) {
    final defaultImg = set.logoUrl ?? 'https://assets.tcgdex.net/en/sv/sv08/logo.png';
    final productMap = _productImages[set.id] ?? {};

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
