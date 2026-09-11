import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_preferences_service.dart';

/// Global card display mode shared across screens with item grids.
enum CardViewMode { grid, list }

class CardViewModeNotifier extends Notifier<CardViewMode> {
  @override
  CardViewMode build() {
    final saved = AppPreferencesService.getSavedViewMode();
    if (saved == CardViewMode.grid.name) return CardViewMode.grid;
    if (saved == CardViewMode.list.name) return CardViewMode.list;
    return CardViewMode.list; // Default: list
  }

  void setMode(CardViewMode mode) {
    state = mode;
    AppPreferencesService.saveViewMode(mode.name);
  }

  void toggle() =>
      setMode(state == CardViewMode.grid ? CardViewMode.list : CardViewMode.grid);
}

final cardViewModeProvider =
    NotifierProvider<CardViewModeNotifier, CardViewMode>(CardViewModeNotifier.new);