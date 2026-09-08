class SemanticSearchHelper {
  // Suffixes recognized in Pokemon TCG
  static final List<String> recognizedSuffixes = [
    'ex',
    'EX',
    'VSTAR',
    'V-Astro',
    'VMAX',
    'V-MAX',
    'V',
    'GX',
    'TAG TEAM',
    'Radiant',
    'Radiante',
    'Prime',
    'LEGEND',
    'BREAK',
    'Star',
    'Prism Star',
  ];

  // PT-BR to EN synonyms for sets and terms
  static final Map<String, String> translationSynonyms = {
    'vastro': 'vstar',
    'v-astro': 'vstar',
    'radiante': 'radiant',
    'brilhante': 'shiny',
    'dourado': 'gold',
    'dourada': 'gold',
    'secreta': 'secret',
    'rara': 'rare',
    'espada e escudo': 'sword & shield',
    'escarlate e violeta': 'scarlet & violet',
    'evolucoes em paldea': 'paldea evolved',
    'origem perdida': 'lost origin',
    'cinzas brilhantes': 'shrouded fable',
    'fagulhas fulgurantes': 'surging sparks',
    'forca temporal': 'temporal forces',
    'mascara do crepusculo': 'twilight masquerade',
    'coroa estelar': 'stellar crown',
    'destino de paldea': 'paldean fates',
  };

  /// Normalizes user query for search comparison
  static String normalizeQuery(String query) {
    String normalized = query.trim().toLowerCase();
    
    // Remove accents
    normalized = normalized
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');

    // Replace known PT synonyms with their EN counterpart for catalog matching
    translationSynonyms.forEach((pt, en) {
      if (normalized.contains(pt)) {
        normalized = normalized.replaceAll(pt, en);
      }
    });

    return normalized;
  }

  /// Formats a card to the required: Nome-Sufixo(Codigo)
  /// e.g. "Charizard-ex(#125/197)" or "Giratina-VSTAR(#GG69/GG70)"
  static String formatCardIdentifier({
    required String rawName,
    required String number,
    String? setTotal,
  }) {
    String baseName = rawName.trim();
    String suffix = '';

    for (final s in recognizedSuffixes) {
      // Check if name ends with suffix or contains suffix separated by space
      final regex = RegExp(r'\b' + RegExp.escape(s) + r'\b', caseSensitive: false);
      if (regex.hasMatch(baseName)) {
        suffix = s;
        baseName = baseName.replaceAll(regex, '').trim();
        break;
      }
    }

    final cleanBase = baseName.replaceAll(RegExp(r'\s+'), ' ').trim();
    final cleanCode = (setTotal != null && setTotal.isNotEmpty && !number.contains('/'))
        ? '#$number/$setTotal'
        : (number.startsWith('#') ? number : '#$number');

    if (suffix.isNotEmpty) {
      return '$cleanBase-$suffix($cleanCode)';
    } else {
      return '$cleanBase($cleanCode)';
    }
  }
}
