import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_preferences_service.dart';

class AutoclickerPausedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return AppPreferencesService.isAutoclickerPaused();
  }

  void setPaused(bool paused) {
    state = paused;
    AppPreferencesService.setAutoclickerPaused(paused);
  }

  void toggle() {
    setPaused(!state);
  }
}

final autoclickerPausedProvider =
    NotifierProvider<AutoclickerPausedNotifier, bool>(AutoclickerPausedNotifier.new);
