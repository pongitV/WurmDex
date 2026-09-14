import 'package:flutter/material.dart';
import '../database/app_database.dart';
import 'card_pricing_helper.dart';
import '../../features/catalog/models/catalog_filter_state.dart';
import '../../features/catalog/models/pokemon_card_item.dart';

class CardSortingHelper {
  /// Sorts a list of cards according to the specified sort option
  static List<PokemonCardItem> sort(
    List<PokemonCardItem> cards,
    CatalogSortOption option,
  ) {
    final list = List<PokemonCardItem>.from(cards);

    switch (option) {
      case CatalogSortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case CatalogSortOption.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case CatalogSortOption.priceDesc:
        list.sort((a, b) => (b.tcgMarketUsd ?? 0.0).compareTo(a.tcgMarketUsd ?? 0.0));
        break;

      case CatalogSortOption.priceAsc:
        list.sort((a, b) => (a.tcgMarketUsd ?? 0.0).compareTo(b.tcgMarketUsd ?? 0.0));
        break;

      case CatalogSortOption.releaseDateDesc:
        list.sort((a, b) {
          final yearA = _estimateCardYear(a);
          final yearB = _estimateCardYear(b);
          final comp = yearB.compareTo(yearA);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        });
        break;

      case CatalogSortOption.releaseDateAsc:
        list.sort((a, b) {
          final yearA = _estimateCardYear(a);
          final yearB = _estimateCardYear(b);
          final comp = yearA.compareTo(yearB);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        });
        break;

      case CatalogSortOption.popularityDesc:
        list.sort((a, b) {
          final popA = _calculatePopularity(a);
          final popB = _calculatePopularity(b);
          return popB.compareTo(popA);
        });
        break;

      case CatalogSortOption.numberAsc:
        list.sort((a, b) {
          final numA = _extractNumeric(a.number);
          final numB = _extractNumeric(b.number);
          final comp = numA.compareTo(numB);
          if (comp != 0) return comp;
          return a.number.compareTo(b.number);
        });
        break;
    }

    return list;
  }

  static int _extractNumeric(String rawNumber) {
    final cleaned = rawNumber.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(cleaned) ?? 99999;
  }

  static int _estimateCardYear(PokemonCardItem card) {
    final sid = card.setId.toLowerCase();
    if (sid.startsWith('me') || sid.startsWith('mega') || sid.startsWith('sv11') || sid.startsWith('sv12')) return 2026;
    if (sid.startsWith('sv09') || sid.startsWith('sv10') || sid.startsWith('a3') || sid.startsWith('a4')) return 2025;
    if (sid.startsWith('sv05') || sid.startsWith('sv06') || sid.startsWith('sv07') || sid.startsWith('sv08')) return 2024;
    if (sid.startsWith('sv')) return 2023;
    if (sid.startsWith('swsh10') || sid.startsWith('swsh11') || sid.startsWith('swsh12')) return 2022;
    if (sid.startsWith('swsh4') || sid.startsWith('swsh5') || sid.startsWith('swsh6') || sid.startsWith('swsh7') || sid.startsWith('swsh8') || sid.startsWith('cel25')) return 2021;
    if (sid.startsWith('swsh')) return 2020;
    if (sid.startsWith('sm9') || sid.startsWith('sm10') || sid.startsWith('sm11') || sid.startsWith('sm12') || sid.startsWith('sma')) return 2019;
    if (sid.startsWith('sm5') || sid.startsWith('sm6') || sid.startsWith('sm7') || sid.startsWith('sm8')) return 2018;
    if (sid.startsWith('sm')) return 2017;
    if (sid.startsWith('xy9') || sid.startsWith('xy10') || sid.startsWith('xy11') || sid.startsWith('xy12') || sid.startsWith('g1')) return 2016;
    if (sid.startsWith('xy5') || sid.startsWith('xy6') || sid.startsWith('xy7') || sid.startsWith('xy8')) return 2015;
    if (sid.startsWith('xy')) return 2014;
    if (sid.startsWith('bw8') || sid.startsWith('bw9') || sid.startsWith('bw10') || sid.startsWith('bw11')) return 2013;
    if (sid.startsWith('bw')) return 2011;
    if (sid.startsWith('hgss') || sid.startsWith('col')) return 2010;
    if (sid.startsWith('pl')) return 2009;
    if (sid.startsWith('dp')) return 2007;
    if (sid.startsWith('ex')) return 2004;
    if (sid.startsWith('ecard') || sid.startsWith('lc')) return 2002;
    if (sid.startsWith('neo')) return 2000;
    if (sid.startsWith('gym') || sid.startsWith('base')) return 1999;
    return 2023;
  }

