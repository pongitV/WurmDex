import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeMode {
  dark,
  light,
  gramado,
  wurmple,
}

class AppThemes {
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    Color onSecondary = Colors.white,
    double indicatorAlpha = 0.25,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: AppColors.lossRed,
      onPrimary: Colors.white,
      onSecondary: onSecondary,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: indicatorAlpha),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(color: textSecondary);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: indicatorAlpha),
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelTextStyle: TextStyle(color: textSecondary, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
    );
  }

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.redAccent,
        secondary: AppColors.redAccent,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        border: AppColors.darkBorder,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
      );

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        primary: AppColors.lightAccent,
        secondary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        border: AppColors.lightBorder,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
        indicatorAlpha: 0.15,
      );

  static ThemeData get gramadoTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.gramadoPrimary,
        secondary: AppColors.gramadoSecondary,
        surface: AppColors.gramadoSurface,
        background: AppColors.gramadoBackground,
        border: AppColors.gramadoBorder,
        textPrimary: AppColors.gramadoTextPrimary,
        textSecondary: AppColors.gramadoTextSecondary,
        onSecondary: Colors.black,
      );

  static ThemeData get wurmpleTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.wurmplePrimary,
        secondary: AppColors.wurmpleSecondary,
        surface: AppColors.wurmpleSurface,
        background: AppColors.wurmpleBackground,
        border: AppColors.wurmpleBorder,
        textPrimary: AppColors.wurmpleTextPrimary,
        textSecondary: AppColors.wurmpleTextSecondary,
        onSecondary: Colors.black,
      );
}
