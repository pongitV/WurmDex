import '../../catalog/models/pokemon_card_item.dart';

enum BoosterFormat {
  usa10,
  brazil6,
}

class BoosterCardPull {
  final PokemonCardItem card;
  final bool isReverseHolo;
  final bool isChase;
  final String slotType; // 'common', 'uncommon', 'reverse', 'rare', 'chase'

  const BoosterCardPull({
    required this.card,
    this.isReverseHolo = false,
    this.isChase = false,
    required this.slotType,
  });
}

class BoosterPackResult {
  final String setId;
  final String setName;
  final BoosterFormat format;
  final List<BoosterCardPull> cards;
  final double totalMarketUsd;
  final bool isGodPack;
  final String? godPackTheme;

  const BoosterPackResult({
    required this.setId,
    required this.setName,
    required this.format,
    required this.cards,
    required this.totalMarketUsd,
    this.isGodPack = false,
    this.godPackTheme,
  });
}
