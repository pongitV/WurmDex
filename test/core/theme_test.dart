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

      container.read(themeProvider.notifier).setTheme(AppThemeMode.lugia);
      expect(container.read(themeProvider), AppThemeMode.lugia);
      expect(container.read(themeProvider.notifier).currentThemeData.brightness, Brightness.dark);
      expect(container.read(themeProvider.notifier).currentThemeData.scaffoldBackgroundColor, AppColors.lugiaBackground);
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

      // All themes should be visible in the settings screen
      expect(find.text('Light Theme (Antique Book Page)'), findsOneWidget);
      expect(find.text('Gramado Theme (Lawn / Grassland)'), findsOneWidget);
      expect(find.text('Wurmple Theme (#265)'), findsOneWidget);
      expect(find.text('Lugia Theme (#249)'), findsOneWidget);
      expect(find.text('Shiny Wurmple Theme (★ #265)'), findsOneWidget);
      expect(find.text('Shiny Lugia Theme (★ #249)'), findsOneWidget);
      expect(find.text('Dark Lugia Theme (Shadow XD001)'), findsOneWidget);

      // Tap the Light Theme option
      final lightThemeTile = find.textContaining('Light Theme');
      await tester.tap(lightThemeTile);
      await tester.pumpAndSettle();

      // Verified tile is interactive and selectable
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
    });

    testWidgets('Unlock Extra Themes requires password 011 and toggles theme lock status', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the button to unlock extra themes
      final unlockBtn = find.text('Unlock Extra Themes');
      expect(unlockBtn, findsOneWidget);

      // Scroll until visible and tap button to open password dialog
      await tester.ensureVisible(unlockBtn);
      await tester.pumpAndSettle();
      await tester.tap(unlockBtn);
      await tester.pumpAndSettle();

      // Verify password prompt dialog is open
      expect(find.text('Access Password'), findsOneWidget);

      // Enter incorrect password first
      await tester.enterText(find.byType(TextField), '999');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Password dialog should still be present
      expect(find.text('Access Password'), findsOneWidget);

      // Enter correct passcode "011"
      await tester.enterText(find.byType(TextField), '011');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Manage dialog should now be visible
      expect(find.text('Manage Extra Themes'), findsOneWidget);
      expect(find.text('Choose Theme to Configure'), findsOneWidget);

      // Tap Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Manage Extra Themes'), findsNothing);
    });
  });
}
