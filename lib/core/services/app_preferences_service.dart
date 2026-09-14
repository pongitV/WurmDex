import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../localization/app_language.dart';
import '../theme/theme_constants.dart';

/// Service responsible for persisting user preferences (Theme, Language, Card Scales)
/// across application restarts on all platforms (Windows, Android, iOS, Linux, macOS).
class AppPreferencesService {
  static const String _settingsFileName = 'wurmdex_user_settings.json';
  static Map<String, dynamic> _cache = {};
  static File? _file;
  static bool _initialized = false;

  /// Test helper to supply a directory or file without calling path_provider.
  ///
  /// This only points the service at a file; the file is (re)loaded by [init].
  @visibleForTesting
  static void setMockDirectory(Directory directory) {
    _file = File('${directory.path}/$_settingsFileName');
  }

  @visibleForTesting
  static void resetForTesting() {
    _cache = {};
    _file = null;
    _initialized = false;
  }

  /// Initializes the service by reading stored preferences from disk.
  ///
  /// Re-reads the settings file whenever it is invoked so values written by a
  /// previous session (e.g. empty wishlist folders) are reloaded even if the
  /// service was mocked with [setMockDirectory] and there is no cached state.
  static Future<void> init() async {
    try {
      if (_file == null) {
        final directory = await getApplicationSupportDirectory();
        _file = File('${directory.path}/$_settingsFileName');
      }
      if (_file!.existsSync()) {
        final content = _file!.readAsStringSync();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            _cache = decoded;
          }
        }
      }
    } catch (e) {
      debugPrint('AppPreferencesService init error: $e');
      _cache = {};
    } finally {
      // Keep the service usable in-memory even if disk access failed, so
      // setting values never silently no-op because it was never initialized.
      _initialized = true;
    }
  }

  /// Persists the current cache synchronously.
  ///
  /// A synchronous write guarantees every value is durable by the time a setter
  /// returns, so folders and preferences are never lost to a missing flush or a
  /// fire-and-forget write racing with a restart.
  static void _persist() {
    final file = _file;
    if (file == null) return;
    try {
      file.writeAsStringSync(jsonEncode(_cache), flush: true);
    } catch (e) {
      debugPrint('AppPreferencesService write error: $e');
    }
  }

  // --- Theme Mode ---
  static const String _keyThemeMode = 'theme_mode';

  static AppThemeMode? getSavedThemeMode() {
    if (!_initialized) return null;
    final val = _cache[_keyThemeMode];
    if (val is String) {
      for (final mode in AppThemeMode.values) {
        if (mode.name == val) return mode;
      }
    }
    return null;
  }

  static void saveThemeMode(AppThemeMode mode) {
    if (!_initialized) return;
    _cache[_keyThemeMode] = mode.name;
    _persist();
  }

  // --- Language ---
  static const String _keyLanguage = 'language';

  static AppLanguage? getSavedLanguage() {
    if (!_initialized) return null;
    final val = _cache[_keyLanguage];
    if (val is String) {
      for (final lang in AppLanguage.values) {
        if (lang.name == val) return lang;
      }
    }
    return null;
  }

  static void saveLanguage(AppLanguage language) {
    if (!_initialized) return;
    _cache[_keyLanguage] = language.name;
    _persist();
  }

  // --- Card Scales ---
  static const String _keyMenuScale = 'menu_card_scale';
  static const String _keyCollectionScale = 'collection_card_scale';

  static double? getSavedMenuScale() {
    if (!_initialized) return null;
    final val = _cache[_keyMenuScale];
    if (val is num) return val.toDouble();
    return null;
  }

  static void saveMenuScale(double scale) {
    if (!_initialized) return;
    _cache[_keyMenuScale] = scale;
    _persist();
  }

  static double? getSavedCollectionScale() {
    if (!_initialized) return null;
    final val = _cache[_keyCollectionScale];
    if (val is num) return val.toDouble();
    return null;
  }

  static void saveCollectionScale(double scale) {
    if (!_initialized) return;
    _cache[_keyCollectionScale] = scale;
    _persist();
  }

  // --- Wurmple Clicker Data ---
  static const String _keyWurmpleClicker = 'wurmple_clicker_data';

  static Map<String, dynamic>? getWurmpleClickerData() {
    if (!_initialized) return null;
    final val = _cache[_keyWurmpleClicker];
    if (val is Map<String, dynamic>) return val;
    return null;
  }

  static void saveWurmpleClickerData(Map<String, dynamic> data) {
    if (!_initialized) return;
    _cache[_keyWurmpleClicker] = data;
    _persist();
  }

  // --- Lugia Clicker Data ---
  static const String _keyLugiaClicker = 'lugia_clicker_data';

  static Map<String, dynamic>? getLugiaClickerData() {
    if (!_initialized) return null;
    final val = _cache[_keyLugiaClicker];
    if (val is Map<String, dynamic>) return val;
    return null;
  }

  static void saveLugiaClickerData(Map<String, dynamic> data) {
    if (!_initialized) return;
    _cache[_keyLugiaClicker] = data;
    _persist();
  }

  // --- Autoclicker Reset (keeps theme unlocks) ---
  static void resetAutoclickerProgress() {
    if (!_initialized) return;
    _cache.remove(_keyWurmpleClicker);
    _cache.remove(_keyLugiaClicker);
    _persist();
  }

  // --- Theme Unlocks ---
  static const String _keyWurmpleShinyUnlocked = 'wurmple_shiny_unlocked';
  static const String _keyLugiaShinyUnlocked = 'lugia_shiny_unlocked';
  static const String _keyDarkLugiaUnlocked = 'dark_lugia_unlocked';

  static bool isWurmpleShinyUnlocked() {
    if (!_initialized) return false;
    return _cache[_keyWurmpleShinyUnlocked] == true;
  }

  static void setWurmpleShinyUnlocked(bool unlocked) {
    if (!_initialized) return;
    _cache[_keyWurmpleShinyUnlocked] = unlocked;
    _persist();
  }

  static bool isLugiaShinyUnlocked() {
    if (!_initialized) return false;
    return _cache[_keyLugiaShinyUnlocked] == true;
  }

  static void setLugiaShinyUnlocked(bool unlocked) {
    if (!_initialized) return;
    _cache[_keyLugiaShinyUnlocked] = unlocked;
    _persist();
  }

  static bool isDarkLugiaUnlocked() {
    if (!_initialized) return false;
    return _cache[_keyDarkLugiaUnlocked] == true;
  }

  static void setDarkLugiaUnlocked(bool unlocked) {
    if (!_initialized) return;
    _cache[_keyDarkLugiaUnlocked] = unlocked;
    _persist();
  }

  // --- Autoclicker Preferences ---
  static const String _keyAutoclickerPaused = 'autoclicker_paused';

  static bool isAutoclickerPaused() {
    if (!_initialized) return false;
    return _cache[_keyAutoclickerPaused] == true;
  }

  static void setAutoclickerPaused(bool paused) {
    if (!_initialized) return;
    _cache[_keyAutoclickerPaused] = paused;
    _persist();
  }

  // --- Grid Composition Preferences ---
  static const String _keyGridComposition = 'grid_composition';

  static String? getSavedGridComposition() {
    if (!_initialized) return null;
    final val = _cache[_keyGridComposition];
    return val is String ? val : null;
  }

  static void saveGridComposition(String comp) {
    if (!_initialized) return;
    _cache[_keyGridComposition] = comp;
    _persist();
  }

  // --- Card View Mode (grid / list) Preferences ---
  static const String _keyViewMode = 'card_view_mode';

  static String? getSavedViewMode() {
    if (!_initialized) return null;
    final val = _cache[_keyViewMode];
    return val is String ? val : null;
  }

  static void saveViewMode(String mode) {
    if (!_initialized) return;
    _cache[_keyViewMode] = mode;
    _persist();
  }

  // --- Liga Radar Background Monitoring Preferences ---
  static const String _keyLigaBackgroundEnabled = 'liga_radar_background_enabled';
  static const String _keyLigaBackgroundInterval = 'liga_radar_background_interval_minutes';
  static const String _keyWishlistBackgroundEnabled = 'wishlist_background_enabled';
  static const String _keyRadarFolders = 'liga_radar_folders';
  static const String _keyWishlistFolders = 'wishlist_folders';

  static bool isBackgroundLigaMonitoringEnabled() {
    if (!_initialized) return false;
    return _cache[_keyLigaBackgroundEnabled] == true;
  }

  static void setBackgroundLigaMonitoringEnabled(bool enabled) {
    if (!_initialized) return;
    _cache[_keyLigaBackgroundEnabled] = enabled;
    _persist();
  }

  static int getLigaMonitoringIntervalMinutes() {
    if (!_initialized) return 60;
    final val = _cache[_keyLigaBackgroundInterval];
    if (val is num) return val.toInt();
    return 60;
  }

  static void setLigaMonitoringIntervalMinutes(int minutes) {
    if (!_initialized) return;
    _cache[_keyLigaBackgroundInterval] = minutes;
    _persist();
  }

  static bool isBackgroundWishlistScanEnabled() {
    if (!_initialized) return false;
    return _cache[_keyWishlistBackgroundEnabled] == true;
  }

  static void setBackgroundWishlistScanEnabled(bool enabled) {
    if (!_initialized) return;
    _cache[_keyWishlistBackgroundEnabled] = enabled;
    _persist();
  }

  static List<String> getRadarFolders() {
    if (!_initialized) return const [];
    final value = _cache[_keyRadarFolders];
    return value is List
        ? value.whereType<String>().where((item) => item.isNotEmpty).toList()
        : const [];
  }

  static void setRadarFolders(List<String> folders) {
    if (!_initialized) return;
    _cache[_keyRadarFolders] = folders.toSet().toList()..sort();
    _persist();
  }

  static List<String> getWishlistFolders() {
    if (!_initialized) return [];
    final value = _cache[_keyWishlistFolders];
    if (value is List) {
      return value.whereType<String>().where((item) => item.isNotEmpty).toList();
    }
    // Fallback: se ainda não houver salvo especificamente na nova chave,
    // verifica se há pastas salvas na chave anterior para não perder dados do usuário.
    final legacy = _cache[_keyRadarFolders];
    if (legacy is List) {
      final list = legacy.whereType<String>().where((item) => item.isNotEmpty).toList();
      if (list.isNotEmpty) {
        _cache[_keyWishlistFolders] = list;
        _persist();
        return list;
      }
    }
    return [];
  }

  static void setWishlistFolders(List<String> folders) {
    if (!_initialized) return;
    _cache[_keyWishlistFolders] = folders
        .map((f) => f.trim())
        .where((item) => item.isNotEmpty && item != 'Geral' && item != 'Todas')
        .toSet()
        .toList()
      ..sort();
    _persist();
  }

  static void addWishlistFolder(String folder) {
    final clean = folder.trim();
    if (clean.isEmpty || clean == 'Geral' || clean == 'Todas') return;
    final current = getWishlistFolders();
    if (!current.contains(clean)) {
      current.add(clean);
      setWishlistFolders(current);
    }
  }

  static void renameWishlistFolder(String oldName, String newName) {
    final cleanOld = oldName.trim();
    final cleanNew = newName.trim();
    if (cleanNew.isEmpty || cleanOld.isEmpty || cleanNew == cleanOld) return;
    final current = getWishlistFolders();
    final updated = current.map((f) => f == cleanOld ? cleanNew : f).toList();
    if (!updated.contains(cleanNew) && cleanNew != 'Geral' && cleanNew != 'Todas') {
      updated.add(cleanNew);
    }
    setWishlistFolders(updated);
  }

  static void deleteWishlistFolder(String folder) {
    final clean = folder.trim();
    final current = getWishlistFolders();
    current.removeWhere((f) => f == clean);
    setWishlistFolders(current);
  }
}

