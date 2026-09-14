import 'package:drift/drift.dart' as drift;
import '../../../core/database/app_database.dart';
import '../../../core/services/app_preferences_service.dart';

/// Centralized service for managing LigaRadar Folders (DRY).
///
/// Ensures unified logic mirroring My Collection and Wishlist:
/// - Retrieving sorted folders (with 'Geral' first)
/// - Adding new folders with persistence in [AppPreferencesService]
/// - Renaming folders across preferences and SQLite database
/// - Deleting folders and moving contained items back to 'Geral'
class RadarFolderService {
  /// Returns a sorted list of unique folder names.
  /// 'Geral' is always first, followed by alphabetical order.
  static List<String> getAllFolders({List<LigaPriceAlert>? alerts}) {
    final folderSet = <String>{'Geral'};

    // 1. Add from persistent preferences
    folderSet.addAll(AppPreferencesService.getRadarFolders());

    // 2. Add from existing alerts if provided
    if (alerts != null) {
      for (final alert in alerts) {
        final f = alert.folderName.trim();
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
    final current = AppPreferencesService.getRadarFolders();
    if (current.any((f) => f.toLowerCase() == name.toLowerCase())) {
      return false;
    }
    AppPreferencesService.addRadarFolder(name);
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
    AppPreferencesService.renameRadarFolder(cleanOld, cleanNew);

    // Update SQLite database items
    await (db.update(db.ligaPriceAlerts)..where((t) => t.folderName.equals(cleanOld))).write(
      LigaPriceAlertsCompanion(folderName: drift.Value(cleanNew)),
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
    AppPreferencesService.deleteRadarFolder(cleanName);

    // Update SQLite database items to 'Geral'
    await (db.update(db.ligaPriceAlerts)..where((t) => t.folderName.equals(cleanName))).write(
      const LigaPriceAlertsCompanion(folderName: drift.Value('Geral')),
    );
  }
}
