import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/features/catalog/services/pokemon_catalog_service.dart';

void main() {
  test('Search Charizard returns strictly matching Charizard cards', () async {
    final res = await PokemonCatalogService.searchCards(query: 'Charizard');
    expect(res, isNotEmpty);
    for (final c in res) {
      expect(c.name.toLowerCase().contains('charizard'), isTrue);
    }
  });

  test('Search Pikachu returns strictly matching Pikachu cards', () async {
    final res = await PokemonCatalogService.searchCards(query: 'Pikachu');
    expect(res, isNotEmpty);
    for (final c in res) {
      expect(c.name.toLowerCase().contains('pikachu'), isTrue);
    }
  });

  test('Search Mew returns strictly matching Mew cards', () async {
    final res = await PokemonCatalogService.searchCards(query: 'Mew');
    expect(res, isNotEmpty);
    for (final c in res) {
      expect(c.name.toLowerCase().contains('mew'), isTrue);
    }
  });
}
