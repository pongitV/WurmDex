import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeMode {
  dark,
  light,
  gramado,
  wurmple,
}

class AppThemes {
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.redAccent,
      secondary: AppColors.redAccent,
      surface: AppColors.darkSurface,
      error: AppColors.lossRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.redAccent.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.redAccent);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.redAccent.withValues(alpha: 0.25),
        selectedIconTheme: const IconThemeData(color: AppColors.redAccent),
        unselectedIconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
        selectedLabelTextStyle: const TextStyle(color: AppColors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelTextStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.lightAccent,
      secondary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      error: AppColors.lossRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground, // Branco amarelado de folha de livro antigo
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightAccent.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightAccent);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightAccent.withValues(alpha: 0.15),
        selectedIconTheme: const IconThemeData(color: AppColors.lightAccent),
        unselectedIconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
        selectedLabelTextStyle: const TextStyle(color: AppColors.lightAccent, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelTextStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      ),
    );
  }

  static ThemeData get gramadoTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.gramadoPrimary,
      secondary: AppColors.gramadoSecondary,
      surface: AppColors.gramadoSurface,
      error: AppColors.lossRed,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.gramadoTextPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.gramadoBackground,
      cardColor: AppColors.gramadoSurface,
      dividerColor: AppColors.gramadoBorder,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gramadoPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gramadoPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gramadoTextPrimary,
          side: const BorderSide(color: AppColors.gramadoBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.gramadoSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gramadoBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.gramadoBackground,
        foregroundColor: AppColors.gramadoTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.gramadoSurface,
        indicatorColor: AppColors.gramadoPrimary.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.gramadoPrimary);
          }
          return const IconThemeData(color: AppColors.gramadoTextSecondary);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.gramadoSurface,
        indicatorColor: AppColors.gramadoPrimary.withValues(alpha: 0.25),
        selectedIconTheme: const IconThemeData(color: AppColors.gramadoPrimary),
        unselectedIconTheme: const IconThemeData(color: AppColors.gramadoTextSecondary),
        selectedLabelTextStyle: const TextStyle(color: AppColors.gramadoPrimary, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelTextStyle: const TextStyle(color: AppColors.gramadoTextSecondary, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gramadoSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gramadoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gramadoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gramadoPrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.gramadoTextSecondary),
      ),
    );
  }

  static ThemeData get wurmpleTheme {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.wurmplePrimary,
      secondary: AppColors.wurmpleSecondary,
      surface: AppColors.wurmpleSurface,
      error: AppColors.lossRed,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.wurmpleTextPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.wurmpleBackground,
      cardColor: AppColors.wurmpleSurface,
      dividerColor: AppColors.wurmpleBorder,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.wurmplePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.wurmplePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.wurmpleTextPrimary,
          side: const BorderSide(color: AppColors.wurmpleBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.wurmpleSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.wurmpleBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.wurmpleBackground,
        foregroundColor: AppColors.wurmpleTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.wurmpleSurface,
        indicatorColor: AppColors.wurmplePrimary.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.wurmplePrimary);
          }
          return const IconThemeData(color: AppColors.wurmpleTextSecondary);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.wurmpleSurface,
        indicatorColor: AppColors.wurmplePrimary.withValues(alpha: 0.25),
        selectedIconTheme: const IconThemeData(color: AppColors.wurmplePrimary),
        unselectedIconTheme: const IconThemeData(color: AppColors.wurmpleTextSecondary),
        selectedLabelTextStyle: const TextStyle(color: AppColors.wurmplePrimary, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelTextStyle: const TextStyle(color: AppColors.wurmpleTextSecondary, fontSize: 11),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.wurmpleSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.wurmpleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.wurmpleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.wurmplePrimary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.wurmpleTextSecondary),
      ),
    );
  }
}
