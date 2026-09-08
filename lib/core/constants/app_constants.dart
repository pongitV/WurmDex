/// Application-wide constants to eliminate hardcoded magic numbers and strings.
abstract final class AppConstants {
  // Financial & Exchange Rates
  static const double defaultUsdToBrlRate = 5.60;
  static const Duration exchangeRateCacheDuration = Duration(hours: 2);

  // Network & API Endpoints
  static const String tcgdexBaseUrl = 'https://api.tcgdex.net/v2';
  static const String awesomeApiUsdBrlUrl = 'https://economia.awesomeapi.com.br/last/USD-BRL';
  static const String officialPokemonNewsRssUrl = 'https://www.pokemon.com/us/pokemon-news/rss';

  // Binder & Folio Geometry
  static const int binderSlotsPerPage = 9;
  static const int binderSpineRingsCount = 6;
  static const double binderPunchHoleAxisX = 10.0;
  static const double binderDefaultCardAspectRatio = 0.70;

  // Universal Card Dimensions & Aspect Ratios
  /// Universal physical standard aspect ratio of all Pokémon TCG cards (63mm x 88mm / 2.5in x 3.5in)
  static const double pokemonCardAspectRatio = 63.0 / 88.0; // ~0.7159

  /// Standardized GridView childAspectRatio for card catalog & gallery items (card ratio + metadata footer)
  static const double cardGridItemAspectRatio = 0.58;

  /// Optimal aspect ratio of a 3x3 binder sheet (3 columns x 3 rows of standard cards + ring eyelet margins)
  static const double binderSheetAspectRatio = 0.755;

  /// Vertical clearance reserved for binder folio leather padding
  static const double binderLeatherMarginV = 48.0;

  // Defaults & Placeholders
  static const String defaultBinderFolderName = 'WurmDex';
  static const String defaultCardCondition = 'Near Mint';
  static const String defaultCardFinish = 'Regular';
  static const String defaultCardSupertype = 'Pokémon';
}
