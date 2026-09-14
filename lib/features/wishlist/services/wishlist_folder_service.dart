import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/services/app_preferences_service.dart';

/// Centralized service for managing Wishlist Folders.
///
/// Ensures unified logic for:
/// - Retrieving sorted folders (with 'Geral' first)
/// - Adding new folders with persistence in [AppPreferencesService]
/// - Renaming folders across preferences and SQLite database
/// - Deleting folders and moving contained items back to 'Geral'
class WishlistFolderService {
  /// Returns a sorted list of unique folder names.
  /// 'Geral' is always first, followed by alphabetical order.
  static List<String> getAllFolders({List<WishlistItem>? items}) {
    final folderSet = <String>{'Geral'};

    // 1. Add from persistent preferences
    folderSet.addAll(AppPreferencesService.getWishlistFolders());

    // 2. Add from existing items if provided
    if (items != null) {
      for (final item in items) {
        final f = item.folderName.trim();
        if (f.isNotEmpty) {
          folderSet.add(f);
        }
      }
    }

    final list = folderSet.toList();
    list.sort((a, b) {
      if (a == 'Geral') return -1;
      if (b == 'Geral') return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return list;
  }

  /// Adds a new folder to preferences.
  /// Returns true if added, false if invalid or duplicate.
  static bool addFolder(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty || name == 'Geral' || name == 'Todas') {
      return false;
    }
    final current = AppPreferencesService.getWishlistFolders();
    if (current.any((f) => f.toLowerCase() == name.toLowerCase())) {
      return false;
    }
    AppPreferencesService.addWishlistFolder(name);
    return true;
  }

  /// Renames a folder in preferences and updates all matching items in SQLite.
  static Future<bool> renameFolder({
    required AppDatabase db,
    required String oldName,
    required String newName,
  }) async {
    final cleanOld = oldName.trim();
    final cleanNew = newName.trim();
    if (cleanNew.isEmpty || cleanOld.isEmpty || cleanNew == cleanOld) return false;
    if (cleanNew == 'Geral' || cleanNew == 'Todas') return false;

    // Update persistent preferences
    AppPreferencesService.renameWishlistFolder(cleanOld, cleanNew);

    // Update SQLite database items
    await (db.update(db.wishlistItems)..where((t) => t.folderName.equals(cleanOld))).write(
      WishlistItemsCompanion(folderName: drift.Value(cleanNew)),
    );
    return true;
  }

  /// Deletes a folder from preferences and resets affected items to 'Geral'.
  static Future<void> deleteFolder({
    required AppDatabase db,
    required String folderName,
  }) async {
    final cleanName = folderName.trim();
    if (cleanName.isEmpty || cleanName == 'Geral' || cleanName == 'Todas') return;

    // Update persistent preferences
    AppPreferencesService.deleteWishlistFolder(cleanName);

    // Update SQLite database items to 'Geral'
    await (db.update(db.wishlistItems)..where((t) => t.folderName.equals(cleanName))).write(
      const WishlistItemsCompanion(folderName: drift.Value('Geral')),
    );
  }
}
