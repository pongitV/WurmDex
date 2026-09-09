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
}
