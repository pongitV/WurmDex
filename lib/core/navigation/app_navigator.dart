import 'package:flutter/material.dart';
import '../../features/booster_simulator/presentation/booster_opening_screen.dart';
import '../../features/card_details/presentation/card_details_screen.dart';
import '../../features/catalog/models/pokemon_card_item.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/collections/presentation/folder_detail_screen.dart';
import '../../features/collections/presentation/top_cards_podium_screen.dart';
import '../../features/monitoring/models/monitored_card_item.dart';
import '../../features/monitoring/presentation/price_monitoring_screen.dart';
import '../../features/pokedex/models/pokedex_entry.dart';
import '../../features/pokedex/presentation/pokemon_cards_gallery_screen.dart';
import '../../features/sets/models/tcg_set_item.dart';
import '../../features/sets/presentation/set_detail_screen.dart';
import '../database/app_database.dart';

/// Centralized, type-safe navigation helper for WurmDex.
///
/// Encapsulates route generation, transition animations, and parameter passing,
/// decoupling individual feature screens and eliminating repetitive [MaterialPageRoute] boilerplate.
class AppNavigator {
  AppNavigator._();

  /// Pushes a new screen onto the navigation stack with a smooth platform transition.
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(builder: (_) => screen),
    );
  }

  /// Navigates to the comprehensive Card Details screen.
  static Future<void> toCardDetails(
    BuildContext context,
    PokemonCardItem card, {
    String? userCardId,
  }) {
    return push(
      context,
      CardDetailsScreen(
        card: card,
        userCardId: userCardId,
      ),
    );
  }

  /// Navigates to the Folder Detail screen (or General Collection if folder is null).
  static Future<void> toFolder(
    BuildContext context, {
    Folder? folder,
  }) {
    return push(
      context,
      FolderDetailScreen(folder: folder),
    );
  }

  /// Navigates to the Set Detail screen (Cards & Sealed Products for a set).
  static Future<void> toSet(
    BuildContext context, {
    required TcgSetItem set,
  }) {
    return push(
      context,
      SetDetailScreen(set: set),
    );
  }

  /// Navigates to the Pokémon Cards Gallery (all cards for a specific Pokémon species).
  static Future<void> toPokemonGallery(
    BuildContext context, {
    required PokedexEntry pokemon,
  }) {
    return push(
      context,
      PokemonCardsGalleryScreen(pokemon: pokemon),
    );
  }

  /// Navigates to the Booster Pack Opening simulator.
  static Future<void> toBoosterOpening(
    BuildContext context, {
    required TcgSetItem set,
    required List<PokemonCardItem> allCards,
  }) {
    return push(
      context,
      BoosterOpeningScreen(
        set: set,
        allCards: allCards,
      ),
    );
  }

  /// Navigates to the Price Monitoring screen.
  static Future<void> toPriceMonitoring(BuildContext context) {
    return push(
      context,
      const PriceMonitoringScreen(),
    );
  }

  /// Navigates to the Top 10 podium screen.
  static Future<void> toTopCardsPodium(
    BuildContext context, {
    required List<MonitoredCardItem> topMonitored,
  }) {
    return push(
      context,
      TopCardsPodiumScreen(topMonitored: topMonitored),
    );
  }

  /// Navigates to the Catalog screen (optionally targeting a folder for adding cards).
  static Future<void> toCatalog(
    BuildContext context, {
    Folder? targetFolder,
    bool autoFocusSearch = false,
  }) {
    return push(
      context,
      CatalogScreen(
        targetFolder: targetFolder,
        autoFocusSearch: autoFocusSearch,
      ),
    );
  }
}

