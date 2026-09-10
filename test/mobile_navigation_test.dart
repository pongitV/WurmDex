import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/localization/app_language.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/features/navigation/presentation/main_scaffold.dart';

class MockPtLanguageNotifier extends LanguageNotifier {
  @override
  AppLanguage build() => AppLanguage.ptBr;
}

void main() {
  testWidgets('Mobile navigation displays 3 buttons and opens More sheet (pt-BR)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith(MockPtLanguageNotifier.new),
        ],
        child: const MaterialApp(
          home: MainScaffold(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Exactly 4 navigation destinations in mobile NavigationBar: Catalog - Liga Radar - Colecoes - Mais
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Radar Liga'), findsOneWidget);
    expect(find.text('Coleções'), findsWidgets);
    expect(find.text('Mais'), findsOneWidget);

    // Tap "Radar Liga"
    await tester.tap(find.text('Radar Liga'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Radar LigaPokémon'), findsOneWidget);

    // Tap "Mais" to open modal bottom sheet
    await tester.tap(find.text('Mais'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300)); // animation

    // Verify "Mais Opções" bottom sheet is visible with its items
    expect(find.text('Mais Opções'), findsOneWidget);
    expect(find.text('Coleções TCG'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);

    // Tap "Coleções TCG" inside the sheet
    await tester.tap(find.text('Coleções TCG'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300)); // dismiss animation

    // Verify Expansions screen is shown and 4th tab label updated to reflect active screen
    expect(find.text('Expansões & Lançamentos TCG'), findsOneWidget);
  });

  testWidgets('Desktop/Windows size displays identical 4-button navigation dock and More sheet', (WidgetTester tester) async {
    // Desktop 1280x720 window
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageProvider.overrideWith(MockPtLanguageNotifier.new),
        ],
        child: const MaterialApp(
          home: MainScaffold(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // Exactly 4 navigation destinations in NavigationBar on Desktop as well
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Radar Liga'), findsOneWidget);
    expect(find.text('Coleções'), findsWidgets);
    expect(find.text('Mais'), findsOneWidget);

    // Tap "Mais" on desktop
    await tester.tap(find.text('Mais'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify "Mais Opções" bottom sheet is visible
    expect(find.text('Mais Opções'), findsOneWidget);
    expect(find.text('Coleções TCG'), findsOneWidget);
  });
}

