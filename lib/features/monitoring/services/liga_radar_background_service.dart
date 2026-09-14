import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/app_preferences_service.dart';
import '../../../core/services/notification_service.dart';
import 'liga_scraper_service.dart';

const String ligaRadarTaskName = 'com.wurmdex.app.liga_radar_check_task';
const String ligaRadarUniqueWorkName = 'ligaRadarPeriodicCheck';

/// Headless entry point for Workmanager when the app process is closed on Android.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await NotificationService.initialize();
      final db = AppDatabase();
      await LigaScraperService.checkAllActiveAlerts(db: db, notify: true);
      await db.close();
    } catch (e) {
      debugPrint('Workmanager background check error: $e');
    }
    return Future.value(true);
  });
}

/// Periodic checker for LigaPokémon price alerts.
///
/// While the app process is running (foreground, minimized or otherwise in the
/// background on Windows / Android) a [Timer] checks the price of every
/// activated monitored product at the configured interval and fires local
/// notifications when a product reaches the target price range.
///
/// When the app is closed on Android, Workmanager periodically triggers
/// [callbackDispatcher] to ensure alerts are verified even without user interaction.
class LigaRadarBackgroundService {
  LigaRadarBackgroundService(this._ref);

  final Ref _ref;
  Timer? _timer;
  bool _checking = false;

  bool get isRunning => _timer != null;

  /// Initializes the WorkManager plugin on mobile platforms.
  static Future<void> initializeWorkManager() async {
    if (!kIsWeb &&
        !Platform.environment.containsKey('FLUTTER_TEST') &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        await Workmanager().initialize(callbackDispatcher);
        debugPrint('Workmanager initialized successfully.');
      } catch (e) {
        debugPrint('Workmanager initialization error: $e');
      }
    }
  }

  /// (Re)applies the stored preferences: cancels any existing timer and starts
  /// a new one when background monitoring is enabled. Also registers or cancels
  /// the native Workmanager periodic task.
  void configure() {
    _timer?.cancel();
    _timer = null;

    final enabled = AppPreferencesService.isBackgroundLigaMonitoringEnabled();
    final isMobile = !kIsWeb &&
        !Platform.environment.containsKey('FLUTTER_TEST') &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (!enabled) {
      if (isMobile) {
        try {
          Workmanager().cancelByUniqueName(ligaRadarUniqueWorkName).catchError((e) {
            debugPrint('Error cancelling WorkManager task: $e');
          });
          debugPrint('Liga Radar WorkManager task cancelled.');
        } catch (e) {
          debugPrint('Error cancelling WorkManager task: $e');
        }
      }
      return;
    }

    final intervalMinutes = AppPreferencesService.getLigaMonitoringIntervalMinutes();
    final safeInterval = intervalMinutes < 5 ? 5 : intervalMinutes;
    _timer = Timer.periodic(
      Duration(minutes: safeInterval),
      (_) => _runCheck(),
    );
    debugPrint('Liga Radar background monitoring started (every $safeInterval min).');

    // Register WorkManager for closed-app execution on Android / iOS
    if (isMobile) {
      try {
        // Android WorkManager requires a minimum interval of 15 minutes.
        final workmanagerMinutes = safeInterval < 15 ? 15 : safeInterval;
        Workmanager().registerPeriodicTask(
          ligaRadarUniqueWorkName,
          ligaRadarTaskName,
          frequency: Duration(minutes: workmanagerMinutes),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
        ).catchError((e) {
          debugPrint('Error registering WorkManager periodic task: $e');
        });
        debugPrint('Liga Radar WorkManager registered (every $workmanagerMinutes min).');
      } catch (e) {
        debugPrint('Error registering WorkManager periodic task: $e');
      }
    }
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