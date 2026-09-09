import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_preferences_service.dart';

enum AppLanguage {
  enUs,
  ptBr,
}

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return AppPreferencesService.getSavedLanguage() ?? AppLanguage.enUs;
  }

  void setLanguage(AppLanguage language) {
    state = language;
    AppPreferencesService.saveLanguage(language);
  }

  bool get isEnglish => state == AppLanguage.enUs;
  bool get isPortuguese => state == AppLanguage.ptBr;
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);
