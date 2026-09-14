import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/utils/card_condition_helper.dart';
import 'package:wurmdex/core/widgets/condition_badge.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/catalog/presentation/widgets/card_grid_item.dart';
import 'package:wurmdex/features/collections/presentation/widgets/virtual_binder_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('CardConditionHelper Tests', () {
    test('Maps standard conditions to short abbreviations', () {
      expect(CardConditionHelper.getShortCondition('Near Mint'), 'NM');
      expect(CardConditionHelper.getShortCondition('NM'), 'NM');
      expect(CardConditionHelper.getShortCondition('near_mint'), 'NM');

      expect(CardConditionHelper.getShortCondition('Slightly Played'), 'SP');
      expect(CardConditionHelper.getShortCondition('SP'), 'SP');
      expect(CardConditionHelper.getShortCondition('EX'), 'SP');
      expect(CardConditionHelper.getShortCondition('Lightly Played'), 'SP');

      expect(CardConditionHelper.getShortCondition('Moderately Played'), 'MP');
      expect(CardConditionHelper.getShortCondition('MP'), 'MP');

      expect(CardConditionHelper.getShortCondition('Heavily Played'), 'HP');
      expect(CardConditionHelper.getShortCondition('HP'), 'HP');

      expect(CardConditionHelper.getShortCondition('Damaged'), 'DMG');
      expect(CardConditionHelper.getShortCondition('DMG'), 'DMG');
      expect(CardConditionHelper.getShortCondition('Danificada'), 'DMG');

      expect(CardConditionHelper.getShortCondition('Mint'), 'MINT');
      expect(CardConditionHelper.getShortCondition('Perfeita'), 'MINT');
    });

    test('Maps graded cards accurately with Graduada prefix', () {
      expect(CardConditionHelper.getShortCondition('PSA 10'), 'Graduada (PSA 10)');
      expect(CardConditionHelper.getShortCondition('BGS 9.5'), 'Graduada (BGS 9.5)');
      expect(CardConditionHelper.getShortCondition('CGC 10'), 'Graduada (CGC 10)');
      expect(CardConditionHelper.getShortCondition('Graduada (PSA 10)'), 'Graduada (PSA 10)');
    });

    test('Defaults null or empty to market standard NM', () {
      expect(CardConditionHelper.getShortCondition(null), 'NM');
      expect(CardConditionHelper.getShortCondition(''), 'NM');
      expect(CardConditionHelper.getShortCondition('   '), 'NM');
    });

    test('Calculates price multipliers relative to NM', () {
      expect(CardConditionHelper.getConditionMultiplier('NM'), 1.0);
      expect(CardConditionHelper.getConditionMultiplier('Near Mint'), 1.0);
      expect(CardConditionHelper.getConditionMultiplier('Slightly Played'), 0.85);
      expect(CardConditionHelper.getConditionMultiplier('Moderately Played'), 0.70);
      expect(CardConditionHelper.getConditionMultiplier('Heavily Played'), 0.50);
      expect(CardConditionHelper.getConditionMultiplier('Damaged'), 0.30);
      expect(CardConditionHelper.getConditionMultiplier('Mint'), 1.10);
      expect(CardConditionHelper.getConditionMultiplier('PSA 10'), 3.5);
    });

    test('Returns distinctive colors for conditions', () {
      expect(CardConditionHelper.getConditionColor('NM'), isA<Color>());
      expect(CardConditionHelper.getConditionColor('SP'), isA<Color>());
      expect(CardConditionHelper.getConditionColor('MP'), isA<Color>());
      expect(CardConditionHelper.getConditionColor('HP'), isA<Color>());
      expect(CardConditionHelper.getConditionColor('DMG'), isA<Color>());
      expect(CardConditionHelper.getConditionColor('MINT'), isA<Color>());
      expect(CardConditionHelper.getConditionColor('Graduada (PSA 10)'), isA<Color>());
    });
  });

  group('ConditionBadge Widget Tests', () {
    testWidgets('Renders NM condition badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConditionBadge(condition: 'Near Mint'),
          ),
        ),
      );

      expect(find.text('NM'), findsOneWidget);
    });

    testWidgets('Renders SP condition badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConditionBadge(condition: 'Slightly Played', compact: true),
          ),
        ),
      );

      expect(find.text('SP'), findsOneWidget);
    });

    testWidgets('Renders Graduada badge with premium icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConditionBadge(condition: 'PSA 10'),
          ),
        ),
      );

      expect(find.text('Graduada (PSA 10)'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });
  });

  group('CardGridItem Condition Badge Tests', () {
    testWidgets('CardGridItem shows NM by default for catalog price', (tester) async {
      const mockCard = PokemonCardItem(
        id: 'test-card-1',
        name: 'Charizard ex',
        number: '199',
        setId: 'obf',
        setName: 'Obsidian Flames',
        rarity: 'Special Illustration Rare',
        imageUrlSmall: 'https://example.com/small.png',
        imageUrlLarge: 'https://example.com/large.png',
        types: ['Fire'],
        supertype: 'Pokémon',
        artist: 'AKIRA EGAWA',
        tcgMarketUsd: 55.0,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: CardGridItem(card: mockCard),
              ),
            ),
          ),
        ),
      );

      // Verify the NM badge appears next to the price
      expect(find.text('NM'), findsOneWidget);
    });

    testWidgets('CardGridItem shows custom condition when owned (e.g. SP)', (tester) async {
      const mockCard = PokemonCardItem(
        id: 'test-card-2',
        name: 'Gengar VMAX',
        number: '157',
        setId: 'fs',
        setName: 'Fusion Strike',
        rarity: 'Secret Rare',
        imageUrlSmall: 'https://example.com/small2.png',
        imageUrlLarge: 'https://example.com/large2.png',
        types: ['Psychic'],
        supertype: 'Pokémon',
        artist: 'sowsow',
        tcgMarketUsd: 180.0,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: CardGridItem(
                  card: mockCard,
                  isOwned: true,
                  condition: 'Slightly Played',
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the SP badge is displayed
      expect(find.text('SP'), findsOneWidget);
    });
  });

  group('VirtualBinderView Sticker Tests', () {
    testWidgets('VirtualBinderView renders adhesive tape sticker with folder name', (tester) async {
      final mockCards = [
        UserCard(
          id: 'uc1',
          cardApiId: 'base1-4',
          name: 'Charizard',
          number: '4',
          setName: 'Base Set',
          rarity: 'Rare Holo',
          imageUrl: 'https://example.com/charizard.png',
          folderId: 'f1',
          condition: 'Near Mint',
          language: 'PT',
          finish: 'Holofoil',
          quantity: 1,
          purchasePriceBrl: 450.0,
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 900,
                child: VirtualBinderView(
                  cards: mockCards,
                  folderName: 'Minhas Cartas Raras',
                  onAddCard: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the sticker text is rendered
      expect(find.text('Minhas Cartas Raras'), findsOneWidget);

      // Verify the card's condition badge inside the binder pocket is rendered
      expect(find.text('NM'), findsOneWidget);
    });

    testWidgets('VirtualBinderView flips page over the 6 rings on next button click', (tester) async {
      // 12 cards -> 2 pages (9 cards per page)
      final mockCards = List.generate(
        12,
        (i) => UserCard(
          id: 'card_$i',
          cardApiId: 'api_$i',
          name: 'Card $i',
          number: '$i',
          setName: 'Base Set',
          rarity: 'Common',
          imageUrl: 'https://example.com/$i.png',
          folderId: 'f1',
          condition: 'Near Mint',
          language: 'PT',
          finish: 'Regular',
          quantity: 1,
          purchasePriceBrl: 10.0,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 900,
                child: VirtualBinderView(
                  cards: mockCards,
                  folderName: 'Coleção Teste',
                  onAddCard: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Initially on page 1 of 2 (in default English or Portuguese)
      final page1Finder = find.textContaining('1 of 2');
      final page1AltFinder = find.textContaining('1 de 2');
      expect(page1Finder.evaluate().isNotEmpty || page1AltFinder.evaluate().isNotEmpty, isTrue);

      // Click next page button
      final nextButton = find.byIcon(Icons.arrow_forward);
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);

      // Pump animation frames of the 3D ring flip
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 250));

      // Page is now 2 of 2
      final page2Finder = find.textContaining('2 of 2');
      final page2AltFinder = find.textContaining('2 de 2');
      expect(page2Finder.evaluate().isNotEmpty || page2AltFinder.evaluate().isNotEmpty, isTrue);
    });
  });
}

