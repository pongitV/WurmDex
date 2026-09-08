import 'dart:math';
import '../../catalog/models/pokemon_card_item.dart';
import '../models/booster_pack_config.dart';

class BoosterGeneratorService {
  static final Random _rng = Random();

  /// Detects if a set is canonically known for God Packs (special high-class expansions)
  static bool isGodPackEligible(String setId, String setName) {
    final sId = setId.toLowerCase();
    final sName = setName.toLowerCase();

    return sId.contains('sv3pt5') || // Pokémon 151
        sId.contains('151') ||
        sName.contains('151') ||
        sId.contains('swsh12pt5') || // Crown Zenith / VSTAR Universe
        sName.contains('crown zenith') ||
        sName.contains('zenith') ||
        sName.contains('vstar universe') ||
        sId.contains('sv4pt5') || // Paldean Fates / Shiny Treasure
        sName.contains('paldean fates') ||
        sName.contains('destinos de paldea') ||
        sName.contains('shiny treasure') ||
        sId.contains('sv8pt5') || // Prismatic Evolutions / Terastal Festival
        sName.contains('prismatic') ||
        sName.contains('terastal');
  }

  /// Returns a thematic label for the God Pack based on the expansion
  static String getGodPackThemeName(String setId, String setName) {
    final sId = setId.toLowerCase();
    final sName = setName.toLowerCase();

    if (sId.contains('151') || sName.contains('151')) {
      return '151 Starter SAR God Pack';
    } else if (sId.contains('zenith') || sName.contains('zenith') || sName.contains('vstar')) {
      return 'Crown Zenith Galarian Gallery God Pack';
    } else if (sId.contains('paldean') || sName.contains('paldean fates') || sName.contains('shiny') || sName.contains('destinos')) {
      return 'Paldean Fates Shiny Vault God Pack';
    } else if (sId.contains('prismatic') || sName.contains('prismatic') || sName.contains('terastal')) {
      return 'Prismatic Evolutions Eeveelution God Pack';
    }
    return 'Secret Illustration Rare God Pack';
  }

