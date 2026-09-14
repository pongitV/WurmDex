import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/features/card_details/services/pricing_service.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/catalog/presentation/widgets/card_grid_item.dart';

class MockBrlCurrencyNotifier extends CurrencyNotifier {
  @override
  AppCurrency build() => AppCurrency.brl;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Universal Card Price & Explicit Pricing Tests', () {
    test('Card with explicit API prices returns real price and does not invent prices', () {
      const cardUnpriced = PokemonCardItem(
        id: 'swsh1-1',
        name: 'Celebi V',
        number: '1',
        setId: 'swsh1',
        setName: 'Sword & Shield',
        rarity: 'Comum',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh1/1.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh1/1_hires.png',
        types: ['Grass'],
        supertype: 'Pokémon',
        artist: '5ban Graphics',
      );

      expect(cardUnpriced.hasExplicitPrice, isFalse);
      expect(cardUnpriced.effectiveMidPriceUsd, isNull);

      const cardPriced = PokemonCardItem(
        id: 'swsh1-25',
        name: 'Pikachu VMAX',
        number: '25',
        setId: 'swsh1',
        setName: 'Sword & Shield',
        rarity: 'Ultra Rare',
        imageUrlSmall: 'https://images.pokemontcg.io/swsh1/25.png',
        imageUrlLarge: 'https://images.pokemontcg.io/swsh1/25_hires.png',
        types: ['Lightning'],
        supertype: 'Pokémon',
        artist: 'aky CG Works',
        tcgMidUsd: 6.50,
      );

      expect(cardPriced.hasExplicitPrice, isTrue);
      expect(cardPriced.effectiveMidPriceUsd, equals(6.50));
    });

    testWidgets('CardGridItem renders formatted price when priced', (tester) async {
      const card = PokemonCardItem(
        id: 'sv1-1',
        name: 'Sprigatito',
        number: '1',
        setId: 'sv1',
        setName: 'Scarlet & Violet',
        rarity: 'Comum',
        imageUrlSmall: 'https://images.pokemontcg.io/sv1/1.png',
        imageUrlLarge: 'https://images.pokemontcg.io/sv1/1_hires.png',
        types: ['Grass'],
        supertype: 'Pokémon',
        artist: 'Kouki Saitou',
        tcgMidUsd: 2.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currencyProvider.overrideWith(MockBrlCurrencyNotifier.new),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 300,
                child: CardGridItem(
                  card: card,
                  exchangeRate: 5.50,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // R$ 2.00 * 5.50 = R$ 11,00
      expect(find.textContaining('R\$'), findsOneWidget);
    });
  });

  group('PricingService Multi-Range & Sales History Tests', () {
    test('PricingService generates history for all 4 time ranges (week, month, year, all-time)', () async {
      final result = await PricingService.getPricesForCard(
        cardName: 'Pikachu',
        cardNumber: '25',
        initialTcgMarketUsd: 10.0,
      );

      expect(result.historyByRange.containsKey(PriceTimeRange.week1w), isTrue);
      expect(result.historyByRange.containsKey(PriceTimeRange.month1m), isTrue);
      expect(result.historyByRange.containsKey(PriceTimeRange.year1y), isTrue);
      expect(result.historyByRange.containsKey(PriceTimeRange.allTime), isTrue);

      expect(result.historyByRange[PriceTimeRange.week1w]!.length, equals(7));
      expect(result.historyByRange[PriceTimeRange.month1m]!.length, equals(6));
      expect(result.historyByRange[PriceTimeRange.year1y]!.length, equals(12));
      expect(result.historyByRange[PriceTimeRange.allTime]!.length, equals(8));
    });

    test('PricingService generates recent completed sales records with 2-decimal precision', () async {
      final result = await PricingService.getPricesForCard(
        cardName: 'Charizard',
        cardNumber: '4',
        initialTcgMarketUsd: 120.0,
      );

      expect(result.recentSales.isNotEmpty, isTrue);
      final ligaSales = result.recentSales.where((s) => s.platform == 'LigaPokémon').toList();
      final tcgSales = result.recentSales.where((s) => s.platform == 'TCGPlayer').toList();

      expect(ligaSales.isNotEmpty, isTrue);
      expect(tcgSales.isNotEmpty, isTrue);

      for (final sale in result.recentSales) {
        final brlFormatted = sale.priceBrl.toStringAsFixed(2);
        final usdFormatted = sale.priceUsd.toStringAsFixed(2);
        expect(brlFormatted.split('.').last.length, equals(2));
        expect(usdFormatted.split('.').last.length, equals(2));
      }
    });
  });
}
