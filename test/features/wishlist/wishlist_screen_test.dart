import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/widgets/app_filter_modal.dart';
import 'package:wurmdex/core/widgets/folder_filter_bar.dart';
import 'package:wurmdex/features/wishlist/presentation/wishlist_screen.dart';

void main() {
  testWidgets('WishlistScreen moves folder filter to filter modal and removes FolderFilterBar', (tester) async {
    final mockItems = [
      WishlistItem(
        id: 'w1',
        cardApiId: 'c1',
        name: 'Charizard Base Set',
        number: '4/102',
        setName: 'Base Set',
        imageUrl: 'https://example.com/charizard.png',
        minTargetPriceBrl: 0.0,
        targetPriceBrl: 1500.0,
        priority: 'Alta',
        folderName: 'Sonhos',
        language: 'PT',
        isPreSale: false,
        condition: 'Near Mint',
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
        minTargetPriceBrl: 0.0,
        targetPriceBrl: 50000.0,
        priority: 'Média',
        folderName: 'Grails',
        language: 'PT',
        isPreSale: false,
        condition: 'Mint',
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

    // Verify rectangular FolderFilterBar is REMOVED from the body
    expect(find.byType(FolderFilterBar), findsNothing);

    // Verify sort icon exists in appbar
    expect(find.byIcon(Icons.sort), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsNothing);

    // Verify filter button exists in appbar
    final filterBtn = find.byType(AppFilterButton);
    expect(filterBtn, findsOneWidget);

    // Open filter modal dialog
    await tester.tap(filterBtn);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify folder chips exist in the filter modal
    expect(find.descendant(of: find.byType(Dialog), matching: find.text('Sonhos')), findsOneWidget);
    expect(find.descendant(of: find.byType(Dialog), matching: find.text('Grails')), findsOneWidget);

    // Filter by "Sonhos"
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Sonhos')));
    await tester.pump(const Duration(milliseconds: 300));

    // Close modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 300));

    // Only Charizard should be shown
    expect(find.textContaining('Charizard'), findsOneWidget);
    expect(find.textContaining('Pikachu'), findsNothing);

    // Verify active folder chip is shown in the body
    expect(find.byType(InputChip), findsOneWidget);
  });
}
