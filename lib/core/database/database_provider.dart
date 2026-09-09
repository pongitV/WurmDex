import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Stream providers for reactive UI
final foldersStreamProvider = StreamProvider<List<Folder>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllFolders();
});

final userCardsStreamProvider = StreamProvider<List<UserCard>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllCards();
});

final wishlistStreamProvider = StreamProvider<List<WishlistItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchWishlist();
});

final folderCardsProvider = StreamProvider.family<List<UserCard>, String?>((ref, folderId) {
  final db = ref.watch(databaseProvider);
  return db.watchCardsByFolder(folderId);
});

final ligaAlertsStreamProvider = StreamProvider<List<LigaPriceAlert>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllLigaAlerts();
});

