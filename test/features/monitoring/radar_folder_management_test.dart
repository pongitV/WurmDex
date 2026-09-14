import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/services/app_preferences_service.dart';
import 'package:wurmdex/core/widgets/folder_badge.dart';
import 'package:wurmdex/core/widgets/folder_filter_bar.dart';
import 'package:wurmdex/features/monitoring/presentation/widgets/radar_manage_folders_dialog.dart';
import 'package:wurmdex/features/monitoring/services/radar_folder_service.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('radar_folder_test_');
    AppPreferencesService.setMockDirectory(tempDir);
    await AppPreferencesService.init();
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
    AppPreferencesService.resetForTesting();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('RadarFolderService Tests', () {
    test('getAllFolders always returns Geral first and includes saved folders', () {
      AppPreferencesService.setRadarFolders(['Selados', 'Cartas']);

      final folders = RadarFolderService.getAllFolders();
      expect(folders.first, 'Geral');
      expect(folders, containsAll(['Geral', 'Cartas', 'Selados']));
    });

    test('addFolder saves new folder to persistent preferences', () {
      final added = RadarFolderService.addFolder('Promoções');
      expect(added, isTrue);

      final folders = RadarFolderService.getAllFolders();
      expect(folders, contains('Promoções'));

      // Duplicate prevention
      final duplicate = RadarFolderService.addFolder('promoções');
      expect(duplicate, isFalse);

      // Disallow reserved names
      expect(RadarFolderService.addFolder('Geral'), isFalse);
      expect(RadarFolderService.addFolder('Todas'), isFalse);
      expect(RadarFolderService.addFolder('   '), isFalse);
    });

    test('renameFolder updates preferences and database alerts', () async {
      RadarFolderService.addFolder('Caixas');

      await db.insertLigaAlert(
        LigaPriceAlertsCompanion.insert(
          id: 'test_alert_1',
          targetUrl: 'https://example.com/1',
          title: 'Booster Box 151',
          folderName: const drift.Value('Caixas'),
        ),
      );

      final renamed = await RadarFolderService.renameFolder(
        db: db,
        oldName: 'Caixas',
        newName: 'Boxes',
      );
      expect(renamed, isTrue);

      final folders = RadarFolderService.getAllFolders();
      expect(folders, contains('Boxes'));
      expect(folders, isNot(contains('Caixas')));

      final alerts = await db.getAllLigaAlerts();
      expect(alerts.first.folderName, 'Boxes');
    });

    test('deleteFolder removes from preferences and resets alerts to Geral', () async {
      RadarFolderService.addFolder('Avaliados');

      await db.insertLigaAlert(
        LigaPriceAlertsCompanion.insert(
          id: 'test_alert_2',
          targetUrl: 'https://example.com/2',
          title: 'Charizard PSA 10',
          folderName: const drift.Value('Avaliados'),
        ),
      );

      await RadarFolderService.deleteFolder(
        db: db,
        folderName: 'Avaliados',
      );

      final folders = RadarFolderService.getAllFolders();
      expect(folders, isNot(contains('Avaliados')));

      final alerts = await db.getAllLigaAlerts();
      expect(alerts.first.folderName, 'Geral');
    });
  });

  group('Radar Folder Widgets Tests', () {
    testWidgets('FolderBadge renders folderName and icon properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FolderBadge(
              folderName: 'Vintage',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.text('Vintage'), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets('FolderFilterBar displays all, geral and custom folders', (tester) async {
      String? selected = 'Todas';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FolderFilterBar(
                  selected: selected == 'Todas' ? null : selected,
                  folders: const ['Geral', 'Investimentos'],
                  hint: 'Filtrar por Pasta',
                  allLabel: 'Todas',
                  onChanged: (val) => setState(() => selected = val ?? 'Todas'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Todas'), findsOneWidget);

      // Tap on dropdown to open menu
      await tester.tap(find.byType(DropdownButton<String?>));
      await tester.pumpAndSettle();

      expect(find.text('Geral').last, findsOneWidget);
      expect(find.text('Investimentos').last, findsOneWidget);

      // Tap on Investimentos
      await tester.tap(find.text('Investimentos').last);
      await tester.pumpAndSettle();
      expect(selected, 'Investimentos');
    });

    testWidgets('RadarManageFoldersDialog allows creating and viewing folders', (tester) async {
      final strings = getStrings(AppLanguage.ptBr);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RadarManageFoldersDialog(
              db: db,
              allAlerts: const [],
              strings: strings,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(strings.wishlistNewFolder), findsOneWidget);
      expect(find.text(strings.noCustomFoldersYet), findsOneWidget);

      // Tap to create folder
      await tester.tap(find.text(strings.wishlistNewFolder));
      await tester.pumpAndSettle();

      expect(find.text(strings.wishlistNewFolderName), findsOneWidget);
    });

    testWidgets('RadarManageFoldersDialog closes dialog upon folder deletion', (tester) async {
      final strings = getStrings(AppLanguage.ptBr);
      RadarFolderService.addFolder('Promo');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => RadarManageFoldersDialog.show(
                  context,
                  db: db,
                  allAlerts: const [],
                  strings: strings,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dialog is open with folder 'Promo'
      expect(find.text('Promo'), findsOneWidget);
      expect(find.byType(RadarManageFoldersDialog), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap confirm delete
      await tester.tap(find.text(strings.btnDelete));
      await tester.pumpAndSettle();

      // Verify RadarManageFoldersDialog is closed!
      expect(find.byType(RadarManageFoldersDialog), findsNothing);
    });
  });
}
