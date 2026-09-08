import '../../../../core/database/app_database.dart';
import '../../catalog/models/pokemon_card_item.dart';
import '../models/tcg_set_item.dart';

class SetCompletionHelper {
  /// Checks whether a user card belongs to the given set
  static bool matchesSet(UserCard userCard, TcgSetItem set) {
    final setPrefix = '${set.id.toLowerCase()}-';
    if (userCard.cardApiId.toLowerCase().startsWith(setPrefix)) {
      return true;
    }
    if (userCard.setName.isNotEmpty &&
        userCard.setName.toLowerCase() == set.name.toLowerCase()) {
      return true;
    }
    return false;
  }

  /// Calculates the number of distinct cards the user owns from this set
  static int getOwnedDistinctCount(List<UserCard> userCards, TcgSetItem set) {
    final setCardKeys = <String>{};
    for (final card in userCards) {
      if (matchesSet(card, set)) {
        final key = card.number.isNotEmpty ? card.number.trim().toLowerCase() : card.cardApiId;
        setCardKeys.add(key);
      }
    }
    return setCardKeys.length;
  }

  /// Calculates the completion ratio (0.0 to 1.0)
  static double getCompletionRatio(int ownedCount, TcgSetItem set) {
    final total = set.totalCards > 0 ? set.totalCards : set.officialCards;
    if (total <= 0) return 0.0;
    return (ownedCount / total).clamp(0.0, 1.0);
  }

  /// Checks whether a specific card from the set gallery is already owned by the user
  static bool isCardOwned(List<UserCard> userCards, PokemonCardItem card) {
    final cardIdLower = card.id.toLowerCase();
    final cardNumLower = card.number.trim().toLowerCase();
    final setNameLower = card.setName.trim().toLowerCase();

    return userCards.any((uc) {
      if (uc.cardApiId.toLowerCase() == cardIdLower) return true;
      if (uc.number.trim().toLowerCase() == cardNumLower &&
          uc.setName.trim().toLowerCase() == setNameLower) {
        return true;
      }
      return false;
    });
  }
}
