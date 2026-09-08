import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/features/monitoring/models/monitored_card_item.dart';
import 'package:wurmdex/features/monitoring/presentation/price_monitoring_screen.dart';
import 'package:wurmdex/features/monitoring/presentation/widgets/monitoring_kpi_card.dart';
import 'package:wurmdex/features/monitoring/services/price_monitoring_service.dart';

void main() {
  group('PriceMonitoringService Tests', () {
    final mockFolder1 = Folder(
      id: 'folder_1',
      name: 'Master Set 151',
      description: 'Cartas da colecao 151',
      colorTag: '#7C3AED',
      iconName: 'folder',
      displayMode: 'binder',
      createdAt: DateTime.now(),
    );

    final mockFolder2 = Folder(
      id: 'folder_2',
      name: 'Decks Competitivos',
      description: '',
      colorTag: '#10B981',
      iconName: 'flash_on',
      displayMode: 'grid',
      createdAt: DateTime.now(),
    );

    final mockCards = [
      UserCard(
        id: 'c1',
        cardApiId: 'sv3pt5-199',
        name: 'Charizard ex',
        number: '199',
        setName: '151',
        rarity: 'Special Illustration Rare',
        imageUrl: 'https://example.com/charizard.png',
        folderId: 'folder_1',
        condition: 'Near Mint',
        language: 'PT',
        finish: 'Holofoil',
        quantity: 1,
        purchasePriceBrl: 450.0,
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: 'c2',
        cardApiId: 'sv3pt5-25',
        name: 'Pikachu',
        number: '25',
        setName: '151',
        rarity: 'Illustration Rare',
        imageUrl: 'https://example.com/pikachu.png',
        folderId: 'folder_1',
        condition: 'Graduada (PSA 10)',
        language: 'PT',
        finish: 'Holofoil',
        quantity: 2,
        purchasePriceBrl: 80.0,
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: 'c3',
        cardApiId: 'base1-4',
        name: 'Charizard',
        number: '4',
        setName: 'Base Set',
        rarity: 'Rare Holo',
        imageUrl: 'https://example.com/base_charizard.png',
        folderId: null, // General collection
        condition: 'Slightly Played',
        language: 'EN',
        finish: 'Holofoil',
        quantity: 1,
        purchasePriceBrl: 600.0,
        createdAt: DateTime.now(),
      ),
    ];

    test('Maps folder association and calculates market price correctly', () {
      final items = PriceMonitoringService.generateMonitoredItems(
        cards: mockCards,
        folders: [mockFolder1, mockFolder2],
      );

      expect(items.length, 3);

      final charizard151 = items.firstWhere((i) => i.card.id == 'c1');
      expect(charizard151.folderName, 'Master Set 151');
      expect(charizard151.purchasePriceBrl, 450.0);
      expect(charizard151.estimatedCurrentPriceBrl, greaterThan(0));

      final pikachu = items.firstWhere((i) => i.card.id == 'c2');
      expect(pikachu.folderName, 'Master Set 151');
      expect(pikachu.purchasePriceBrl, 80.0);
      expect(pikachu.estimatedCurrentPriceBrl, greaterThan(0));

      final baseCharizard = items.firstWhere((i) => i.card.id == 'c3');
      expect(baseCharizard.folderName, isNull);
      expect(baseCharizard.purchasePriceBrl, 600.0);
    });

    test('Assigns trend directions (surging, dropping, or stable)', () {
      final items = PriceMonitoringService.generateMonitoredItems(
        cards: mockCards,
        folders: [mockFolder1, mockFolder2],
      );

      for (final item in items) {
        if (item.percentageChange > 2.0) {
          expect(item.trendDirection, PriceTrendDirection.surging);
          expect(item.isSurging, isTrue);
        } else if (item.percentageChange < -2.0) {
          expect(item.trendDirection, PriceTrendDirection.dropping);
          expect(item.isDropping, isTrue);
        } else {
          expect(item.trendDirection, PriceTrendDirection.stable);
          expect(item.isStable, isTrue);
        }
      }
    });
  });

  group('PriceMonitoringScreen Widget Tests', () {
    testWidgets('Renders empty state when user has no cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userCardsStreamProvider.overrideWith((ref) => Stream.value([])),
            foldersStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: PriceMonitoringScreen(),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Price Monitoring'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('Renders collections selector, KPI summary and card tiles', (tester) async {
      final testFolder = Folder(
        id: 'f1',
        name: 'Minhas Raras',
        description: '',
        colorTag: '#7C3AED',
        iconName: 'folder',
        displayMode: 'grid',
        createdAt: DateTime.now(),
      );

      final testCard = UserCard(
        id: 'card_test',
        cardApiId: 'sv3pt5-199',
        name: 'Charizard ex',
        number: '199',
        setName: '151',
        rarity: 'Special Illustration Rare',
        imageUrl: 'https://example.com/charizard.png',
        folderId: 'f1',
        condition: 'Near Mint',
        language: 'PT',
        finish: 'Holofoil',
        quantity: 1,
        purchasePriceBrl: 400.0,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userCardsStreamProvider.overrideWith((ref) => Stream.value([testCard])),
            foldersStreamProvider.overrideWith((ref) => Stream.value([testFolder])),
          ],
          child: const MaterialApp(
            home: PriceMonitoringScreen(),
          ),
        ),
      );

      await tester.pump();

      // Top title
      expect(find.text('Price Monitoring'), findsOneWidget);

      // Collections selector chips
      expect(find.textContaining('All Collections'), findsOneWidget);
      expect(find.text('Minhas Raras (1)'), findsOneWidget);

      // KPI card
      expect(find.byType(MonitoringKpiCard), findsOneWidget);

      // Card row rendered
      expect(find.textContaining('Charizard'), findsOneWidget);
      expect(find.text('151'), findsOneWidget);
      expect(find.text('NM'), findsOneWidget);

      // Trend filter pills
      expect(find.text('All Cards'), findsOneWidget);
      expect(find.text('Surging (+)'), findsOneWidget);
      expect(find.text('Dropping (-)'), findsOneWidget);
      expect(find.text('Stable (±2%)'), findsOneWidget);
    });
  });
}
