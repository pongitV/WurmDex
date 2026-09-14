import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/localization/app_language.dart';
import 'package:wurmdex/core/providers/card_scale_provider.dart';
import 'package:wurmdex/core/services/app_preferences_service.dart';
import 'package:wurmdex/core/theme/theme_constants.dart';
import 'package:wurmdex/core/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('wurmdex_test_');
    AppPreferencesService.setMockDirectory(tempDir);
    await AppPreferencesService.init();
  });

  tearDown(() {
    AppPreferencesService.resetForTesting();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('AppPreferencesService & Persistence Tests', () {
    test('AppPreferencesService saves and retrieves ThemeMode', () {
      AppPreferencesService.saveThemeMode(AppThemeMode.gramado);
      expect(AppPreferencesService.getSavedThemeMode(), equals(AppThemeMode.gramado));

      AppPreferencesService.saveThemeMode(AppThemeMode.wurmple);
      expect(AppPreferencesService.getSavedThemeMode(), equals(AppThemeMode.wurmple));

      AppPreferencesService.saveThemeMode(AppThemeMode.light);
      expect(AppPreferencesService.getSavedThemeMode(), equals(AppThemeMode.light));

      AppPreferencesService.saveThemeMode(AppThemeMode.dark);
      expect(AppPreferencesService.getSavedThemeMode(), equals(AppThemeMode.dark));
    });

    test('AppPreferencesService saves and retrieves Language', () {
      AppPreferencesService.saveLanguage(AppLanguage.ptBr);
      expect(AppPreferencesService.getSavedLanguage(), equals(AppLanguage.ptBr));

      AppPreferencesService.saveLanguage(AppLanguage.enUs);
      expect(AppPreferencesService.getSavedLanguage(), equals(AppLanguage.enUs));
    });

    test('AppPreferencesService saves and retrieves Card Scales', () {
      AppPreferencesService.saveMenuScale(1.35);
      expect(AppPreferencesService.getSavedMenuScale(), equals(1.35));

      AppPreferencesService.saveCollectionScale(0.95);
      expect(AppPreferencesService.getSavedCollectionScale(), equals(0.95));
    });

    test('ThemeNotifier and LanguageNotifier update and persist state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Change Theme
      container.read(themeProvider.notifier).setTheme(AppThemeMode.gramado);
      expect(container.read(themeProvider), equals(AppThemeMode.gramado));
      expect(AppPreferencesService.getSavedThemeMode(), equals(AppThemeMode.gramado));

      // Change Language
      container.read(languageProvider.notifier).setLanguage(AppLanguage.ptBr);
      expect(container.read(languageProvider), equals(AppLanguage.ptBr));
      expect(AppPreferencesService.getSavedLanguage(), equals(AppLanguage.ptBr));

      // Change Card Scale
      container.read(menuCardScaleProvider.notifier).setScale(1.20);
      expect(container.read(menuCardScaleProvider), equals(1.20));
      expect(AppPreferencesService.getSavedMenuScale(), equals(1.20));
    });
  });
}
