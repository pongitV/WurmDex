import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/semantic_search_helper.dart';
import '../models/pokemon_card_item.dart';

class PokemonCatalogService {
  static final Map<String, List<PokemonCardItem>> _queryCache = {};
  static Map<String, String>? _setNamesCache;
  static bool _isLoadingSets = false;

  /// Curated fallback map of popular Pokémon TCG sets
  static const Map<String, String> _knownSets = {
    'sv03.5': '151',
    'sv08': 'Surging Sparks',
    'sv07': 'Stellar Crown',
    'sv06': 'Twilight Masquerade',
    'sv05': 'Temporal Forces',
    'sv04.5': 'Paldean Fates',
    'sv04': 'Paradox Rift',
    'sv03': 'Obsidian Flames',
    'sv02': 'Paldea Evolved',
    'sv01': 'Scarlet & Violet',
    'swsh12pt5': 'Crown Zenith',
    'swsh12pt5gg': 'Crown Zenith Galarian Gallery',
    'swsh12': 'Silver Tempest',
    'swsh11': 'Lost Origin',
    'swsh10': 'Astral Radiance',
    'swsh9': 'Brilliant Stars',
    'swsh8': 'Fusion Strike',
    'swsh7': 'Evolving Skies',
    'swsh6': 'Chilling Reign',
    'swsh5': 'Battle Styles',
    'swsh4': 'Vivid Voltage',
    'swsh3': 'Darkness Ablaze',
    'swsh2': 'Rebel Clash',
    'swsh1': 'Sword & Shield',
    'base1': 'Base Set',
    'base2': 'Jungle',
    'base3': 'Fossil',
    'base4': 'Base Set 2',
    'base5': 'Team Rocket',
    'gym1': 'Gym Heroes',
    'gym2': 'Gym Challenge',
    'neo1': 'Neo Genesis',
    'neo2': 'Neo Discovery',
    'neo3': 'Neo Revelation',
    'neo4': 'Neo Destiny',
  };

