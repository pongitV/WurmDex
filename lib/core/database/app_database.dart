import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Folders Table
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get colorTag => text().withDefault(const Constant('#7C3AED'))();
  TextColumn get iconName => text().withDefault(const Constant('folder'))();
  // displayMode: 'grid' or 'binder'
  TextColumn get displayMode => text().withDefault(const Constant('grid'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// UserCards Table (Cards in user's collection/folders)
class UserCards extends Table {
  TextColumn get id => text()();
  TextColumn get cardApiId => text()();
  TextColumn get name => text()();
  TextColumn get number => text().withDefault(const Constant(''))();
  TextColumn get setName => text().withDefault(const Constant(''))();
  TextColumn get rarity => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text()();
  TextColumn get folderId => text().nullable().references(Folders, #id, onDelete: KeyAction.cascade)();
  
  // Mint, Near Mint, Slightly Played, Moderately Played, Heavily Played, Damaged
  TextColumn get condition => text().withDefault(const Constant('Near Mint'))();
  // PT, EN, JP
  TextColumn get language => text().withDefault(const Constant('PT'))();
  // Regular, Reverse Holo, Holofoil, Secret Rare
  TextColumn get finish => text().withDefault(const Constant('Regular'))();
  
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get purchasePriceBrl => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// Wishlist Table
class WishlistItems extends Table {
  TextColumn get id => text()();
  TextColumn get cardApiId => text()();
  TextColumn get name => text()();
  TextColumn get number => text().withDefault(const Constant(''))();
  TextColumn get setName => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text()();
  RealColumn get targetPriceBrl => real().withDefault(const Constant(0.0))();
  // Baixa, Média, Alta
  TextColumn get priority => text().withDefault(const Constant('Média'))();
  TextColumn get folderName => text().withDefault(const Constant('Geral'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// PriceSnapshots Table (Historical prices saved locally)
class PriceSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardApiId => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  RealColumn get ligaMinBrl => real().nullable()();
  RealColumn get ligaAvgBrl => real().nullable()();
  RealColumn get ligaMaxBrl => real().nullable()();
  RealColumn get tcgMarketUsd => real().nullable()();
  RealColumn get exchangeRateBrl => real().withDefault(const Constant(5.60))();
}

@DriftDatabase(tables: [Folders, UserCards, WishlistItems, PriceSnapshots])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(folders, folders.iconName);
      }
      if (from < 3) {
        await m.addColumn(wishlistItems, wishlistItems.folderName);
      }
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await _createIndexes();
    },
  );

  Future<void> _createIndexes() async {
    await customStatement('CREATE INDEX IF NOT EXISTS idx_user_cards_folder ON user_cards (folder_id);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_user_cards_api_id ON user_cards (card_api_id);');
    await customStatement('CREATE INDEX IF NOT EXISTS idx_price_snapshots_card_time ON price_snapshots (card_api_id, timestamp);');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'yourdex_database');
  }

  // --- Folder Queries ---
  Stream<List<Folder>> watchAllFolders() => (select(folders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Future<List<Folder>> getAllFolders() => (select(folders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  Future<Folder?> getFolderById(String id) => (select(folders)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertFolder(FoldersCompanion folder) => into(folders).insert(folder);
  Future<bool> updateFolder(FoldersCompanion folder) => update(folders).replace(folder);
  Future<int> deleteFolder(String id) => (delete(folders)..where((t) => t.id.equals(id))).go();

  // --- UserCards Queries ---
  Stream<List<UserCard>> watchAllCards() => (select(userCards)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Stream<List<UserCard>> watchCardsByFolder(String? folderId) {
    if (folderId == null) {
      return (select(userCards)..where((t) => t.folderId.isNull())..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
    }
    return (select(userCards)..where((t) => t.folderId.equals(folderId))..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }
  Future<List<UserCard>> getAllCards() => select(userCards).get();
  Future<int> insertCard(UserCardsCompanion card) => into(userCards).insert(card);
  Future<bool> updateCard(UserCardsCompanion card) => update(userCards).replace(card);
  Future<int> deleteCard(String id) => (delete(userCards)..where((t) => t.id.equals(id))).go();

  // --- Wishlist Queries ---
  Stream<List<WishlistItem>> watchWishlist() => (select(wishlistItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  Stream<List<WishlistItem>> watchWishlistByFolder(String? folder) {
    if (folder == null || folder.isEmpty || folder == 'Todas') {
      return watchWishlist();
    }
    return (select(wishlistItems)..where((t) => t.folderName.equals(folder))..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }
  Future<List<WishlistItem>> getAllWishlist() => select(wishlistItems).get();
  Future<int> insertWishlistItem(WishlistItemsCompanion item) => into(wishlistItems).insert(item);
  Future<int> deleteWishlistItem(String id) => (delete(wishlistItems)..where((t) => t.id.equals(id))).go();

  // --- PriceSnapshots Queries ---
  Future<int> insertPriceSnapshot(PriceSnapshotsCompanion snapshot) => into(priceSnapshots).insert(snapshot);
  Future<List<PriceSnapshot>> getSnapshotsForCard(String cardApiId) => 
      (select(priceSnapshots)..where((t) => t.cardApiId.equals(cardApiId))..orderBy([(t) => OrderingTerm.asc(t.timestamp)])).get();

  // --- Backup / Restore ---
  Future<void> clearAllUserData() async {
    await delete(priceSnapshots).go();
    await delete(wishlistItems).go();
    await delete(userCards).go();
    await delete(folders).go();
  }
}
