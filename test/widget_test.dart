import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/localization/app_language.dart';
import 'package:wurmdex/features/collections/presentation/widgets/virtual_binder_view.dart';
import 'package:wurmdex/main.dart';

void main() {
  testWidgets('WurmDexApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WurmDexApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('WurmDex Catalog'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('HomeScreen features persistent search bar, news and price alerts without trending cards or tags', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WurmDexApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify search bar is directly visible at the top of the menu
    expect(find.byType(TextField), findsOneWidget);
    // Verify My Collections button has been removed from menu
    expect(find.text('View Collection'), findsNothing);

    // Verify trending cards section is removed
    expect(find.text('TRENDING CARDS RIGHT NOW'), findsNothing);

    // Verify news section is present
    expect(find.text('POKÉMON TCG NEWS & SCENE'), findsOneWidget);

    // Verify ready-made tags are NOT present as chips
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);

    // Enter search text to activate search mode
    await tester.enterText(find.byType(TextField), 'Charizard');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Home'), findsOneWidget);

    // Tap 'Home' to return to home dashboard
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextField), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Switching language to pt-BR updates UI dynamically', (WidgetTester tester) async {
    final container = ProviderContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WurmDexApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(TextField), findsOneWidget);

    container.read(languageProvider.notifier).setLanguage(AppLanguage.ptBr);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('NOTÍCIAS & CENÁRIO DO POKÉMON TCG'), findsOneWidget);
  });

  testWidgets('VirtualBinderView renders and supports pagination and scroll', (WidgetTester tester) async {
    final mockCards = List.generate(
      15,
      (i) => UserCard(
        id: 'card_$i',
        cardApiId: 'api_$i',
        name: 'Pikachu $i',
        number: '$i',
        setName: 'Base Set',
        rarity: 'Common',
        imageUrl: 'https://images.pokemontcg.io/base1/$i.png',
        folderId: null,
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
                onAddCard: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Verify page 1 indicator (15 cards = 2 pages of 9 cards)
    expect(find.text('Page 1 of 2'), findsOneWidget);

    // Tap next button
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // Verify page 2 indicator
    expect(find.text('Page 2 of 2'), findsOneWidget);

    // Tap previous button
    await tester.tap(find.text('Previous'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Page 1 of 2'), findsOneWidget);
  });
}