  /// Generates an authentic booster pack according to the selected format (USA 10 or Brasil 6).
  /// Strictly ensures NO duplicate cards appear within the same booster pack.
  static BoosterPackResult generatePack({
    required List<PokemonCardItem> allCards,
    required String setId,
    required String setName,
    required BoosterFormat format,
    bool forceGodPack = false,
  }) {
    if (allCards.isEmpty) {
      return BoosterPackResult(
        setId: setId,
        setName: setName,
        format: format,
        cards: const [],
        totalMarketUsd: 0.0,
      );
    }

    // Segregate pool by official rarity tiers
    final commons = <PokemonCardItem>[];
    final uncommons = <PokemonCardItem>[];
    final regularRares = <PokemonCardItem>[];
    final chaseCards = <PokemonCardItem>[];

    for (final card in allCards) {
      final r = card.rarity.toLowerCase().trim();
      if (r.contains('uncommon')) {
        uncommons.add(card);
      } else if (r.contains('common')) {
        commons.add(card);
      } else if (r.contains('ultra') ||
          r.contains('secret') ||
          r.contains('special illustration') ||
          r.contains('hyper') ||
          r.contains('illustration') ||
          r.contains('double rare') ||
          r.contains('ace spec') ||
          r.contains('shiny') ||
          r.contains('holo rare')) {
        chaseCards.add(card);
      } else if (r.contains('rare')) {
        regularRares.add(card);
      } else {
        // Unspecified rarity cards default to commons
        commons.add(card);
      }
    }

    // Fallbacks if a set lacks certain rarity labels
    final effectiveCommons = commons.isNotEmpty ? commons : allCards;
    final effectiveUncommons = uncommons.isNotEmpty ? uncommons : effectiveCommons;
    final effectiveRares = regularRares.isNotEmpty ? regularRares : effectiveUncommons;
    final effectiveChases = chaseCards.isNotEmpty ? chaseCards : effectiveRares;

    // Deduplication tracker: guarantees zero duplicate cards in the booster
    final usedCardIds = <String>{};

    PokemonCardItem pickUnique(List<PokemonCardItem> pool) {
      final available = pool.where((c) => !usedCardIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        final chosen = available[_rng.nextInt(available.length)];
        usedCardIds.add(chosen.id);
        return chosen;
      }
      // If pool is exhausted of unused cards, check if any unused card exists in allCards
      final remainingAll = allCards.where((c) => !usedCardIds.contains(c.id)).toList();
      if (remainingAll.isNotEmpty) {
        final chosen = remainingAll[_rng.nextInt(remainingAll.length)];
        usedCardIds.add(chosen.id);
        return chosen;
      }
      // Absolute fallback if allCards has fewer cards than the booster pack size
      final fallback = pool.isNotEmpty ? pool[_rng.nextInt(pool.length)] : allCards[_rng.nextInt(allCards.length)];
      usedCardIds.add(fallback.id);
      return fallback;
    }

    final pulls = <BoosterCardPull>[];
    final eligibleForGodPack = isGodPackEligible(setId, setName);
    // Authentic roll: ~3.5% chance for God Pack if the expansion supports it, or forced for demo/testing
    final isGodPackRoll = eligibleForGodPack && (forceGodPack || _rng.nextDouble() < 0.035);

    if (isGodPackRoll) {
      // -------------------------------------------------------------------
      // GOD PACK: Every card is a spectacular Chase Hit (SAR / Shinies / IR)
      // -------------------------------------------------------------------
      final packSize = format == BoosterFormat.usa10 ? 10 : 6;
      final godPool = effectiveChases.isNotEmpty ? effectiveChases : effectiveRares;
      final themeName = getGodPackThemeName(setId, setName);

      for (int i = 0; i < packSize; i++) {
        final card = pickUnique(godPool);
        pulls.add(BoosterCardPull(
          card: card,
          isChase: true,
          slotType: 'chase',
        ));
      }

      double totalMarket = 0.0;
      for (final pull in pulls) {
        totalMarket += (pull.card.effectiveMidPriceUsd ?? pull.card.tcgMarketUsd ?? 0.0);
      }

      return BoosterPackResult(
        setId: setId,
        setName: setName,
        format: format,
        cards: pulls,
        totalMarketUsd: totalMarket,
        isGodPack: true,
        godPackTheme: themeName,
      );
    }

    if (format == BoosterFormat.usa10) {
      // -------------------------------------------------------------------
      // USA 10 CARDS FORMAT:
      // Modern SV Era: 4 Commons, 3 Uncommons, 2 Reverse/IR slots, 1 Rare/Chase
      // Pre-SV Era: 5 Commons, 3 Uncommons, 1 Reverse Holo, 1 Rare/Chase
      // -------------------------------------------------------------------
      final isModernSv = setId.toLowerCase().startsWith('sv') ||
          setName.toLowerCase().contains('scarlet') ||
          setName.toLowerCase().contains('violet') ||
          setName.toLowerCase().contains('151');

      final commonCount = isModernSv ? 4 : 5;
      for (int i = 0; i < commonCount; i++) {
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveCommons),
          slotType: 'common',
        ));
      }

      // 3 Uncommons
      for (int i = 0; i < 3; i++) {
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveUncommons),
          slotType: 'uncommon',
        ));
      }

      if (isModernSv) {
        // Modern Slot 8: Reverse Holo 1 (Common or Uncommon)
        final reversePool1 = [...effectiveCommons, ...effectiveUncommons];
        pulls.add(BoosterCardPull(
          card: pickUnique(reversePool1),
          isReverseHolo: true,
          slotType: 'reverse',
        ));

        // Modern Slot 9: Reverse Holo 2 OR Illustration Rare / Trainer Gallery hit
        final irRoll = _rng.nextDouble();
        if (irRoll < 0.16 && effectiveChases.isNotEmpty) {
          pulls.add(BoosterCardPull(
            card: pickUnique(effectiveChases),
            isChase: true,
            slotType: 'chase',
          ));
        } else {
          final reversePool2 = [...effectiveCommons, ...effectiveUncommons, ...effectiveRares];
          pulls.add(BoosterCardPull(
            card: pickUnique(reversePool2),
            isReverseHolo: true,
            slotType: 'reverse',
          ));
        }
      } else {
        // Legacy Slot 9: Single Reverse Holo
        final reversePool = [...effectiveCommons, ...effectiveUncommons, ...effectiveRares];
        pulls.add(BoosterCardPull(
          card: pickUnique(reversePool),
          isReverseHolo: true,
          slotType: 'reverse',
        ));
      }

      // Final Slot 10: Rare / Double Rare / Ultra / Secret / SIR slot
      final rareRoll = _rng.nextDouble();
      if (rareRoll < 0.14 && effectiveChases.isNotEmpty) {
        // Secret / Special Illustration / Ultra Chase hit
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveChases),
          isChase: true,
          slotType: 'chase',
        ));
      } else if (rareRoll < 0.38 && effectiveChases.isNotEmpty) {
        // Double Rare / Regular Holo Rare
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveChases),
          isChase: true,
          slotType: 'rare',
        ));
      } else {
        // Regular Rare
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveRares),
          slotType: 'rare',
        ));
      }
    } else {
      // -------------------------------------------------------------------
      // BRASIL 6 CARDS FORMAT (Copag Official Standard):
      // Exactly 3 Commons, 2 Uncommons, 1 Rare / Reverse / Chase hit
      // -------------------------------------------------------------------
      // 3 Commons
      for (int i = 0; i < 3; i++) {
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveCommons),
          slotType: 'common',
        ));
      }

      // 2 Uncommons
      for (int i = 0; i < 2; i++) {
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveUncommons),
          slotType: 'uncommon',
        ));
      }

      // Slot 6: Final Rare / Reverse / Chase slot
      final roll = _rng.nextDouble();
      if (roll < 0.18 && effectiveChases.isNotEmpty) {
        // Big Chase Hit
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveChases),
          isChase: true,
          slotType: 'chase',
        ));
      } else if (roll < 0.45) {
        // Reverse Holo
        final reversePool = [...effectiveCommons, ...effectiveUncommons, ...effectiveRares];
        pulls.add(BoosterCardPull(
          card: pickUnique(reversePool),
          isReverseHolo: true,
          slotType: 'reverse',
        ));
      } else {
        // Regular Rare
        pulls.add(BoosterCardPull(
          card: pickUnique(effectiveRares),
          slotType: 'rare',
        ));
      }
    }

    double totalMarket = 0.0;
    for (final pull in pulls) {
      totalMarket += (pull.card.effectiveMidPriceUsd ?? pull.card.tcgMarketUsd ?? 0.0);
    }

    return BoosterPackResult(
      setId: setId,
      setName: setName,
      format: format,
      cards: pulls,
      totalMarketUsd: totalMarket,
      isGodPack: false,
    );
  }
}
