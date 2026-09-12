import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/features/wishlist/presentation/wishlist_screen.dart';

void main() {
  testWidgets('WishlistScreen shows folder dropdown and sort button', (tester) async {
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

    // Verify the folder filter is rendered below the statistics.
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.text('All Folders (2)'), findsOneWidget);

    // Verify sort icon exists in appbar
    expect(find.byIcon(Icons.sort), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsOneWidget);

    // Filter by "Sonhos"
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sonhos (1)').last);
    await tester.pump(const Duration(milliseconds: 500));

    // Only Charizard should be shown
    expect(find.textContaining('Charizard'), findsOneWidget);
    expect(find.textContaining('Pikachu'), findsNothing);
  });
}
