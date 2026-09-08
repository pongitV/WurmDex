class PokedexEntry {
  final int id;
  final String name;
  final List<String> types;
  final int generation;

  const PokedexEntry({
    required this.id,
    required this.name,
    required this.types,
    required this.generation,
  });

  String get formattedNumber => '#${id.toString().padLeft(3, '0')}';

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
}
