import 'package:flutter/material.dart';

/// Small visual badge displaying the country flag corresponding to the card language.
/// Common Pokémon TCG language codes:
/// - PT / PT-BR: Brazil 🇧🇷
/// - EN / US: United States 🇺🇸
/// - JP / JA: Japan 🇯🇵
/// - Other ISO codes supported gracefully.
class LanguageFlagBadge extends StatelessWidget {
  final String language;
  final bool compact;
  final double? fontSize;
  final bool showCode;

  const LanguageFlagBadge({
    super.key,
    required this.language,
    this.compact = false,
    this.fontSize,
    this.showCode = false,
  });

  /// Helper to get flag emoji for a language code
  static String getFlagEmoji(String lang) {
    final clean = lang.trim().toUpperCase();
    if (clean.contains('PT') || clean.contains('BR')) return '🇧🇷';
    if (clean.contains('EN') || clean.contains('US')) return '🇺🇸';
    if (clean.contains('JP') || clean.contains('JA')) return '🇯🇵';
    if (clean.contains('ES')) return '🇪🇸';
    if (clean.contains('FR')) return '🇫🇷';
    if (clean.contains('DE')) return '🇩🇪';
    if (clean.contains('IT')) return '🇮🇹';
    if (clean.contains('KR') || clean.contains('KO')) return '🇰🇷';
    if (clean.contains('CN') || clean.contains('ZH')) return '🇨🇳';
    return '🌐';
  }

  /// Helper to get country/language label
  static String getLanguageLabel(String lang, {bool isEn = false}) {
    final clean = lang.trim().toUpperCase();
    if (clean.contains('PT') || clean.contains('BR')) {
      return isEn ? 'Portuguese (BR)' : 'Português (Brasil)';
    }
    if (clean.contains('EN') || clean.contains('US')) {
      return isEn ? 'English (US)' : 'Inglês (EUA)';
    }
    if (clean.contains('JP') || clean.contains('JA')) {
      return isEn ? 'Japanese (JP)' : 'Japonês (Japão)';
    }
    if (clean.contains('CN') || clean.contains('ZH')) {
      return isEn ? 'Chinese (CN)' : 'Chinês (China)';
    }
    if (clean.contains('ES')) {
      return isEn ? 'Spanish (ES)' : 'Espanhol (Espanha)';
    }
    if (clean.contains('KR') || clean.contains('KO')) {
      return isEn ? 'Korean (KR)' : 'Coreano (Coreia)';
    }
    return lang;
  }

  /// Normalized code
  static String normalizeCode(String lang) {
    final clean = lang.trim().toUpperCase();
    if (clean.contains('PT') || clean.contains('BR')) return 'PT';
    if (clean.contains('EN') || clean.contains('US')) return 'EN';
    if (clean.contains('JP') || clean.contains('JA')) return 'JP';
    if (clean.contains('CN') || clean.contains('ZH')) return 'CN';
    if (clean.contains('ES')) return 'ES';
    if (clean.contains('KR') || clean.contains('KO')) return 'KR';
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flag = getFlagEmoji(language);
    final code = normalizeCode(language);
    final size = fontSize ?? (compact ? 10.5 : 12.5);

    return Tooltip(
      message: getLanguageLabel(language),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4.5 : 7.0,
          vertical: compact ? 1.0 : 2.5,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(compact ? 4.0 : 6.0),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: compact ? 0.7 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              flag,
              style: TextStyle(
                fontSize: size,
                height: 1.1,
              ),
            ),
            if (showCode) ...[
              const SizedBox(width: 3.5),
              Text(
                code,
                style: TextStyle(
                  fontSize: compact ? 8.5 : 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
