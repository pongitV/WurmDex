import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/app_preferences_service.dart';
import 'liga_scraper_service.dart';

/// Periodic in-app "background" checker for LigaPokémon price alerts.
///
/// While the app process is running (foreground, minimized or otherwise in the
/// background on Windows / Android) a [Timer] checks the price of every
/// activated monitored product at the configured interval and fires local
/// notifications when a product reaches the target price range.
class LigaRadarBackgroundService {
  LigaRadarBackgroundService(this._ref);

  final Ref _ref;
  Timer? _timer;
  bool _checking = false;

  bool get isRunning => _timer != null;

  /// (Re)applies the stored preferences: cancels any existing timer and starts
  /// a new one when background monitoring is enabled.
  void configure() {
    _timer?.cancel();
    _timer = null;

    if (!AppPreferencesService.isBackgroundLigaMonitoringEnabled()) return;

    final intervalMinutes = AppPreferencesService.getLigaMonitoringIntervalMinutes();
    final safeInterval = intervalMinutes < 5 ? 5 : intervalMinutes;
    _timer = Timer.periodic(
      Duration(minutes: safeInterval),
      (_) => _runCheck(),
    );
    debugPrint('Liga Radar background monitoring started (every $safeInterval min).');
  }

  /// Cancels any scheduled periodic check. Preferences stay untouched.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Runs one verification cycle immediately (non-blocking) when configured.
  void checkNow() {
    _runCheck();
  }

  Future<void> _runCheck() async {
    if (_checking) return;
    _checking = true;
    try {
      final db = _ref.read(databaseProvider);
      // checkAllActiveAlerts only touches products with isActive == true.
      await LigaScraperService.checkAllActiveAlerts(db: db, notify: true);
    } catch (e) {
      debugPrint('Liga Radar background check error: $e');
    } finally {
      _checking = false;
    }
  }
}

/// Global provider used to start/refresh the background checker. It is watched
/// at app startup so the timer lives for the whole application lifetime.
final ligaRadarBackgroundProvider =
    Provider<LigaRadarBackgroundService>((ref) {
  final service = LigaRadarBackgroundService(ref);
  service.configure();
  ref.onDispose(service.stop);
  return service;
});