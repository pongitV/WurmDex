import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/theme/app_colors.dart';
import 'package:wurmdex/core/theme/theme_constants.dart';
import 'package:wurmdex/core/theme/theme_provider.dart';
import 'package:wurmdex/features/settings/presentation/settings_screen.dart';

void main() {
  group('Theme Engine & Antique Book Page Light Theme Tests', () {
    test('Light Theme matches old book page soft beige palette', () {
      final lightTheme = AppThemes.lightTheme;
      expect(lightTheme.brightness, Brightness.light);
      // Soft vintage beige background
      expect(lightTheme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(lightTheme.scaffoldBackgroundColor, const Color(0xFFF5F0E6));
      // Soft parchment card and surface
      expect(lightTheme.cardColor, AppColors.lightSurface);
      expect(lightTheme.cardColor, const Color(0xFFFAF6EE));
      // Deep seal-wax crimson accent
      expect(lightTheme.colorScheme.primary, AppColors.lightAccent);
      expect(lightTheme.colorScheme.primary, const Color(0xFF9E2A2B));
      // Classic readable sepia/charcoal typography
      expect(lightTheme.colorScheme.onSurface, AppColors.lightTextPrimary);
      expect(lightTheme.colorScheme.onSurface, const Color(0xFF2A231E));
    });

    test('ThemeNotifier transitions correctly between all 4 themes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeProvider), AppThemeMode.dark);
      expect(container.read(themeProvider.notifier).currentThemeData.brightness, Brightness.dark);

      container.read(themeProvider.notifier).setTheme(AppThemeMode.light);
      expect(container.read(themeProvider), AppThemeMode.light);
      expect(container.read(themeProvider.notifier).currentThemeData.brightness, Brightness.light);
      expect(container.read(themeProvider.notifier).currentThemeData.scaffoldBackgroundColor, const Color(0xFFF5F0E6));

      container.read(themeProvider.notifier).setTheme(AppThemeMode.gramado);
      expect(container.read(themeProvider), AppThemeMode.gramado);

      container.read(themeProvider.notifier).setTheme(AppThemeMode.wurmple);
      expect(container.read(themeProvider), AppThemeMode.wurmple);
    });

    testWidgets('SettingsScreen displays Light Theme option and allows selecting it', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // All 4 themes should be visible in the settings screen
      expect(find.textContaining('Dark Theme'), findsOneWidget);
      expect(find.textContaining('Light Theme'), findsOneWidget);
      expect(find.textContaining('Gramado Theme'), findsOneWidget);
      expect(find.textContaining('Wurmple Theme'), findsOneWidget);

      // Tap the Light Theme option
      final lightThemeTile = find.textContaining('Light Theme');
      await tester.tap(lightThemeTile);
      await tester.pumpAndSettle();

      // Verified tile is interactive and selectable
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
    });
  });
}
