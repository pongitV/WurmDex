import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/services/app_preferences_service.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/card_details/presentation/widgets/card_quick_wishlist_dialog.dart';
import 'package:wurmdex/features/wishlist/presentation/widgets/wishlist_manage_folders_dialog.dart';
import 'package:wurmdex/features/wishlist/services/wishlist_folder_service.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wishlist_folder_test_');
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

  group('WishlistFolderService Tests', () {
    test('getAllFolders always returns Geral first and includes saved folders', () {
      AppPreferencesService.setWishlistFolders(['Raros', 'Antigos']);

      final folders = WishlistFolderService.getAllFolders();
      expect(folders.first, 'Geral');
      expect(folders, containsAll(['Geral', 'Antigos', 'Raros']));
    });

    test('addFolder saves new folder to persistent preferences', () {
      final added = WishlistFolderService.addFolder('Promoções');
      expect(added, isTrue);

      final folders = WishlistFolderService.getAllFolders();
      expect(folders, contains('Promoções'));

      // Duplicate prevention
      final duplicate = WishlistFolderService.addFolder('promoções');
      expect(duplicate, isFalse);

      // Disallow reserved names
      expect(WishlistFolderService.addFolder('Geral'), isFalse);
      expect(WishlistFolderService.addFolder('Todas'), isFalse);
      expect(WishlistFolderService.addFolder('   '), isFalse);
    });

    test('renameFolder updates preferences and database items', () async {
      WishlistFolderService.addFolder('Antigas');

      await db.insertWishlistItem(
        const WishlistItemsCompanion(
          id: drift.Value('test_card_1'),
          cardApiId: drift.Value('api_1'),
          name: drift.Value('Blastoise'),
          number: drift.Value('2/102'),
          setName: drift.Value('Base Set'),
          imageUrl: drift.Value(''),
          minTargetPriceBrl: drift.Value(10.0),
          targetPriceBrl: drift.Value(100.0),
          priority: drift.Value('Alta'),
          folderName: drift.Value('Antigas'),
        ),
      );

      final renamed = await WishlistFolderService.renameFolder(
        db: db,
        oldName: 'Antigas',
        newName: 'Vintage',
      );
      expect(renamed, isTrue);

      final folders = WishlistFolderService.getAllFolders();
      expect(folders, contains('Vintage'));
      expect(folders, isNot(contains('Antigas')));

      final items = await db.getAllWishlist();
      expect(items.first.folderName, 'Vintage');
    });

    test('deleteFolder removes from preferences and moves items to Geral', () async {
      WishlistFolderService.addFolder('ParaTroca');

      await db.insertWishlistItem(
        const WishlistItemsCompanion(
          id: drift.Value('test_card_2'),
          cardApiId: drift.Value('api_2'),
          name: drift.Value('Venusaur'),
          number: drift.Value('15/102'),
          setName: drift.Value('Base Set'),
          imageUrl: drift.Value(''),
          minTargetPriceBrl: drift.Value(5.0),
          targetPriceBrl: drift.Value(80.0),
          priority: drift.Value('Média'),
          folderName: drift.Value('ParaTroca'),
        ),
      );

      await WishlistFolderService.deleteFolder(
        db: db,
        folderName: 'ParaTroca',
      );

      final folders = WishlistFolderService.getAllFolders();
      expect(folders, isNot(contains('ParaTroca')));

      final items = await db.getAllWishlist();
      expect(items.first.folderName, 'Geral');
    });
  });

  group('WishlistManageFoldersDialog Widget Tests', () {
    testWidgets('Displays New Folder button and allows adding folders', (tester) async {
      final strings = getStrings(AppLanguage.ptBr);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WishlistManageFoldersDialog(
              db: db,
              allItems: const [],
              strings: strings,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify "Nova pasta" action is present
      expect(find.text('Nova pasta'), findsOneWidget);

      // Verify no redundant add-folder buttons remain (title / empty-state)
      expect(find.byIcon(Icons.create_new_folder_outlined), findsNothing);
      expect(find.text('Criar pasta'), findsNothing);

      // Tap to create a new folder
      await tester.tap(find.text('Nova pasta'));
      await tester.pumpAndSettle();

      // Input folder name
      await tester.enterText(find.byType(TextField).last, 'Favoritas');
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      // Verify folder is listed
      expect(find.text('Favoritas'), findsOneWidget);
    });
  });

  group('CardQuickWishlistDialog Tests', () {
    testWidgets('Does NOT contain create folder option (__NEW_FOLDER__)', (tester) async {
      final strings = getStrings(AppLanguage.ptBr);
      const testCard = PokemonCardItem(
        id: 'test_card_id',
        name: 'Mewtwo GX',
        number: '78/73',
        setId: 'sm35',
        setName: 'Shining Legends',
        rarity: 'Secret Rare',
        types: ['Psychic'],
        supertype: 'Pokémon',
        artist: '5ban Graphics',
        imageUrlSmall: 'https://example.com/mewtwo.png',
        imageUrlLarge: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Consumer(
                  builder: (context, ref, _) => ElevatedButton(
                    onPressed: () => CardQuickWishlistDialog.show(
                      context,
                      ref: ref,
                      card: testCard,
                      strings: strings,
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pump(const Duration(milliseconds: 300));

      // Open the folders dropdown
      await tester.tap(find.byIcon(Icons.folder_outlined), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      // Verify "+ Criar nova pasta..." or "+ Add new folder..." is NOT present
      expect(find.textContaining('Criar nova pasta'), findsNothing);
      expect(find.textContaining('Add new folder'), findsNothing);
    });
  });
}
