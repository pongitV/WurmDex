import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/features/sets/data/tcg_sets_data.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';

void main() {
  group('Digital Game (Pokemon TCG Pocket) Exclusion Tests', () {
    test('isDigitalGameSet correctly identifies Pocket and digital sets', () {
      // Pocket series A
      expect(TcgSetsData.isDigitalGameSet('A1'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('A1a'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('A2'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('A2a'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('A2b'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('A3'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('A4'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('P-A'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('p-a'), isTrue);

      // Pocket series B
      expect(TcgSetsData.isDigitalGameSet('B1'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('B1a'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('B2'), isTrue);

      // Explicit names / series
      expect(TcgSetsData.isDigitalGameSet('tcgp-01', 'Genetic Apex'), isTrue);
      expect(TcgSetsData.isDigitalGameSet('some_id', 'Pokémon TCG Pocket Set'), isTrue);
    });

    test('isDigitalGameSet preserves all physical Pokémon TCG sets', () {
      expect(TcgSetsData.isDigitalGameSet('base1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('base2'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('gym1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('neo1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('ecard1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('ex1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('bw1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('xy1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('sm1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('swsh1'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('sv01'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('sv08'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('sv08.5'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('sv09'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('sv10'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('me01'), isFalse);
      expect(TcgSetsData.isDigitalGameSet('me02'), isFalse);
    });

    test('isDigitalCard catches cards belonging to Pocket', () {
      final digitalCard = PokemonCardItem(
        id: 'A1-001',
        name: 'Bulbasaur',
        number: '001',
        setId: 'A1',
        setName: 'Genetic Apex',
        rarity: 'Common',
        imageUrlSmall: 'https://assets.tcgdex.net/en/tcgp/A1/001',
        imageUrlLarge: 'https://assets.tcgdex.net/en/tcgp/A1/001',
        types: const ['Grass'],
        supertype: 'Pokémon',
        artist: 'Unknown',
      );

      expect(
        TcgSetsData.isDigitalCard(
          cardId: digitalCard.id,
          setId: digitalCard.setId,
          setName: digitalCard.setName,
          imageUrlSmall: digitalCard.imageUrlSmall,
          imageUrlLarge: digitalCard.imageUrlLarge,
        ),
        isTrue,
      );

      final physicalCard = PokemonCardItem(
        id: 'sv08-001',
        name: 'Exeggutor',
        number: '001',
        setId: 'sv08',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: 'https://assets.tcgdex.net/en/sv/sv08/001/high.png',
        imageUrlLarge: 'https://assets.tcgdex.net/en/sv/sv08/001/high.png',
        types: const ['Grass'],
        supertype: 'Pokémon',
        artist: 'Unknown',
      );

      expect(
        TcgSetsData.isDigitalCard(
          cardId: physicalCard.id,
          setId: physicalCard.setId,
          setName: physicalCard.setName,
          imageUrlSmall: physicalCard.imageUrlSmall,
          imageUrlLarge: physicalCard.imageUrlLarge,
        ),
        isFalse,
      );
    });

    test('Wurmple mascot menu asset exists', () {
      final file = File('assets/images/wurmple_menu.png');
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(100));
    });
  });
}
