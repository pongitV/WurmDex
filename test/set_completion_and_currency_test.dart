import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/sets/models/tcg_set_item.dart';
import 'package:wurmdex/features/sets/services/set_completion_helper.dart';

void main() {
  group('Currency Provider & Formatter Tests', () {
    test('currencyProvider toggles between USD and BRL and can set explicitly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(currencyProvider), AppCurrency.usd);

      container.read(currencyProvider.notifier).toggleCurrency();
      expect(container.read(currencyProvider), AppCurrency.brl);

      container.read(currencyProvider.notifier).toggleCurrency();
      expect(container.read(currencyProvider), AppCurrency.usd);

      container.read(currencyProvider.notifier).setCurrency(AppCurrency.brl);
      expect(container.read(currencyProvider), AppCurrency.brl);

      container.read(currencyProvider.notifier).setCurrency(AppCurrency.usd);
      expect(container.read(currencyProvider), AppCurrency.usd);
    });

    test('CurrencyFormatter.formatCardPrice in USD formats correctly with null/zero/valid values', () {
      expect(
        CurrencyFormatter.formatCardPrice(usdValue: null, currency: AppCurrency.usd),
        '\$ --',
      );
      expect(
        CurrencyFormatter.formatCardPrice(usdValue: 0.0, currency: AppCurrency.usd),
        '\$ --',
      );
      expect(
        CurrencyFormatter.formatCardPrice(usdValue: 12.5, currency: AppCurrency.usd),
        r'$12.50',
      );
      expect(
        CurrencyFormatter.formatCardPrice(usdValue: 1200.0, currency: AppCurrency.usd),
        r'$1,200.00',
      );
    });

    test('CurrencyFormatter.formatCardPrice in BRL converts with exchange rate', () {
      expect(
        CurrencyFormatter.formatCardPrice(
          usdValue: null,
          currency: AppCurrency.brl,
          exchangeRate: 5.5,
        ),
        'R\$ --',
      );
      expect(
        CurrencyFormatter.formatCardPrice(
          usdValue: 0.0,
          currency: AppCurrency.brl,
          exchangeRate: 5.5,
        ),
        'R\$ --',
      );
      // 10.0 * 5.5 = 55.00 (pt_BR currency uses non-breaking space after symbol)
      final brl55 = CurrencyFormatter.formatCardPrice(
        usdValue: 10.0,
        currency: AppCurrency.brl,
        exchangeRate: 5.5,
      );
      expect(brl55.startsWith('R\$'), isTrue);
      expect(brl55.contains('55,00'), isTrue);

      // default rate is 5.60: 2.0 * 5.60 = 11.20
      final brl11 = CurrencyFormatter.formatCardPrice(
        usdValue: 2.0,
        currency: AppCurrency.brl,
      );
      expect(brl11.startsWith('R\$'), isTrue);
      expect(brl11.contains('11,20'), isTrue);
    });
  });

  group('Set Completion Helper Tests', () {
    const testSet = TcgSetItem(
      id: 'sv08',
      name: 'Surging Sparks',
      totalCards: 252,
      officialCards: 191,
      year: 2024,
    );

    final mockUserCards = [
      UserCard(
        id: '1',
        cardApiId: 'sv08-1',
        name: 'Pikachu ex',
        number: '1',
        setName: 'Surging Sparks',
        rarity: 'Double Rare',
        imageUrl: 'https://example.com/1.png',
        condition: 'Near Mint',
        language: 'EN',
        finish: 'Regular',
        quantity: 2,
        purchasePriceBrl: 15.0,
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: '2',
        cardApiId: 'sv08-2',
        name: 'Latias ex',
        number: '2',
        setName: 'Surging Sparks',
        rarity: 'Double Rare',
        imageUrl: 'https://example.com/2.png',
        condition: 'Near Mint',
        language: 'EN',
        finish: 'Regular',
        quantity: 1,
        purchasePriceBrl: 10.0,
        createdAt: DateTime.now(),
      ),
      UserCard(
        id: '3',
        cardApiId: 'sv07-1',
        name: 'Stellar Crown Card',
        number: '1',
        setName: 'Stellar Crown',
        rarity: 'Common',
        imageUrl: 'https://example.com/3.png',
        condition: 'Near Mint',
        language: 'EN',
        finish: 'Regular',
        quantity: 1,
        purchasePriceBrl: 1.0,
        createdAt: DateTime.now(),
      ),
    ];

    test('matchesSet detects by set ID or set name matching', () {
      final cardWithId = mockUserCards[0]; // sv08-1, setName: Surging Sparks
      final cardOtherSet = mockUserCards[2]; // sv07-1, setName: Stellar Crown

      expect(SetCompletionHelper.matchesSet(cardWithId, testSet), isTrue);
      expect(SetCompletionHelper.matchesSet(cardOtherSet, testSet), isFalse);
    });

    test('getOwnedDistinctCount counts distinct cards matching set', () {
      final count = SetCompletionHelper.getOwnedDistinctCount(mockUserCards, testSet);
      expect(count, 2);
    });

    test('getCompletionRatio computes percentage correctly', () {
      final ratio = SetCompletionHelper.getCompletionRatio(2, testSet);
      // 2 / 252
      expect(ratio, closeTo(2 / 252, 0.0001));

      const emptySet = TcgSetItem(
        id: 'empty',
        name: 'Empty Set',
        totalCards: 0,
        officialCards: 0,
        year: 2024,
      );
      expect(SetCompletionHelper.getCompletionRatio(0, emptySet), 0.0);
    });

    test('isCardOwned matches catalog card to collection', () {
      const catalogCardOwned = PokemonCardItem(
        id: 'sv08-1',
        name: 'Pikachu ex',
        number: '1',
        setId: 'sv08',
        setName: 'Surging Sparks',
        rarity: 'Double Rare',
        imageUrlSmall: 'https://example.com/1.png',
        imageUrlLarge: 'https://example.com/1_large.png',
        types: ['Lightning'],
        supertype: 'Pokémon',
        artist: '5ban Graphics',
      );

      const catalogCardNotOwned = PokemonCardItem(
        id: 'sv08-99',
        name: 'Milotic ex',
        number: '99',
        setId: 'sv08',
        setName: 'Surging Sparks',
        rarity: 'Double Rare',
        imageUrlSmall: 'https://example.com/99.png',
        imageUrlLarge: 'https://example.com/99_large.png',
        types: ['Water'],
        supertype: 'Pokémon',
        artist: 'aky CG Works',
      );

      expect(SetCompletionHelper.isCardOwned(mockUserCards, catalogCardOwned), isTrue);
      expect(SetCompletionHelper.isCardOwned(mockUserCards, catalogCardNotOwned), isFalse);
    });
  });
}
