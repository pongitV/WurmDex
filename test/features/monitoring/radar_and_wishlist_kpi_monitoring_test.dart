import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/core/widgets/kpi_stat_card.dart';
import 'package:wurmdex/features/monitoring/presentation/widgets/radar_background_settings_sheet.dart';
import 'package:wurmdex/features/monitoring/presentation/widgets/radar_kpi_summary.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/features/monitoring/presentation/liga_radar_screen.dart';
import 'package:wurmdex/features/wishlist/presentation/widgets/wishlist_background_settings_dialog.dart';
import 'package:wurmdex/features/wishlist/presentation/widgets/wishlist_kpi_summary.dart';

void main() {
  group('Standardized KPI Statistics Tests (LigaRadar & Wishlist)', () {
    testWidgets('RadarKpiSummary displays Valor total banner, then In range, Atualizados hoje, and Quantidade de produtos',
        (WidgetTester tester) async {
      final strings = getStrings(AppLanguage.ptBr);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RadarKpiSummary(
              totalInRange: 5,
              totalPrice: 450.0,
              updatedToday: 7,
              totalProducts: 12,
              isInRangeSelected: false,
              onToggleInRange: () {},
              onToggleProducts: () {},
              isUsd: false,
              exchangeRate: 5.5,
              strings: strings,
            ),
          ),
        ),
      );

      // Banner: Valor total (full-width rectangular card)
      expect(find.text(strings.kpiTotalPrice), findsOneWidget);
      expect(find.text(CurrencyFormatter.toBrl(450.0)), findsOneWidget);

      // Row: In range | Atualizados hoje | Quantidade de produtos
      expect(find.text(strings.kpiInRangeTotal), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      expect(find.text(strings.kpiUpdatedToday), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      expect(find.text(strings.kpiQuantityProducts), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('WishlistKpiSummary displays Preço total banner, then In range, Atualizadas hoje, and Quantidade de cartas',
        (WidgetTester tester) async {
      final strings = getStrings(AppLanguage.ptBr);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WishlistKpiSummary(
              inRangeCount: 3,
              totalPrice: 1200.0,
              updatedToday: 4,
              totalCards: 8,
              isInRangeSelected: false,
              onToggleInRange: () {},
              isUsd: false,
              exchangeRate: 5.5,
              strings: strings,
            ),
          ),
        ),
      );

      // Banner: Preço total (full-width rectangular card)
      expect(find.text(strings.kpiTotalPrice), findsOneWidget);
      expect(find.text(CurrencyFormatter.toBrl(1200.0)), findsOneWidget);

      // Row: In range | Atualizadas hoje | Quantidade de cartas
      expect(find.text(strings.kpiInRangeTotal), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      expect(find.text(strings.kpiUpdatedToday), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      expect(find.text(strings.kpiQuantityCards), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('KPI cards support USD currency conversion', (WidgetTester tester) async {
      final strings = getStrings(AppLanguage.enUs);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RadarKpiSummary(
              totalInRange: 2,
              totalPrice: 55.0,
              updatedToday: 1,
              totalProducts: 4,
              isInRangeSelected: true,
              onToggleInRange: () {},
              onToggleProducts: () {},
              isUsd: true,
              exchangeRate: 5.5,
              strings: strings,
            ),
          ),
        ),
      );

      expect(find.text('In Range'), findsOneWidget);
      expect(find.text('Updated today'), findsOneWidget);
      expect(find.text('\$10.00'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
    });
  });

  group('Background Monitoring Checkbox Tests', () {
    testWidgets('RadarBackgroundSettingsSheet uses CheckboxListTile instead of Switch',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RadarBackgroundSettingsSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // CheckboxListTile must be present
      expect(find.byType(CheckboxListTile), findsOneWidget);
      // Switch / SwitchListTile must NOT be present
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('WishlistBackgroundSettingsDialog uses CheckboxListTile instead of Switch',
        (WidgetTester tester) async {
      final strings = getStrings(AppLanguage.ptBr);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WishlistBackgroundSettingsDialog(
              initialEnabled: false,
              onToggle: (_) {},
              strings: strings,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // CheckboxListTile must be present
      expect(find.byType(CheckboxListTile), findsOneWidget);
      // Switch / SwitchListTile must NOT be present
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(SwitchListTile), findsNothing);
    });
  });

  group('LigaRadarScreen Rectangular Buttons Removal Tests', () {
    testWidgets('LigaRadarScreen does NOT display rectangular Check prices and Background monitoring buttons',
        (WidgetTester tester) async {
      final mockAlerts = [
        LigaPriceAlert(
          id: 'alert1',
          targetUrl: 'https://example.com/item1',
          title: 'Charizard Box',
          imageUrl: '',
          minTargetPrice: 100.0,
          maxTargetPrice: 200.0,
          allowPreSale: true,
          isActive: true,
          currentLowestPrice: 150.0,
          currentStoreName: 'Loja Teste',
          isPreSale: false,
          isAvailableInRange: true,
          collectionTag: '151',
          languageTag: 'PT',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ligaAlertsStreamProvider.overrideWith((ref) => Stream.value(mockAlerts)),
          ],
          child: const MaterialApp(
            home: LigaRadarScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Rectangular OutlinedButtons for Check prices and Background monitoring should be gone
      expect(find.byType(OutlinedButton), findsNothing);

      // Verify the standardized KPI summary cards are rendered
      expect(find.byType(KpiStatCard), findsNWidgets(3));

      // Verify monitoring check toggle (InkWell checkbox) is removed from product cards
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });
}
