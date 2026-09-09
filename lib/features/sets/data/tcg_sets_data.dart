class TcgSetsData {
  TcgSetsData._();

  /// Predefined mapping of set IDs to release years for accurate chronological grouping
  static const Map<String, int> setYearMap = {
    // 2026 / Future Mega Evolution
    'me01': 2026,
    'me02': 2026,
    'me02.5': 2026,
    'me03': 2026,
    'me04': 2026,
    'me05': 2026,
    'mee': 2026,
    'mep': 2026,

    // 2025
    'sv08.5': 2025,
    'sv09': 2025,
    'sv10': 2025,
    'sv10.5b': 2025,
    'sv10.5w': 2025,

    // 2024
    'sv04.5': 2024,
    'sv05': 2024,
    'sv06': 2024,
    'sv06.5': 2024,
    'sv07': 2024,
    'sv08': 2024,
    '2024sv': 2024,

    // 2023
    'sv01': 2023,
    'sve': 2023,
    'svp': 2023,
    'sv02': 2023,
    '2023sv': 2023,
    'sv03': 2023,
    'sv03.5': 2023,
    'mfb': 2023,
    'sv04': 2023,
    'swsh12.5': 2023,
    'swsh12.5gg': 2023,

    // 2022
    'swsh9': 2022,
    'swsh9tg': 2022,
    'swsh10': 2022,
    'swsh10tg': 2022,
    'swsh10.5': 2022,
    '2022swsh': 2022,
    'swsh11': 2022,
    'swsh11tg': 2022,
    'swsh12': 2022,
    'swsh12tg': 2022,

    // 2021
    'swsh4.5': 2021,
    'swsh4.5sv': 2021,
    'swsh5': 2021,
    'swsh6': 2021,
    'swsh7': 2021,
    'cel25': 2021,
    'cel25cc': 2021,
    'swsh8': 2021,
    '2021swsh': 2021,

    // 2020
    'swsh1': 2020,
    'swsh2': 2020,
    'swsh3': 2020,
    'fut2020': 2020,
    'swsh3.5': 2020,
    'swsh4': 2020,
    'swshp': 2020,

    // 2019
    'sm9': 2019,
    'det1': 2019,
    'sm10': 2019,
    'sm11': 2019,
    'sma': 2019,
    'sm115': 2019,
    '2019sm': 2019,
    'sm12': 2019,

    // 2018
    'sm5': 2018,
    'sm6': 2018,
    'sm7': 2018,
    'sm7.5': 2018,
    '2018sm': 2018,
    'sm8': 2018,

    // 2017
    'sm1': 2017,
    'smp': 2017,
    'tk-sm-r': 2017,
    'tk-sm-l': 2017,
    'sm2': 2017,
    '2017sm': 2017,
    'sm3': 2017,
    'sm3.5': 2017,
    'sm4': 2017,

    // 2016
    'xy9': 2016,
    'g1': 2016,
    'tk-xy-p': 2016,
    'tk-xy-su': 2016,
    'xy10': 2016,
    'xy11': 2016,
    '2016xy': 2016,
    'xy12': 2016,

    // 2015
    'xy5': 2015,
    'dc1': 2015,
    'tk-xy-latio': 2015,
    'tk-xy-latia': 2015,
    'xy6': 2015,
    'xy7': 2015,
    'xy8': 2015,
    '2015xy': 2015,

    // 2014
    'xy0': 2014,
    'xy1': 2014,
    'xya': 2014,
    'tk-xy-n': 2014,
    'tk-xy-sy': 2014,
    'xy2': 2014,
    '2014xy': 2014,
    'xy3': 2014,
    'tk-xy-b': 2014,
    'tk-xy-w': 2014,
    'xy4': 2014,
    'xyp': 2014,

    // 2013
    'bw8': 2013,
    'bw9': 2013,
    'bw10': 2013,
    'bw11': 2013,
    'rc': 2013,

    // 2012
    'bw4': 2012,
    'bw5': 2012,
    '2012bw': 2012,
    'bw6': 2012,
    'dv1': 2012,
    'bw7': 2012,

    // 2011
    'col1': 2011,
    'bw1': 2011,
    'bwp': 2011,
    '2011bw': 2011,
    'bw2': 2011,
    'tk-bw-e': 2011,
    'tk-bw-z': 2011,
    'bw3': 2011,

    // 2010
    'hgss1': 2010,
    'hgssp': 2010,
    'tk-hs-r': 2010,
    'tk-hs-g': 2010,
    'hgss2': 2010,
    'hgss3': 2010,
    'hgss4': 2010,

    // 2009
    'pl1': 2009,
    'pop9': 2009,
    'pl2': 2009,
    'pl3': 2009,
    'pl4': 2009,
    'ru1': 2009,

    // 2008
    'dp4': 2008,
    'pop7': 2008,
    'dp5': 2008,
    'dp6': 2008,
    'pop8': 2008,
    'dp7': 2008,

    // 2007
    'dpp': 2007,
    'dp1': 2007,
    'dp2': 2007,
    'pop6': 2007,
    'tk-dp-l': 2007,
    'tk-dp-m': 2007,
    'dp3': 2007,

    // 2006
    'ex11': 2006,
    'ex12': 2006,
    'tk-ex-m': 2006,
    'tk-ex-p': 2006,
    'pop3': 2006,
    'ex13': 2006,
    'pop4': 2006,
    'ex14': 2006,
    'ex15': 2006,
    'ex16': 2006,
    'pop5': 2006,

    // 2005
    'pop2': 2005,
    'ex8': 2005,
    'ex9': 2005,
    'ex10': 2005,
    'exu': 2005,

    // 2004
    'ex4': 2004,
    'ex5': 2004,
    'ex5.5': 2004,
    'tk-ex-latia': 2004,
    'tk-ex-latio': 2004,
    'ex6': 2004,
    'pop1': 2004,
    'ex7': 2004,

    // 2003
    'ex1': 2003,
    'ex2': 2003,
    'np': 2003,
    'ex3': 2003,

    // 2002
    'lc': 2002,
    'sp': 2002,
    'ecard1': 2002,
    'bog': 2002,
    'ecard2': 2002,
    'ecard3': 2002,

    // 2001
    'neo3': 2001,
    'neo4': 2001,

    // 2000
    'base4': 2000,
    'base5': 2000,
    'gym1': 2000,
    'gym2': 2000,
    'neo1': 2000,
    'neo2': 2000,
    'si1': 2000,

    // 1999
    'base1': 1999,
    'base2': 1999,
    'basep': 1999,
    'wp': 1999,
    'base3': 1999,
    'jumbo': 1999,
    'miscp': 1999,
  };


  /// High-definition sealed product photos for released and upcoming expansions
  static const Map<String, Map<String, String>> productImages = {
    // 2024 - 2025 Scarlet & Violet
    'sv08': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/581898_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/581902_200w.jpg',
    },
    'sv07': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/562143_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/562142_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/562145_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/562147_200w.jpg',
    },
    'sv06': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/545934_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/545933_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/545936_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/545938_200w.jpg',
    },
    'sv06.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/552174_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/552176_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/552177_200w.jpg',
    },
    'sv05': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/535174_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/535173_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/535176_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/535178_200w.jpg',
    },
    'sv04.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/527581_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/527583_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/527585_200w.jpg',
    },
    'sv04': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/517173_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/517172_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/517175_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/517177_200w.jpg',
    },
    'sv03.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/500694_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/500698_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/500696_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/500700_200w.jpg',
    },
    'sv03': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/497678_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/497677_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/497680_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/497682_200w.jpg',
    },
    'sv02': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/491326_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/491325_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/491328_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/491330_200w.jpg',
    },
    'sv01': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/476839_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/476838_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/476841_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/476843_200w.jpg',
    },
    // Upcoming Releases (2025 - 2026)
    'sv08.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/594017_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/594020_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/594019_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/594022_200w.jpg',
    },
    'sv09': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605123_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/605122_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/605125_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/605127_200w.jpg',
    },
    'sv10': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605124_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/605122_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/605125_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/594019_200w.jpg',
    },
    'sv10.5w': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605124_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
    },
    'sv10.5b': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/605124_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
    },
    'me01': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/581898_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/581900_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/500696_200w.jpg',
    },
    'me02': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/581898_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/581897_200w.jpg',
    },
    'me02.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/594017_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/594020_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/594019_200w.jpg',
    },
    // Sword & Shield
    'swsh12.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/452909_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/452912_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/452914_200w.jpg',
    },
    'swsh12': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/285268_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/285267_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/285270_200w.jpg',
    },
    'swsh11': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/276844_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/276843_200w.jpg',
      'bundle': 'https://tcgplayer-cdn.tcgplayer.com/product/276846_200w.jpg',
    },
    'swsh10': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/265888_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/265887_200w.jpg',
    },
    'swsh9': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/257271_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/257270_200w.jpg',
    },
    'cel25': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/246445_200w.jpg',
      'upc': 'https://tcgplayer-cdn.tcgplayer.com/product/246447_200w.jpg',
    },
    'swsh8': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/247074_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/247073_200w.jpg',
    },
    'swsh7': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/242436_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/242435_200w.jpg',
    },
    'swsh6': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/239016_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/239015_200w.jpg',
    },
    'swsh5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/232047_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/232046_200w.jpg',
    },
    'swsh4.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/231439_200w.jpg',
    },
    'swsh4': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/223292_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/223291_200w.jpg',
    },
    'swsh3.5': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/218765_200w.jpg',
    },
    'swsh3': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/215443_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/215442_200w.jpg',
    },
    'swsh2': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/211029_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/211028_200w.jpg',
    },
    'swsh1': {
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/206411_200w.jpg',
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/206410_200w.jpg',
    },
    // Vintage
    'base1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205934_200w.jpg',
      'blister': 'https://tcgplayer-cdn.tcgplayer.com/product/205934_200w.jpg',
    },
    'base2': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205943_200w.jpg',
    },
    'base3': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205942_200w.jpg',
    },
    'base5': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205947_200w.jpg',
    },
    'gym1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205945_200w.jpg',
    },
    'neo1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/205948_200w.jpg',
    },
    'xy12': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/124314_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/124316_200w.jpg',
    },
    'sm1': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/127607_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/127609_200w.jpg',
    },
    'sm5': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/157297_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/157299_200w.jpg',
    },
    'sm9': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/183604_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/183606_200w.jpg',
    },
    'sm10': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/188358_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/188360_200w.jpg',
    },
    'sm11': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/194488_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/194490_200w.jpg',
    },
    'sm12': {
      'booster_box': 'https://tcgplayer-cdn.tcgplayer.com/product/199923_200w.jpg',
      'etb': 'https://tcgplayer-cdn.tcgplayer.com/product/199925_200w.jpg',
    },
  };

  /// Set IDs of confirmed upcoming expansions
  static const Set<String> upcomingSetIds = {
    'sv10',
    'sv10.5b',
    'sv10.5w',
    'me01',
    'me02',
    'me02.5',
    'me03',
    'me04',
    'me05',
    'mee',
    'mep',
  };

  /// Checks if a set ID or name belongs to digital-only games (Pokémon TCG Pocket, TCG Live/Online)
  static bool isDigitalGameSet(String setId, [String? setName]) {
    final lowerId = setId.trim().toLowerCase();
    final lowerName = setName?.toLowerCase() ?? '';

    // Pokémon TCG Pocket series A sets (A1, A1a, A2, A2a, A2b, A3, A4, etc.)
    if (RegExp(r'^a\d', caseSensitive: false).hasMatch(lowerId)) return true;
    // Pokémon TCG Pocket series B sets (B1, B1a, B2, etc.)
    if (RegExp(r'^b\d', caseSensitive: false).hasMatch(lowerId)) return true;
    // Promos-A / Promo-A
    if (lowerId == 'p-a' || lowerId.startsWith('p-a') || lowerId == 'pa') return true;
    // Digital identifiers
    if (lowerId.contains('tcgp') || lowerId.contains('pocket') || lowerId.contains('tcgo')) return true;
    if (lowerName.contains('pocket') || lowerName.contains('tcgp')) return true;

    return false;
  }

  /// Checks if a card belongs to a digital-only game (Pokémon TCG Pocket)
  static bool isDigitalCard({
    required String cardId,
    String? setId,
    String? setName,
    String? imageUrlSmall,
    String? imageUrlLarge,
  }) {
    if (setId != null && isDigitalGameSet(setId, setName)) return true;
    final lowerId = cardId.trim().toLowerCase();
    if (RegExp(r'^(a\d|b\d|p-a|tcgp|pocket)', caseSensitive: false).hasMatch(lowerId)) return true;
    if (imageUrlSmall != null && (imageUrlSmall.contains('/tcgp/') || imageUrlSmall.contains('/pocket/'))) return true;
    if (imageUrlLarge != null && (imageUrlLarge.contains('/tcgp/') || imageUrlLarge.contains('/pocket/'))) return true;
    return false;
  }
}