  static double _calculatePopularity(PokemonCardItem card) {
    double score = (card.tcgMarketUsd ?? 0.0);
    final r = card.rarity.toLowerCase();
    if (r.contains('special') || r.contains('illustration') || r.contains('secret') || r.contains('hyper')) {
      score += 60.0;
    } else if (r.contains('ultra') || r.contains('vstar') || r.contains('vmax') || r.contains('ex')) {
      score += 30.0;
    } else if (r.contains('holo') || r.contains('rare')) {
      score += 10.0;
    }
    return score;
  }

  /// User-friendly label for a sort option
  static String getSortLabel(CatalogSortOption option, bool isEn) {
    switch (option) {
      case CatalogSortOption.nameAsc:
        return isEn ? 'Name (A-Z)' : 'Nome (A-Z)';
      case CatalogSortOption.nameDesc:
        return isEn ? 'Name (Z-A)' : 'Nome (Z-A)';
      case CatalogSortOption.priceDesc:
        return isEn ? 'Price: High to Low' : 'Maior Preço';
      case CatalogSortOption.priceAsc:
        return isEn ? 'Price: Low to High' : 'Menor Preço';
      case CatalogSortOption.releaseDateDesc:
        return isEn ? 'Release Date: Newest' : 'Lançamento: Mais Recentes';
      case CatalogSortOption.releaseDateAsc:
        return isEn ? 'Release Date: Oldest' : 'Lançamento: Mais Antigas';
      case CatalogSortOption.popularityDesc:
        return isEn ? 'Sales / Popularity' : 'Mais Vendidas / Popularidade';
      case CatalogSortOption.numberAsc:
        return isEn ? 'Card Number (#)' : 'Número da Carta (#)';
    }
  }

  /// Icon associated with the sort option
  static IconData getSortIcon(CatalogSortOption option) {
    switch (option) {
      case CatalogSortOption.nameAsc:
        return Icons.sort_by_alpha;
      case CatalogSortOption.nameDesc:
        return Icons.sort_by_alpha;
      case CatalogSortOption.priceDesc:
        return Icons.trending_down;
      case CatalogSortOption.priceAsc:
        return Icons.trending_up;
      case CatalogSortOption.releaseDateDesc:
        return Icons.event;
      case CatalogSortOption.releaseDateAsc:
        return Icons.history;
      case CatalogSortOption.popularityDesc:
        return Icons.local_fire_department;
      case CatalogSortOption.numberAsc:
        return Icons.tag;
    }
  }

  /// Sorts a list of UserCard items according to the specified sort option
  static List<UserCard> sortUserCards(
    List<UserCard> cards,
    CatalogSortOption option,
  ) {
    final list = List<UserCard>.from(cards);

    switch (option) {
      case CatalogSortOption.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case CatalogSortOption.nameDesc:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case CatalogSortOption.priceDesc:
        list.sort((a, b) {
          final priceA = CardPricingHelper.getRealisticMarketPriceBrl(
            purchasePriceBrl: a.purchasePriceBrl,
            rarity: a.rarity,
            condition: a.condition,
          );
          final priceB = CardPricingHelper.getRealisticMarketPriceBrl(
            purchasePriceBrl: b.purchasePriceBrl,
            rarity: b.rarity,
            condition: b.condition,
          );
          return priceB.compareTo(priceA);
        });
        break;

      case CatalogSortOption.priceAsc:
        list.sort((a, b) {
          final priceA = CardPricingHelper.getRealisticMarketPriceBrl(
            purchasePriceBrl: a.purchasePriceBrl,
            rarity: a.rarity,
            condition: a.condition,
          );
          final priceB = CardPricingHelper.getRealisticMarketPriceBrl(
            purchasePriceBrl: b.purchasePriceBrl,
            rarity: b.rarity,
            condition: b.condition,
          );
          return priceA.compareTo(priceB);
        });
        break;

      case CatalogSortOption.releaseDateDesc:
        list.sort((a, b) {
          final comp = b.createdAt.compareTo(a.createdAt);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        });
        break;

      case CatalogSortOption.releaseDateAsc:
        list.sort((a, b) {
          final comp = a.createdAt.compareTo(b.createdAt);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        });
        break;

      case CatalogSortOption.popularityDesc:
        list.sort((a, b) {
          final priceA = CardPricingHelper.getRealisticMarketPriceBrl(
            purchasePriceBrl: a.purchasePriceBrl,
            rarity: a.rarity,
            condition: a.condition,
          );
          final priceB = CardPricingHelper.getRealisticMarketPriceBrl(
            purchasePriceBrl: b.purchasePriceBrl,
            rarity: b.rarity,
            condition: b.condition,
          );
          final comp = (b.quantity * priceB).compareTo(a.quantity * priceA);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        });
        break;

      case CatalogSortOption.numberAsc:
        list.sort((a, b) {
          final numA = _extractNumeric(a.number);
          final numB = _extractNumeric(b.number);
          final comp = numA.compareTo(numB);
          if (comp != 0) return comp;
          return a.number.compareTo(b.number);
        });
        break;
    }

    return list;
  }
}