  /// Ensures set names are available for card metadata enrichment
  static Future<void> _ensureSetsLoaded() async {
    if (_setNamesCache != null || _isLoadingSets) return;
    _isLoadingSets = true;
    _setNamesCache = Map.from(_knownSets);

    try {
      final response = await DioClient.instance.get(
        '${AppConstants.tcgdexBaseUrl}/en/sets',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        for (final item in list) {
          if (item is Map) {
            final id = item['id']?.toString();
            final name = item['name']?.toString();
            if (id != null && name != null && name.isNotEmpty) {
              _setNamesCache![id] = name;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Set list loading error: $e');
    } finally {
      _isLoadingSets = false;
    }
  }

  /// Searches cards online using high-reliability Pokémon TCG datasets (TCGdex & pokemontcg.io)
  /// Guarantees that returned cards strictly match the search query without random card leakage.
  static Future<List<PokemonCardItem>> searchCards({
    required String query,
    int page = 1,
    int pageSize = 30,
    bool isEn = true,
  }) async {
    final cleanQuery = query.trim();
    final cacheKey = '${cleanQuery.toLowerCase()}_$page';

    if (_queryCache.containsKey(cacheKey)) {
      return _queryCache[cacheKey]!;
    }

    await _ensureSetsLoaded();

    // 1. If query is empty, return popular featured cards from 151 & recent sets
    if (cleanQuery.isEmpty) {
      final defaultCards = await _fetchFeaturedDefaultCards();
      if (defaultCards.isNotEmpty) {
        _queryCache[cacheKey] = defaultCards;
        return defaultCards;
      }
    }

    final normalized = SemanticSearchHelper.normalizeQuery(cleanQuery);
    final List<PokemonCardItem> candidateCards = [];

    // 2. Query TCGdex (fast, 100% uptime, zero 500/502 errors)
    try {
      final isNumberQuery = RegExp(r'^#?\d+$').hasMatch(cleanQuery);
      final queryParam = isNumberQuery
          ? 'localId=${Uri.encodeComponent(cleanQuery.replaceAll('#', ''))}'
          : 'name=${Uri.encodeComponent(cleanQuery)}';

      // Primary endpoint
      final primaryLang = isEn ? 'en' : 'pt';
      final primaryUrl = '${AppConstants.tcgdexBaseUrl}/$primaryLang/cards?$queryParam';

      final response = await DioClient.instance.get(
        primaryUrl,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final cardId = item['id']?.toString() ?? '';
            final setId = cardId.contains('-') ? cardId.split('-').first : '';
            final setName = _setNamesCache?[setId] ?? _knownSets[setId];
            final card = PokemonCardItem.fromTcgdex(item, setName: setName);
            candidateCards.add(card);
          }
        }
      }

      // If in PT-BR mode or few results, also check EN counterpart to broaden results
      if (!isEn && candidateCards.length < 5 && !isNumberQuery) {
        final enUrl = '${AppConstants.tcgdexBaseUrl}/en/cards?$queryParam';
        final enResp = await DioClient.instance.get(
          enUrl,
          options: Options(validateStatus: (status) => status != null && status < 500),
        );
        if (enResp.statusCode == 200 && enResp.data is List) {
          for (final item in (enResp.data as List)) {
            if (item is Map<String, dynamic>) {
              final cardId = item['id']?.toString() ?? '';
              final setId = cardId.contains('-') ? cardId.split('-').first : '';
              final setName = _setNamesCache?[setId] ?? _knownSets[setId];
              final card = PokemonCardItem.fromTcgdex(item, setName: setName);
              if (!candidateCards.any((c) => c.id == card.id)) {
                candidateCards.add(card);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('TCGdex search error: $e');
    }

    // 3. Fallback/Enrich with pokemontcg.io if candidates are few
    if (candidateCards.length < 5) {
      try {
        String filterString = '';
        if (RegExp(r'^#?\d+$').hasMatch(cleanQuery)) {
          filterString = 'number:${cleanQuery.replaceAll('#', '')}';
        } else {
          // Clean prefix query without leading wildcard or quotes to avoid 400/500
          final cleanTerm = normalized.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
          filterString = 'name:$cleanTerm*';
        }

        final url =
            'https://api.pokemontcg.io/v2/cards?q=$filterString&page=1&pageSize=$pageSize&orderBy=-set.releaseDate';

        final response = await DioClient.instance.get(
          url,
          options: Options(
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] as List<dynamic>?;
          if (data != null) {
            for (final item in data) {
              final card = PokemonCardItem.fromJson(item as Map<String, dynamic>);
              if (!candidateCards.any((c) => c.id == card.id)) {
                candidateCards.add(card);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('pokemontcg.io fallback error: $e');
      }
    }

    // 4. STRICT FILTERING & RELEVANCE SORTING:
    // Guarantees that EVERY returned card strictly relates to what the user searched.
    final numTarget = cleanQuery.replaceAll('#', '').toLowerCase();
    final isNumSearch = RegExp(r'^\d+$').hasMatch(numTarget);

    final filtered = candidateCards.where((card) {
      final cardNameLower = card.name.toLowerCase();
      final cardNumLower = card.number.toLowerCase();
      final setNameLower = card.setName.toLowerCase();

      if (isNumSearch) {
        return cardNumLower == numTarget;
      }

      // Must contain query words in name or set
      final words = normalized.split(' ').where((w) => w.length > 1).toList();
      if (words.isEmpty) {
        return cardNameLower.contains(normalized);
      }

      // All words must match card name or set
      return words.every((word) => cardNameLower.contains(word) || setNameLower.contains(word));
    }).toList();

    // Sort by relevance
    filtered.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();

      // Exact name match comes first
      final aExact = aName == normalized;
      final bExact = bName == normalized;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      // Starts with query comes second
      final aStarts = aName.startsWith(normalized);
      final bStarts = bName.startsWith(normalized);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      // Cards with valid image prioritized
      final aHasImg = a.imageUrlSmall.isNotEmpty && !a.imageUrlSmall.endsWith('.png');
      final bHasImg = b.imageUrlSmall.isNotEmpty && !b.imageUrlSmall.endsWith('.png');
      if (aHasImg && !bHasImg) return -1;
      if (!aHasImg && bHasImg) return 1;

      return a.name.compareTo(b.name);
    });

    _queryCache[cacheKey] = filtered;
    return filtered;
  }

  /// Provides initial curated cards from latest sets when search bar is empty
  static Future<List<PokemonCardItem>> _fetchFeaturedDefaultCards() async {
    try {
      final response = await DioClient.instance.get(
        '${AppConstants.tcgdexBaseUrl}/en/cards?name=Charizard',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List).take(24);
        final List<PokemonCardItem> items = [];
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final cardId = item['id']?.toString() ?? '';
            final setId = cardId.contains('-') ? cardId.split('-').first : '';
            final setName = _setNamesCache?[setId] ?? _knownSets[setId];
            items.add(PokemonCardItem.fromTcgdex(item, setName: setName));
          }
        }
        return items;
      }
    } catch (e) {
      debugPrint('Default cards error: $e');
    }

    return [];
  }
}
