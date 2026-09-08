import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/constants/app_constants.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/widgets/pokemon_card_image.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/catalog/presentation/widgets/card_grid_item.dart';
import 'package:wurmdex/features/collections/presentation/widgets/collection_dashboard_widget.dart';
import 'package:wurmdex/features/collections/presentation/widgets/virtual_binder_view.dart';

void main() {
  group('Universal Card Aspect Ratio & Geometry Tests', () {
    test('Standard Pokémon Card aspect ratio matches 63x88mm physical cards', () {
      expect(AppConstants.pokemonCardAspectRatio, closeTo(63.0 / 88.0, 0.0001));
      expect(AppConstants.cardGridItemAspectRatio, 0.58);
      expect(AppConstants.binderSheetAspectRatio, 0.755);
    });

    testWidgets('CardGridItem renders card container with standard pokemonCardAspectRatio', (tester) async {
      const cardItem = PokemonCardItem(
        id: 'sv3pt5-25',
        name: 'Pikachu',
        number: '025',
        setId: 'sv3pt5',
        setName: '151',
        rarity: 'Common',
        imageUrlSmall: 'https://images.pokemontcg.io/sv3pt5/25.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv3pt5/25_hires.png',
        types: ['Lightning'],
        supertype: 'Pokémon',
        artist: 'Mitsuhiro Arita',
        tcgMarketUsd: 2.50,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 180,
                height: 310,
                child: CardGridItem(card: cardItem),
              ),
            ),
          ),
        ),
      );

      final aspectRatioFinder = find.byWidgetPredicate(
        (widget) => widget is AspectRatio && (widget.aspectRatio - AppConstants.pokemonCardAspectRatio).abs() < 0.001,
      );
      expect(aspectRatioFinder, findsOneWidget);
    });

    testWidgets('VirtualBinderView pockets maintain full card AspectRatio without clipping', (tester) async {
      final sampleCards = List.generate(
        9,
        (i) => UserCard(
          id: '${i + 1}',
          cardApiId: 'sv3pt5-$i',
          name: 'Pikachu $i',
          number: '0$i',
          setName: '151',
          rarity: 'Rare',
          imageUrl: 'https://images.pokemontcg.io/sv3pt5/$i.png',
          purchasePriceBrl: (i + 1) * 10.0,
          condition: 'NM',
          finish: 'Regular',
          language: 'PT',
          quantity: 1,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 900,
                height: 700,
                child: VirtualBinderView(
                  cards: sampleCards,
                  onAddCard: () {},
                  folderName: 'Vintage Portfolio',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final pocketAspectRatios = find.byWidgetPredicate(
        (widget) => widget is AspectRatio && (widget.aspectRatio - AppConstants.pokemonCardAspectRatio).abs() < 0.001,
      );
      // The open binder spread renders cards in pockets using the universal aspect ratio
      expect(pocketAspectRatios, findsWidgets);
    });

    testWidgets('CollectionDashboardWidget displays Top 10 most valuable cards', (tester) async {
      final cardsList = List.generate(
        15,
        (i) => UserCard(
          id: '${i + 1}',
          cardApiId: 'card-$i',
          name: 'Card $i',
          number: '$i',
          setName: 'Base Set',
          rarity: 'Holofoil Rare',
          imageUrl: 'https://images.pokemontcg.io/base/$i.png',
          purchasePriceBrl: (i + 1) * 20.0, // Ascending values
          condition: 'NM',
          finish: 'Regular',
          language: 'PT',
          quantity: 1,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CollectionDashboardWidget(cards: cardsList),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Header should say "TOP 10" and show card count 10
      expect(find.textContaining('TOP 10'), findsOneWidget);
      expect(find.textContaining('10 cards'), findsOneWidget);
    });

    testWidgets('PokemonCardImage renders full card without corner-clipping ClipRRect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PokemonCardImage(
              imageUrl: 'https://images.pokemontcg.io/sv3pt5/25.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );

      // PokemonCardImage must NOT wrap its card image in ClipRRect (preserving authentic printed corners)
      expect(find.byType(ClipRRect), findsNothing);
      expect(find.byType(PokemonCardImage), findsOneWidget);
    });

    testWidgets('CardGridItem renders 3-tier metadata layout: Name/Number top, Set middle, Condition/Price bottom', (tester) async {
      const cardItem = PokemonCardItem(
        id: 'sv3pt5-25',
        name: 'Pikachu',
        number: '025',
        setId: 'sv3pt5',
        setName: 'Scarlet & Violet 151',
        rarity: 'Common',
        imageUrlSmall: 'https://images.pokemontcg.io/sv3pt5/25.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv3pt5/25_hires.png',
        types: ['Lightning'],
        supertype: 'Pokémon',
        artist: 'Mitsuhiro Arita',
        tcgMarketUsd: 2.50,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 180,
                height: 310,
                child: CardGridItem(card: cardItem),
              ),
            ),
          ),
        ),
      );

      // Top line: Name & Number formatted as Pikachu(#025)
      expect(find.text('Pikachu(#025)'), findsOneWidget);
      // Middle line: Set name
      expect(find.text('Scarlet & Violet 151'), findsOneWidget);
      // Bottom line: Condition badge and price ($2.50)
      expect(find.text('NM'), findsOneWidget);
      expect(find.textContaining(r'$'), findsOneWidget);
    });
  });
}
