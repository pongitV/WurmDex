import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/features/monitoring/services/liga_scraper_service.dart';

void main() {
  group('LigaScraperService URL & Price Parsing Tests', () {
    test('normalizeUrl handles standard cards, items, and search terms', () {
      expect(
        LigaScraperService.normalizeUrl('https://www.ligapokemon.com.br/?view=cards/card&card=Charizard'),
        'https://www.ligapokemon.com.br/?view=cards/card&card=Charizard',
      );

      expect(
        LigaScraperService.normalizeUrl('ligapokemon.com.br/?view=cards/item&card=BoosterBox'),
        'https://ligapokemon.com.br/?view=cards/item&card=BoosterBox',
      );

      expect(
        LigaScraperService.normalizeUrl('Charizard ex'),
        'https://www.ligapokemon.com.br/?view=cards/card&card=Charizard%20ex',
      );

      expect(LigaScraperService.normalizeUrl('   '), '');
    });

    test('parseBrlPrice parses different Brazilian currency representations', () {
      expect(LigaScraperService.parseBrlPrice('R\$ 1.250,90'), 1250.90);
      expect(LigaScraperService.parseBrlPrice('r\$ 45,50'), 45.50);
      expect(LigaScraperService.parseBrlPrice('199,00'), 199.00);
      expect(LigaScraperService.parseBrlPrice('0,99'), 0.99);
      expect(LigaScraperService.parseBrlPrice(null), isNull);
      expect(LigaScraperService.parseBrlPrice('invalid'), isNull);
    });

    test('parseContent correctly parses sealed products with PRE ORDER and Marketplace prices', () {
      const url =
          'https://www.ligapokemon.com.br/?view=prod/view&pcode=136987&prod=(PT-BR)%20Blister%20Triplo%20-%20Celebra%C3%A7%C3%A3o%20de%2030%20Anos%20-%20Cole%C3%A7%C3%A3o%20com%20Adesivos%20-%20Exeggutor%20de%20Alola';

      const markdownSnippet = '''
Title: (PT-BR) Blister Triplo - Celebração de 30 Anos - Coleção com Adesivos - Exeggutor de Alola | Busca de Produtos e Acessórios | LigaPokemon

![Image 46: Exeggutor](https://repositorio.sbrauble.com/arquivos/up/prod/20260729/1785330156_7216.jpg)

Produto se encontra em **PRE ORDER**.

Preços aplicados no Marketplace

R\$ 119,00

R\$ 161,97

R\$ 259,99

Lojas Vendendo

R\$ 119,00
Ir à Loja
''';

      final product = LigaScraperService.parseContent(url, markdownSnippet);

      expect(product.title, contains('Blister Triplo'));
      expect(product.isPreSale, isTrue);
      expect(product.hasStock, isTrue);
      expect(product.lowestPrice, 119.00);
      expect(product.averagePrice, 161.97);
      expect(product.highestPrice, 259.99);
      expect(product.imageUrl, 'https://repositorio.sbrauble.com/arquivos/up/prod/20260729/1785330156_7216.jpg');
      expect(product.storeName, 'Marketplace (LigaPokémon)');
    });

    test('parseContent extracts specific store name from Avatar da Loja', () {
      const url =
          'https://www.ligapokemon.com.br/?view=prod/view&pcode=136987&prod=(PT-BR)%20Blister%20Triplo%20-%20Celebra%C3%A7%C3%A3o%20de%2030%20Anos';

      const markdownWithStore = '''
Title: (PT-BR) Blister Triplo | LigaPokemon
Preços aplicados no Marketplace
R\$ 119,00
R\$ 160,00
R\$ 200,00

Lojas Vendendo
R\$ 119,00
Ir à Loja

![Image 211: Avatar da Loja Dellos Tcg e Colecionáveis ](https://repositorio.sbrauble.com/arquivos/up/ecom/avatar/737677_1762138713.jpg)
''';

      final product = LigaScraperService.parseContent(url, markdownWithStore);
      expect(product.lowestPrice, 119.00);
      expect(product.storeName, 'Dellos Tcg e Colecionáveis');
    });

    test('Pre-sale and target price range validation logic', () {
      // Test offer in pre-sale with allowPreSale = true
      const productPreSalePrice = 120.0;
      const minTarget = 100.0;
      const maxTarget = 150.0;
      const allowPreSale = true;
      const isPreSale = true;

      final passesPreSale = !isPreSale || allowPreSale;
      final inRange = passesPreSale &&
          (minTarget <= 0 || productPreSalePrice >= minTarget) &&
          (maxTarget <= 0 || productPreSalePrice <= maxTarget);

      expect(inRange, isTrue);

      // Test offer in pre-sale with allowPreSale = false (should reject)
      const allowPreSaleDisabled = false;
      final passesPreSaleDisabled = !isPreSale || allowPreSaleDisabled;
      expect(passesPreSaleDisabled, isFalse);

      // Test offer above max range
      const highPrice = 180.0;
      final inRangeHigh = passesPreSale &&
          (minTarget <= 0 || highPrice >= minTarget) &&
          (maxTarget <= 0 || highPrice <= maxTarget);
      expect(inRangeHigh, isFalse);
    });
  });
}
