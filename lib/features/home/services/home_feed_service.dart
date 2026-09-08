import '../../catalog/models/pokemon_card_item.dart';
import '../models/tcg_news_item.dart';
import 'tcg_news_service.dart';

class HomeFeedService {
  /// Trending cards in Brazil / LigaPokémon market (national staples and trends)
  static List<PokemonCardItem> getLigaPokemonTrendingCards() {
    return const [
      PokemonCardItem(
        id: 'sv3pt5-199',
        name: 'Charizard ex',
        number: '199',
        setTotal: '165',
        setId: 'sv3pt5',
        setName: '151',
        rarity: 'Especial Rara Ilustração',
        imageUrlSmall: 'https://images.pokemontcg.io/sv3pt5/199.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv3pt5/199_hires.png',
        types: ['Fogo'],
        supertype: 'Pokémon',
        artist: 'AKIRA EGAWA',
        tcgMarketUsd: 118.50,
      ),
      PokemonCardItem(
        id: 'sv8-238',
        name: 'Pikachu ex',
        number: '238',
        setTotal: '191',
        setId: 'sv8',
        setName: 'Faíscas Impetuosas',
        rarity: 'Rara Hiper',
        imageUrlSmall: 'https://images.pokemontcg.io/sv8/238.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv8/238_hires.png',
        types: ['Elétrico'],
        supertype: 'Pokémon',
        artist: '5ban Graphics',
        tcgMarketUsd: 145.00,
      ),
      PokemonCardItem(
        id: 'sv6pt5-092',
        name: 'Fezandipiti ex',
        number: '092',
        setTotal: '064',
        setId: 'sv6pt5',
        setName: 'Fábulas Nebulosas',
        rarity: 'Especial Rara Ilustração',
        imageUrlSmall: 'https://images.pokemontcg.io/sv6pt5/92.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv6pt5/92_hires.png',
        types: ['Psíquico'],
        supertype: 'Pokémon',
        artist: 'Atsushi Furusawa',
        tcgMarketUsd: 68.00,
      ),
      PokemonCardItem(
        id: 'sv3pt5-151',
        name: 'Mew ex',
        number: '151',
        setTotal: '165',
        setId: 'sv3pt5',
        setName: '151',
        rarity: 'Dupla Rara',
        imageUrlSmall: 'https://images.pokemontcg.io/sv3pt5/151.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv3pt5/151_hires.png',
        types: ['Psíquico'],
        supertype: 'Pokémon',
        artist: 'PLANETA Mochizuki',
        tcgMarketUsd: 18.50,
      ),
      PokemonCardItem(
        id: 'swsh11-177',
        name: 'Rotom V',
        number: '177',
        setTotal: '196',
        setId: 'swsh11',
        setName: 'Origem Perdida',
        rarity: 'Rara Ultra Arte Alternativa',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh11/177.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh11/177_hires.png',
        types: ['Elétrico'],
        supertype: 'Pokémon',
        artist: 'Yuka Morii',
        tcgMarketUsd: 42.00,
      ),
    ];
  }

  /// Trending cards in Global / TCGPlayer market (international top volume and chase)
  static List<PokemonCardItem> getTcgPlayerTrendingCards() {
    return const [
      PokemonCardItem(
        id: 'swsh7-215',
        name: 'Umbreon VMAX',
        number: '215',
        setTotal: '203',
        setId: 'swsh7',
        setName: 'Evolving Skies',
        rarity: 'Secret Rare Alt Art',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh7/215.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh7/215_hires.png',
        types: ['Darkness'],
        supertype: 'Pokémon',
        artist: 'kawayoo',
        tcgMarketUsd: 680.00,
      ),
      PokemonCardItem(
        id: 'swsh8-271',
        name: 'Gengar VMAX',
        number: '271',
        setTotal: '264',
        setId: 'swsh8',
        setName: 'Fusion Strike',
        rarity: 'Special Art Rare',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh8/271.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh8/271_hires.png',
        types: ['Darkness'],
        supertype: 'Pokémon',
        artist: 'sowsow',
        tcgMarketUsd: 310.00,
      ),
      PokemonCardItem(
        id: 'swsh12pt5gg-GG69',
        name: 'Giratina VSTAR',
        number: 'GG69',
        setTotal: 'GG70',
        setId: 'swsh12pt5gg',
        setName: 'Crown Zenith',
        rarity: 'Galarian Gallery',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh12pt5gg/GG69.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh12pt5gg/GG69_hires.png',
        types: ['Dragon'],
        supertype: 'Pokémon',
        artist: 'Shinji Kanda',
        tcgMarketUsd: 132.20,
      ),
      PokemonCardItem(
        id: 'sv6-214',
        name: 'Greninja ex',
        number: '214',
        setTotal: '167',
        setId: 'sv6',
        setName: 'Twilight Masquerade',
        rarity: 'Special Illustration Rare',
        imageUrlSmall: 'https://images.pokemontcg.io/sv6/214.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv6/214_hires.png',
        types: ['Fighting'],
        supertype: 'Pokémon',
        artist: 'SIE NANAHARA',
        tcgMarketUsd: 260.00,
      ),
      PokemonCardItem(
        id: 'swsh7-218',
        name: 'Rayquaza VMAX',
        number: '218',
        setTotal: '203',
        setId: 'swsh7',
        setName: 'Evolving Skies',
        rarity: 'Secret Rare Alt Art',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh7/218.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh7/218_hires.png',
        types: ['Dragon'],
        supertype: 'Pokémon',
        artist: 'Ryuta Fuse',
        tcgMarketUsd: 410.00,
      ),
    ];
  }

  static List<PokemonCardItem> getTrendingCards() {
    return getLigaPokemonTrendingCards();
  }

  static Future<List<TcgNewsItem>> getLatestNews({bool forceRefresh = false}) {
    return TcgNewsService.fetchLiveNews(forceRefresh: forceRefresh);
  }
}
