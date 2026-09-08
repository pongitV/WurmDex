import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  enUs,
  ptBr,
}

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    // Default language is English En-US
    return AppLanguage.enUs;
  }

  void setLanguage(AppLanguage language) {
    state = language;
  }

  bool get isEnglish => state == AppLanguage.enUs;
  bool get isPortuguese => state == AppLanguage.ptBr;
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);
