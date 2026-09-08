import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/features/wishlist/presentation/wishlist_screen.dart';

void main() {
  testWidgets('WishlistScreen shows folder filter chips and sort button', (tester) async {
    final mockItems = [
      WishlistItem(
        id: 'w1',
        cardApiId: 'c1',
        name: 'Charizard Base Set',
        number: '4/102',
        setName: 'Base Set',
        imageUrl: 'https://example.com/charizard.png',
        targetPriceBrl: 1500.0,
        priority: 'Alta',
        folderName: 'Sonhos',
        notes: '',
        createdAt: DateTime.now(),
      ),
      WishlistItem(
        id: 'w2',
        cardApiId: 'c2',
        name: 'Pikachu Illustrator',
        number: 'Promo',
        setName: 'Promos',
        imageUrl: 'https://example.com/pikachu.png',
        targetPriceBrl: 50000.0,
        priority: 'Média',
        folderName: 'Grails',
        notes: '',
        createdAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wishlistStreamProvider.overrideWith((ref) => Stream.value(mockItems)),
        ],
        child: const MaterialApp(
          home: WishlistScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify folders are rendered as chips
    expect(find.widgetWithText(FilterChip, 'All Folders (2)'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Sonhos (1)'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Grails (1)'), findsOneWidget);

    // Verify sort icon exists in appbar
    expect(find.byIcon(Icons.sort), findsOneWidget);

    // Filter by "Sonhos"
    await tester.tap(find.widgetWithText(FilterChip, 'Sonhos (1)'));
    await tester.pump(const Duration(milliseconds: 500));

    // Only Charizard should be shown
    expect(find.textContaining('Charizard'), findsOneWidget);
    expect(find.textContaining('Pikachu'), findsNothing);
  });
}

