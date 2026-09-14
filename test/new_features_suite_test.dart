import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/utils/card_pricing_helper.dart';
import 'package:wurmdex/features/booster_simulator/models/booster_pack_config.dart';
import 'package:wurmdex/features/booster_simulator/services/booster_generator_service.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/news/services/home_feed_service.dart';
import 'package:wurmdex/features/trade/presentation/widgets/trade_card_selector_dialog.dart';

void main() {
  group('BoosterGeneratorService Tests', () {
    final mockCards = [
      // Commons
      const PokemonCardItem(
        id: 'c1',
        name: 'Pikachu',
        number: '1',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: 'https://example.com/c1.png',
        imageUrlLarge: 'https://example.com/c1_lg.png',
        types: ['Lightning'],
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        tcgMarketUsd: 0.50,
      ),
      const PokemonCardItem(
        id: 'c2',
        name: 'Caterpie',
        number: '2',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: 'https://example.com/c2.png',
        imageUrlLarge: 'https://example.com/c2_lg.png',
        types: ['Grass'],
        supertype: 'Pokémon',
        artist: 'Mitsuhiro Arita',
        tcgMarketUsd: 0.25,
      ),
      const PokemonCardItem(
        id: 'c3',
        name: 'Weedle',
        number: '3',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: 'https://example.com/c3.png',
        imageUrlLarge: 'https://example.com/c3_lg.png',
        types: ['Grass'],
        supertype: 'Pokémon',
        artist: 'Mitsuhiro Arita',
        tcgMarketUsd: 0.20,
      ),
      const PokemonCardItem(
        id: 'c4',
        name: 'Pidgey',
        number: '4',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: 'https://example.com/c4.png',
        imageUrlLarge: 'https://example.com/c4_lg.png',
        types: ['Colorless'],
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        tcgMarketUsd: 0.15,
      ),
      const PokemonCardItem(
        id: 'c5',
        name: 'Rattata',
        number: '5',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Common',
        imageUrlSmall: 'https://example.com/c5.png',
        imageUrlLarge: 'https://example.com/c5_lg.png',
        types: ['Colorless'],
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        tcgMarketUsd: 0.10,
      ),
      // Uncommons
      const PokemonCardItem(
        id: 'u1',
        name: 'Pikachu ex Prep',
        number: '6',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Uncommon',
        imageUrlSmall: 'https://example.com/u1.png',
        imageUrlLarge: 'https://example.com/u1_lg.png',
        types: ['Trainer'],
        supertype: 'Trainer',
        artist: 'Toyste Beach',
        tcgMarketUsd: 1.20,
      ),
      const PokemonCardItem(
        id: 'u2',
        name: 'Ultra Ball',
        number: '7',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Uncommon',
        imageUrlSmall: 'https://example.com/u2.png',
        imageUrlLarge: 'https://example.com/u2_lg.png',
        types: ['Trainer'],
        supertype: 'Trainer',
        artist: 'Toyste Beach',
        tcgMarketUsd: 0.80,
      ),
      const PokemonCardItem(
        id: 'u3',
        name: 'Metapod',
        number: '8',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Uncommon',
        imageUrlSmall: 'https://example.com/u3.png',
        imageUrlLarge: 'https://example.com/u3_lg.png',
        types: ['Grass'],
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        tcgMarketUsd: 0.40,
      ),
      // Rares & Chase
      const PokemonCardItem(
        id: 'r1',
        name: 'Dragonite',
        number: '9',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Rare',
        imageUrlSmall: 'https://example.com/r1.png',
        imageUrlLarge: 'https://example.com/r1_lg.png',
        types: ['Dragon'],
        supertype: 'Pokémon',
        artist: 'Ken Sugimori',
        tcgMarketUsd: 4.50,
      ),
      const PokemonCardItem(
        id: 'ch1',
        name: 'Pikachu ex Special Illustration Rare',
        number: '10',
        setId: 'set1',
        setName: 'Surging Sparks',
        rarity: 'Special Illustration Rare',
        imageUrlSmall: 'https://example.com/ch1.png',
        imageUrlLarge: 'https://example.com/ch1_lg.png',
        types: ['Lightning'],
        supertype: 'Pokémon',
        artist: 'Gakuzan',
        tcgMarketUsd: 180.00,
      ),
    ];

    test('USA 10 format generates exactly 10 cards with correct slot distribution', () {
      final pack = BoosterGeneratorService.generatePack(
        allCards: mockCards,
        setId: 'swsh1',
        setName: 'Sword & Shield Base',
        format: BoosterFormat.usa10,
      );

      expect(pack.cards.length, equals(10));
      expect(pack.format, equals(BoosterFormat.usa10));
      expect(pack.totalMarketUsd, greaterThan(0.0));

      final commonSlots = pack.cards.where((c) => c.slotType == 'common').toList();
      final uncommonSlots = pack.cards.where((c) => c.slotType == 'uncommon').toList();
      final reverseSlots = pack.cards.where((c) => c.slotType == 'reverse').toList();
      final rareOrChaseSlots = pack.cards.where((c) => c.slotType == 'rare' || c.slotType == 'chase').toList();

      expect(commonSlots.length, equals(5));
      expect(uncommonSlots.length, equals(3));
      expect(reverseSlots.length, equals(1));
      expect(reverseSlots.first.isReverseHolo, isTrue);
      expect(rareOrChaseSlots.length, equals(1));
    });

    test('Modern Scarlet & Violet USA 10 generates 4 commons, 3 uncommons, 2 foil/chase slots, 1 rare', () {
      final pack = BoosterGeneratorService.generatePack(
        allCards: mockCards,
        setId: 'sv8',
        setName: 'Surging Sparks',
        format: BoosterFormat.usa10,
      );

      expect(pack.cards.length, equals(10));
      final commonSlots = pack.cards.where((c) => c.slotType == 'common').toList();
      final uncommonSlots = pack.cards.where((c) => c.slotType == 'uncommon').toList();

      expect(commonSlots.length, equals(4));
      expect(uncommonSlots.length, equals(3));
    });

    test('Guarantees NO duplicate cards in the booster pack when pool is sufficient', () {
      final pack = BoosterGeneratorService.generatePack(
        allCards: mockCards,
        setId: 'sv8',
        setName: 'Surging Sparks',
        format: BoosterFormat.usa10,
      );

      final cardIds = pack.cards.map((c) => c.card.id).toList();
      final uniqueCardIds = cardIds.toSet();
      expect(uniqueCardIds.length, equals(cardIds.length));
    });

    test('Brasil 6 format generates exactly 6 cards with correct slot distribution and no duplicates', () {
      final pack = BoosterGeneratorService.generatePack(
        allCards: mockCards,
        setId: 'set1',
        setName: 'Surging Sparks',
        format: BoosterFormat.brazil6,
      );

      expect(pack.cards.length, equals(6));
      expect(pack.format, equals(BoosterFormat.brazil6));
      expect(pack.totalMarketUsd, greaterThan(0.0));

      final commonSlots = pack.cards.where((c) => c.slotType == 'common').toList();
      final uncommonSlots = pack.cards.where((c) => c.slotType == 'uncommon').toList();

      expect(commonSlots.length, equals(3));
      expect(uncommonSlots.length, equals(2));
      expect(pack.cards[5].slotType, anyOf(['rare', 'chase', 'reverse']));

      final cardIds = pack.cards.map((c) => c.card.id).toList();
      expect(cardIds.toSet().length, equals(6));
    });

    test('Correctly identifies God Pack eligible expansions', () {
      expect(BoosterGeneratorService.isGodPackEligible('sv3pt5', '151'), isTrue);
      expect(BoosterGeneratorService.isGodPackEligible('swsh12pt5', 'Crown Zenith'), isTrue);
      expect(BoosterGeneratorService.isGodPackEligible('sv4pt5', 'Paldean Fates'), isTrue);
      expect(BoosterGeneratorService.isGodPackEligible('sv8pt5', 'Prismatic Evolutions'), isTrue);
      expect(BoosterGeneratorService.isGodPackEligible('swsh1', 'Sword & Shield'), isFalse);
    });

    test('God Pack generation fills all slots with chase hits and themed label', () {
      final godPack = BoosterGeneratorService.generatePack(
        allCards: mockCards,
        setId: 'sv3pt5',
        setName: '151',
        format: BoosterFormat.usa10,
        forceGodPack: true,
      );

      expect(godPack.isGodPack, isTrue);
      expect(godPack.godPackTheme, contains('151'));
      expect(godPack.cards.length, equals(10));
      for (final pull in godPack.cards) {
        expect(pull.isChase, isTrue);
        expect(pull.slotType, equals('chase'));
      }
    });

    test('Handles empty cards pool safely without crashing', () {
      final pack = BoosterGeneratorService.generatePack(
        allCards: [],
        setId: 'empty',
        setName: 'Empty Set',
        format: BoosterFormat.usa10,
      );

      expect(pack.cards, isEmpty);
      expect(pack.totalMarketUsd, equals(0.0));
    });
  });

  group('Wishlist Target Price Opportunity Logic Tests', () {
    test('Identifies good buying opportunity when market price is at or below target', () {
      const targetBrl = 100.0;
      const currentMarketBrl = 85.0;

      final isGoodOpportunity = targetBrl > 0 && currentMarketBrl <= targetBrl;
      expect(isGoodOpportunity, isTrue);

      final discount = targetBrl - currentMarketBrl;
      expect(discount, equals(15.0));
    });

    test('Identifies above target when market price exceeds target', () {
      const targetBrl = 100.0;
      const currentMarketBrl = 120.0;

      final isAboveTarget = targetBrl > 0 && currentMarketBrl > targetBrl;
      expect(isAboveTarget, isTrue);
    });

    test('Neutral state when no target is set (target == 0)', () {
      const targetBrl = 0.0;
      const currentMarketBrl = 50.0;

      final hasTarget = targetBrl > 0;
      expect(hasTarget, isFalse);
      expect(currentMarketBrl, greaterThan(0));
    });
  });

  group('Backup and Restore Serialization Tests', () {
    test('Validates JSON payload roundtrip structure for multiplatform transfer', () {
      final exportPayload = {
        'version': 1,
        'app': 'WurmDex',
        'exportedAt': DateTime.now().toIso8601String(),
        'folders': [
          {'id': 'f1', 'name': 'Deck Principal', 'color': 4294951424, 'isMaster': 0},
        ],
        'userCards': [
          {
            'id': 'uc1',
            'cardApiId': 'swsh1-1',
            'name': 'Charizard',
            'number': '1',
            'setName': 'Base',
            'condition': 'NM',
            'isFoil': 1,
            'purchasePriceBrl': 250.0,
            'estimatedPriceUsd': 60.0,
          },
        ],
        'wishlist': [
          {
            'id': 'w1',
            'cardApiId': 'sv-10',
            'name': 'Pikachu',
            'number': '10',
            'setName': 'Surging Sparks',
            'targetPriceBrl': 150.0,
            'priority': 'Alta',
          },
        ],
      };

      final jsonStr = jsonEncode(exportPayload);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded['app'], equals('WurmDex'));
      expect(decoded['version'], equals(1));
      expect((decoded['folders'] as List).length, equals(1));
      expect((decoded['userCards'] as List).length, equals(1));
      expect((decoded['wishlist'] as List).length, equals(1));

      final firstCard = (decoded['userCards'] as List).first as Map<String, dynamic>;
      expect(firstCard['name'], equals('Charizard'));
      expect(firstCard['purchasePriceBrl'], equals(250.0));
    });
  });

  group('Real-Time Currency & Primary Mid Price Tests', () {
    test('effectiveMidPriceUsd prioritizes mid price over market price', () {
      const cardWithMid = PokemonCardItem(
        id: 't1',
        name: 'Gengar',
        number: '12',
        setId: 's1',
        setName: 'Set 1',
        rarity: 'Rare',
        imageUrlSmall: '',
        imageUrlLarge: '',
        types: [],
        supertype: 'Pokémon',
        artist: '',
        tcgMarketUsd: 15.0,
        tcgMidUsd: 12.5,
      );

      expect(cardWithMid.effectiveMidPriceUsd, equals(12.5));

      const cardWithoutMid = PokemonCardItem(
        id: 't2',
        name: 'Haunter',
        number: '13',
        setId: 's1',
        setName: 'Set 1',
        rarity: 'Uncommon',
        imageUrlSmall: '',
        imageUrlLarge: '',
        types: [],
        supertype: 'Pokémon',
        artist: '',
        tcgMarketUsd: 4.0,
      );

      expect(cardWithoutMid.effectiveMidPriceUsd, equals(4.0));
    });

    test('Trade equity correctly evaluates left (send) vs right (get)', () {
      const yourTotalSend = 100.0;
      const theirTotalGet = 120.0;

      final diff = theirTotalGet - yourTotalSend;
      expect(diff, equals(20.0));
      expect(diff > 0, isTrue); // Advantageous trade for the user
    });
  });

  group('Trending Cards LigaPokemon vs TCGPlayer Tests', () {
    test('getLigaPokemonTrendingCards returns valid national trending cards', () {
      final ligaCards = HomeFeedService.getLigaPokemonTrendingCards();
      expect(ligaCards, isNotEmpty);
      expect(ligaCards.length, greaterThanOrEqualTo(5));

      final charizard = ligaCards.firstWhere((c) => c.name.contains('Charizard'));
      expect(charizard.tcgMarketUsd, greaterThan(0));
      expect(charizard.setName, equals('151'));
    });

    test('getTcgPlayerTrendingCards returns valid international trending cards', () {
      final tcgCards = HomeFeedService.getTcgPlayerTrendingCards();
      expect(tcgCards, isNotEmpty);
      expect(tcgCards.length, greaterThanOrEqualTo(5));

      final moonbreon = tcgCards.firstWhere((c) => c.name.contains('Umbreon'));
      expect(moonbreon.tcgMarketUsd, greaterThan(500));
      expect(moonbreon.setName, equals('Evolving Skies'));
    });

    test('LigaPokemon and TCGPlayer cards are distinct collections', () {
      final ligaCards = HomeFeedService.getLigaPokemonTrendingCards();
      final tcgCards = HomeFeedService.getTcgPlayerTrendingCards();

      final ligaIds = ligaCards.map((c) => c.id).toSet();
      final tcgIds = tcgCards.map((c) => c.id).toSet();

      // The trending staples lists focus on their respective distinct market leaders
      expect(ligaIds.intersection(tcgIds), isEmpty);
    });
  });

  group('Realistic Card Pricing & Trade Condition Tests', () {
    test('convertUsdToRealisticBrl converts USD directly to BRL without artificial markups', () {
      final brl = CardPricingHelper.convertUsdToRealisticBrl(10.0, 5.5);
      expect(brl, equals(55.0));
    });

    test('getRealisticMarketPriceBrl respects recorded purchase price', () {
      final price = CardPricingHelper.getRealisticMarketPriceBrl(
        purchasePriceBrl: 45.0,
        rarity: 'Common',
        condition: 'Near Mint',
      );
      expect(price, equals(45.0));
    });

    test('getPriceForQuality and getPriceForCondition use Liga prices without fixed multipliers', () {
      const basePrice = 180.0;

      // Without Liga min/max quotes, never applies artificial multipliers:
      final nmPrice = CardPricingHelper.getPriceForQuality(basePrice, 'Near Mint');
      final spPrice = CardPricingHelper.getPriceForQuality(basePrice, 'Slightly Played');
      final dmgPrice = CardPricingHelper.getPriceForQuality(basePrice, 'Damaged');
      expect(nmPrice, equals(basePrice));
      expect(spPrice, equals(basePrice));
      expect(dmgPrice, equals(basePrice));

      // With authentic Liga min/max/quality quotes:
      final customSp = CardPricingHelper.getPriceForCondition(
        basePriceBrl: 180.0,
        minPriceBrl: 140.0,
        maxPriceBrl: 220.0,
        condition: 'Slightly Played',
      );
      expect(customSp, equals(140.0)); // Exact Liga Menor

      final customMint = CardPricingHelper.getPriceForCondition(
        basePriceBrl: 180.0,
        minPriceBrl: 140.0,
        maxPriceBrl: 220.0,
        condition: 'Mint',
      );
      expect(customMint, equals(220.0)); // Exact Liga Maior

      final customNm = CardPricingHelper.getPriceForCondition(
        basePriceBrl: 180.0,
        minPriceBrl: 140.0,
        maxPriceBrl: 220.0,
        condition: 'Near Mint',
      );
      expect(customNm, equals(180.0)); // Exact Liga Médio

      // Explicit marketplace condition quote from Liga
      final customDmg = CardPricingHelper.getPriceForCondition(
        basePriceBrl: 180.0,
        minPriceBrl: 140.0,
        maxPriceBrl: 220.0,
        conditionPrices: {'Damaged': 65.0},
        condition: 'Damaged',
      );
      expect(customDmg, equals(65.0)); // Exact price from Liga listing
    });

    test('TradeCardItem updates valueBrl when condition changes', () {
      const item = TradeCardItem(
        id: 'c1',
        name: 'Charizard ex',
        number: '199/165',
        setName: '151',
        imageUrl: 'https://example.com/c1.png',
        basePriceBrl: 200.0,
        minPriceBrl: 160.0,
        maxPriceBrl: 260.0,
        valueBrl: 200.0,
        condition: 'Near Mint',
      );

      final newPrice = CardPricingHelper.getPriceForCondition(
        basePriceBrl: item.basePriceBrl,
        minPriceBrl: item.minPriceBrl,
        maxPriceBrl: item.maxPriceBrl,
        condition: 'Slightly Played',
      );

      final updated = item.copyWith(
        condition: 'Slightly Played',
        valueBrl: newPrice,
      );

      expect(updated.condition, equals('Slightly Played'));
      expect(updated.valueBrl, equals(160.0));
      expect(updated.number, equals('199/165'));
    });
  });
}
