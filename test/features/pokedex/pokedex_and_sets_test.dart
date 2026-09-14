import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/utils/card_sorting_helper.dart';
import 'package:wurmdex/features/catalog/models/catalog_filter_state.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/pokedex/data/pokedex_data.dart';
import 'package:wurmdex/features/pokedex/models/pokedex_entry.dart';
import 'package:wurmdex/features/sets/models/tcg_set_item.dart';
import 'package:wurmdex/features/sets/services/tcg_sets_service.dart';

void main() {
  group('PokéDex Feature Tests', () {
    test('Contains canonical Pokémon entries across all 9 generations', () {
      expect(PokedexData.entries.length, 1025);

      final bulbasaur = PokedexData.entries.first;
      expect(bulbasaur.id, 1);
      expect(bulbasaur.name, 'Bulbasaur');
      expect(bulbasaur.generation, 1);
      expect(bulbasaur.formattedNumber, '#001');
      expect(
        bulbasaur.artworkUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
      );

      final pikachu = PokedexData.entries[24];
      expect(pikachu.id, 25);
      expect(pikachu.name, 'Pikachu');
      expect(pikachu.generation, 1);
      expect(pikachu.formattedNumber, '#025');

      final pecharunt = PokedexData.entries.last;
      expect(pecharunt.id, 1025);
      expect(pecharunt.name, 'Pecharunt');
      expect(pecharunt.generation, 9);
      expect(pecharunt.formattedNumber, '#1025');
    });

    test('PokedexEntry custom model formats number correctly', () {
      const entry = PokedexEntry(
        id: 6,
        name: 'Charizard',
        types: ['Fire', 'Flying'],
        generation: 1,
      );
      expect(entry.formattedNumber, '#006');
    });
  });

  group('Sets & Expansions Feature Tests', () {
    test('User Requirement: Set name shows (X) where X is the number of prints', () {
      const surgingSparks = TcgSetItem(
        id: 'sv08',
        name: 'Surging Sparks',
        totalCards: 252,
        officialCards: 191,
        year: 2024,
      );
      expect(surgingSparks.displayNameWithCount, 'Surging Sparks (252)');

      const baseSet = TcgSetItem(
        id: 'base1',
        name: 'Base Set',
        totalCards: 102,
        officialCards: 102,
        year: 1999,
      );
      expect(baseSet.displayNameWithCount, 'Base Set (102)');

      const set151 = TcgSetItem(
        id: 'sv03.5',
        name: '151',
        totalCards: 207,
        officialCards: 165,
        year: 2023,
      );
      expect(set151.displayNameWithCount, '151 (207)');
    });

    test('User Requirement: Sets are grouped and separated by year', () {
      final products = TcgSetsService.fetchProductsForSet(
        const TcgSetItem(
          id: 'sv08',
          name: 'Surging Sparks',
          totalCards: 252,
          year: 2024,
        ),
      );

      expect(products.isNotEmpty, true);
      expect(products.any((p) => p.name.contains('Elite Trainer Box')), true);
      expect(products.any((p) => p.name.contains('Booster Display Box')), true);
      expect(products.any((p) => p.name.contains('Booster Bundle')), true);
      expect(products.any((p) => p.name.contains('Ultra-Premium Collection')), true);
    });

    test('Bilingual strings for Pokedex and Sets are populated in En and Pt', () {
      const enStrings = AppStrings(AppLanguage.enUs);
      const ptStrings = AppStrings(AppLanguage.ptBr);

      expect(enStrings.navPokedex, 'WorldDex');
      expect(ptStrings.navPokedex, 'WorldDex');
      expect(enStrings.pokedexTitle, 'WorldDex');
      expect(ptStrings.pokedexTitle, 'DexMundial');
      expect(enStrings.dataSourcesTitle, 'Data Sources & Attribution');
      expect(ptStrings.dataSourcesTitle, 'Fontes de Dados & Atribuição');

      expect(enStrings.pokedexGen(1), 'Gen 1');
      expect(ptStrings.pokedexGen(1), 'Geração 1');

      expect(enStrings.pokedexCardsFor('Pikachu'), 'Cards for Pikachu');
      expect(ptStrings.pokedexCardsFor('Pikachu'), 'Cartas de Pikachu');

      expect(enStrings.navSets, 'Expansions');
      expect(ptStrings.navSets, 'Expansions');

      expect(enStrings.tabReleasedSets, 'Released Sets');
      expect(ptStrings.tabReleasedSets, 'Coleções Lançadas');

      expect(enStrings.tabUpcomingReleases, 'Upcoming Releases');
      expect(ptStrings.tabUpcomingReleases, 'Futuros Lançamentos');

      expect(enStrings.txtAllYears, 'All');
      expect(ptStrings.txtAllYears, 'Todos');
    });

    test('Sealed products feature real high-definition product images', () {
      final products = TcgSetsService.fetchProductsForSet(
        const TcgSetItem(
          id: 'sv08',
          name: 'Surging Sparks',
          totalCards: 252,
          year: 2024,
        ),
      );

      for (final p in products) {
        expect(p.imageUrl.startsWith('https://'), true);
        expect(
          p.imageUrl.endsWith('.jpg') || p.imageUrl.endsWith('.png'),
          true,
        );
      }

      final etb = products.firstWhere((p) => p.productType == 'Elite Trainer Box');
      expect(etb.imageUrl, contains('581898'));
    });
  });

  group('Card Sorting Helper Tests', () {
    final cardA = const PokemonCardItem(
      id: 'sv08-001',
      name: 'Applin',
      number: '1',
      setId: 'sv08',
      setName: 'Surging Sparks',
      rarity: 'Common',
      imageUrlSmall: 'https://img.test/1.png',
      imageUrlLarge: 'https://img.test/1.png',
      tcgMarketUsd: 0.15,
      types: ['Grass'],
      supertype: 'Pokémon',
      artist: 'Ken Sugimori',
    );

    final cardB = const PokemonCardItem(
      id: 'sv08-214',
      name: 'Pikachu ex',
      number: '214',
      setId: 'sv08',
      setName: 'Surging Sparks',
      rarity: 'Special Illustration Rare',
      imageUrlSmall: 'https://img.test/214.png',
      imageUrlLarge: 'https://img.test/214.png',
      tcgMarketUsd: 350.0,
      types: ['Lightning'],
      supertype: 'Pokémon',
      artist: 'Ken Sugimori',
    );

    final cardC = const PokemonCardItem(
      id: 'base1-4',
      name: 'Charizard',
      number: '4',
      setId: 'base1',
      setName: 'Base Set',
      rarity: 'Rare Holo',
      imageUrlSmall: 'https://img.test/4.png',
      imageUrlLarge: 'https://img.test/4.png',
      tcgMarketUsd: 250.0,
      types: ['Fire'],
      supertype: 'Pokémon',
      artist: 'Ken Sugimori',
    );

    test('Sorts by name ascending and descending', () {
      final asc = CardSortingHelper.sort([cardB, cardA, cardC], CatalogSortOption.nameAsc);
      expect(asc.map((c) => c.name).toList(), ['Applin', 'Charizard', 'Pikachu ex']);

      final desc = CardSortingHelper.sort([cardB, cardA, cardC], CatalogSortOption.nameDesc);
      expect(desc.map((c) => c.name).toList(), ['Pikachu ex', 'Charizard', 'Applin']);
    });

    test('Sorts by price descending and ascending', () {
      final desc = CardSortingHelper.sort([cardA, cardB, cardC], CatalogSortOption.priceDesc);
      expect(desc.map((c) => c.name).toList(), ['Pikachu ex', 'Charizard', 'Applin']);

      final asc = CardSortingHelper.sort([cardA, cardB, cardC], CatalogSortOption.priceAsc);
      expect(asc.map((c) => c.name).toList(), ['Applin', 'Charizard', 'Pikachu ex']);
    });

    test('Sorts by release date (estimated year)', () {
      final newest = CardSortingHelper.sort([cardC, cardB], CatalogSortOption.releaseDateDesc);
      expect(newest.first.name, 'Pikachu ex'); // 2024 vs 1999

      final oldest = CardSortingHelper.sort([cardB, cardC], CatalogSortOption.releaseDateAsc);
      expect(oldest.first.name, 'Charizard'); // 1999 vs 2024
    });

    test('Sorts by popularity / sales heuristic', () {
      final pop = CardSortingHelper.sort([cardA, cardB, cardC], CatalogSortOption.popularityDesc);
      // Pikachu ex has high price + Special Illustration Rare bonus
      expect(pop.first.name, 'Pikachu ex');
      expect(pop.last.name, 'Applin');
    });

    test('Sorts by card number numerically', () {
      const card10 = PokemonCardItem(
        id: 'sv08-010',
        name: 'Applin 10',
        number: '10',
        setId: 'sv08',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: '',
        imageUrlLarge: '',
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        types: ['Grass'],
      );
      const card2 = PokemonCardItem(
        id: 'sv08-002',
        name: 'Applin 2',
        number: '2',
        setId: 'sv08',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: '',
        imageUrlLarge: '',
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        types: ['Grass'],
      );
      final numSorted = CardSortingHelper.sort([card10, card2, cardA], CatalogSortOption.numberAsc);
      expect(numSorted.map((c) => c.number).toList(), ['1', '2', '10']);
    });

    test('Sort labels are translated in EN and PT', () {
      expect(CardSortingHelper.getSortLabel(CatalogSortOption.popularityDesc, true), 'Sales / Popularity');
      expect(CardSortingHelper.getSortLabel(CatalogSortOption.popularityDesc, false), 'Mais Vendidas / Popularidade');
      expect(CardSortingHelper.getSortLabel(CatalogSortOption.priceDesc, true), 'Price: High to Low');
      expect(CardSortingHelper.getSortLabel(CatalogSortOption.priceDesc, false), 'Maior Preço');
      expect(CardSortingHelper.getSortLabel(CatalogSortOption.releaseDateDesc, true), 'Release Date: Newest');
      expect(CardSortingHelper.getSortLabel(CatalogSortOption.releaseDateDesc, false), 'Lançamento: Mais Recentes');
    });
  });
}
