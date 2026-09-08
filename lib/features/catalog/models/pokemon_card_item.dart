import '../../../core/utils/tcg_pricing_parser.dart';

class PokemonCardItem {
  final String id;
  final String name;
  final String number;
  final String? setTotal;
  final String setId;
  final String setName;
  final String rarity;
  final String imageUrlSmall;
  final String imageUrlLarge;
  final List<String> types;
  final String supertype;
  final String artist;
  final double? tcgMarketUsd;
  final double? tcgMidUsd;
  final double? tcgLowUsd;

  const PokemonCardItem({
    required this.id,
    required this.name,
    required this.number,
    this.setTotal,
    required this.setId,
    required this.setName,
    required this.rarity,
    required this.imageUrlSmall,
    required this.imageUrlLarge,
    required this.types,
    required this.supertype,
    required this.artist,
    this.tcgMarketUsd,
    this.tcgMidUsd,
    this.tcgLowUsd,
  });

  /// Returns true if an explicit price was returned by API pricing data
  bool get hasExplicitPrice =>
      (tcgMidUsd != null && tcgMidUsd! > 0) ||
      (tcgMarketUsd != null && tcgMarketUsd! > 0) ||
      (tcgLowUsd != null && tcgLowUsd! > 0);

  /// Returns the mid/average price as the primary reference price for the card,
  /// falling back to a realistic market baseline estimate based on rarity so the UI never displays '--'
  double? get effectiveMidPriceUsd {
    if (tcgMidUsd != null && tcgMidUsd! > 0) return tcgMidUsd;
    if (tcgMarketUsd != null && tcgMarketUsd! > 0) return tcgMarketUsd;
    if (tcgLowUsd != null && tcgLowUsd! > 0) return tcgLowUsd;
    return estimatedPriceUsd;
  }

  /// Estimated market baseline price in USD based on card rarity when API pricing is absent
  double get estimatedPriceUsd {
    final r = rarity.toLowerCase().trim();
    if (r.contains('secret') || r.contains('hiper') || r.contains('special illustration') || r.contains('special art')) {
      return 22.50;
    }
    if (r.contains('illustration') || r.contains('ilustração') || r.contains('galerie') || r.contains('trainer gallery')) {
      return 8.90;
    }
    if (r.contains('ultra') || r.contains('ace spec') || r.contains('rainbow') || r.contains('ouro') || r.contains('gold')) {
      return 6.50;
    }
    if (r.contains('double') || r.contains('dupla') || r.contains('radiant') || r.contains('radiante') || r.contains('amazing')) {
      return 2.80;
    }
    if (r.contains('holo') || r.contains('holográfica') || r.contains('shining') || r.contains('promo')) {
      return 1.80;
    }
    if (r.contains('rare') || r.contains('rara')) {
      return 0.95;
    }
    if (r.contains('uncommon') || r.contains('incomum')) {
      return 0.45;
    }
    // Common / Comum / Default
    return 0.25;
  }

  PokemonCardItem copyWith({
    String? id,
    String? name,
    String? supertype,
    String? number,
    String? setId,
    String? setName,
    String? setTotal,
    String? rarity,
    String? imageUrlSmall,
    String? imageUrlLarge,
    List<String>? types,
    String? artist,
    double? tcgMarketUsd,
    double? tcgMidUsd,
    double? tcgLowUsd,
  }) {
    return PokemonCardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      supertype: supertype ?? this.supertype,
      number: number ?? this.number,
      setId: setId ?? this.setId,
      setName: setName ?? this.setName,
      setTotal: setTotal ?? this.setTotal,
      rarity: rarity ?? this.rarity,
      imageUrlSmall: imageUrlSmall ?? this.imageUrlSmall,
      imageUrlLarge: imageUrlLarge ?? this.imageUrlLarge,
      types: types ?? this.types,
      artist: artist ?? this.artist,
      tcgMarketUsd: tcgMarketUsd ?? this.tcgMarketUsd,
      tcgMidUsd: tcgMidUsd ?? this.tcgMidUsd,
      tcgLowUsd: tcgLowUsd ?? this.tcgLowUsd,
    );
  }

  factory PokemonCardItem.fromJson(Map<String, dynamic> json) {
    final setInfo = json['set'] as Map<String, dynamic>?;
    final images = json['images'] as Map<String, dynamic>?;
    final tcgPlayer = json['tcgplayer'] as Map<String, dynamic>?;
    final prices = tcgPlayer?['prices'] as Map<String, dynamic>?;

    double? marketPrice;
    double? midPrice;
    double? lowPrice;

    if (prices != null) {
      // Prices can be in holofoil, reverseHolofoil, normal, 1stEditionHolofoil, etc.
      for (final type in ['holofoil', 'normal', 'reverseHolofoil', '1stEditionHolofoil']) {
        if (prices[type] != null) {
          final p = prices[type] as Map<String, dynamic>;
          marketPrice ??= (p['market'] as num?)?.toDouble();
          midPrice ??= (p['mid'] as num?)?.toDouble();
          lowPrice ??= (p['low'] as num?)?.toDouble();
        }
      }
    }

    return PokemonCardItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Desconhecido',
      number: json['number'] as String? ?? '',
      setTotal: setInfo?['printedTotal']?.toString(),
      setId: setInfo?['id'] as String? ?? '',
      setName: setInfo?['name'] as String? ?? '',
      rarity: json['rarity'] as String? ?? 'Comum',
      imageUrlSmall: images?['small'] as String? ?? 'https://images.pokemontcg.io/${json['id']}.png',
      imageUrlLarge: images?['large'] as String? ?? images?['small'] as String? ?? '',
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      supertype: json['supertype'] as String? ?? 'Pokémon',
      artist: json['artist'] as String? ?? '',
      tcgMarketUsd: marketPrice,
      tcgMidUsd: midPrice,
      tcgLowUsd: lowPrice,
    );
  }

  factory PokemonCardItem.fromTcgdex(Map<String, dynamic> json, {String? setName}) {
    final id = json['id'] as String? ?? '';
    final localId = json['localId']?.toString() ?? '';
    final name = json['name'] as String? ?? 'Card';
    final image = json['image'] as String?;
    final small = image != null ? '$image/low.webp' : 'https://images.pokemontcg.io/$id.png';
    final large = image != null ? '$image/high.webp' : small;
    final setInfo = json['set'] as Map<String, dynamic>?;
    final rawSetId = setInfo?['id']?.toString() ?? (id.contains('-') ? id.split('-').first : '');
    final resolvedSetName = setName ?? setInfo?['name']?.toString() ?? rawSetId.toUpperCase();
    final rarity = json['rarity']?.toString() ?? 'Rara';
    final types = (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final category = json['category']?.toString() ?? 'Pokémon';

    final prices = TcgPricingParser.parsePricing(json['pricing'] as Map<String, dynamic>?);
    final market = prices.market;
    final mid = prices.mid;
    final low = prices.low;

    return PokemonCardItem(
      id: id,
      name: name,
      number: localId,
      setTotal: setInfo?['cardCount']?['total']?.toString(),
      setId: rawSetId,
      setName: resolvedSetName,
      rarity: rarity,
      imageUrlSmall: small,
      imageUrlLarge: large,
      types: types,
      supertype: category,
      artist: json['illustrator']?.toString() ?? '',
      tcgMarketUsd: market,
      tcgMidUsd: mid,
      tcgLowUsd: low,
    );
  }
}
