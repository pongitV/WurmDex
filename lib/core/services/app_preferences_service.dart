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

  /// Test helper to supply a directory or file without calling path_provider
  @visibleForTesting
  static void setMockDirectory(Directory directory) {
    _file = File('${directory.path}/$_settingsFileName');
    _initialized = true;
  }

  @visibleForTesting
  static void resetForTesting() {
    _cache = {};
    _file = null;
    _initialized = false;
  }

  /// Initializes the service by reading stored preferences from disk.
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final directory = await getApplicationSupportDirectory();
      _file = File('${directory.path}/$_settingsFileName');
      if (await _file!.exists()) {
        final content = await _file!.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is Map<String, dynamic>) {
            _cache = decoded;
          }
        }
      }
      _initialized = true;
    } catch (e) {
      debugPrint('AppPreferencesService init error: $e');
      _cache = {};
    }
  }

  static Future<void> _persist() async {
    try {
      if (_file == null) {
        final directory = await getApplicationSupportDirectory();
        _file = File('${directory.path}/$_settingsFileName');
      }
      await _file!.writeAsString(jsonEncode(_cache), flush: true);
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
}

