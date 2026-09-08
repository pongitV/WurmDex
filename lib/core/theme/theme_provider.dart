import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_constants.dart';

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return AppThemeMode.dark;
  }

  void setTheme(AppThemeMode mode) {
    state = mode;
  }

  ThemeData get currentThemeData {
    switch (state) {
      case AppThemeMode.dark:
        return AppThemes.darkTheme;
      case AppThemeMode.light:
        return AppThemes.lightTheme;
      case AppThemeMode.gramado:
        return AppThemes.gramadoTheme;
      case AppThemeMode.wurmple:
        return AppThemes.wurmpleTheme;
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
