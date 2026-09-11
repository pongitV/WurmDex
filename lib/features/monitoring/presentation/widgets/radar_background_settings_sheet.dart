import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../services/liga_radar_background_service.dart';

/// Bottom sheet for configuring the Liga Radar background monitoring:
/// enables/disables periodic price checks and defines the check interval.
class RadarBackgroundSettingsSheet extends ConsumerStatefulWidget {
  const RadarBackgroundSettingsSheet({super.key});

  @override
  ConsumerState<RadarBackgroundSettingsSheet> createState() => _RadarBackgroundSettingsSheetState();
}

class _RadarBackgroundSettingsSheetState extends ConsumerState<RadarBackgroundSettingsSheet> {
  bool _enabled = false;
  int _intervalMinutes = 60;
  final TextEditingController _intervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _enabled = AppPreferencesService.isBackgroundLigaMonitoringEnabled();
    _intervalMinutes = AppPreferencesService.getLigaMonitoringIntervalMinutes();
    _intervalController.text = _intervalMinutes.toString();
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  void _setEnabled(bool value) {
    setState(() => _enabled = value);
    AppPreferencesService.setBackgroundLigaMonitoringEnabled(value);
    ref.read(ligaRadarBackgroundProvider).configure();
    if (value) {
      // Fire one immediate check so the user sees the feature working.
      ref.read(ligaRadarBackgroundProvider).checkNow();
    }
  }

  void _setInterval(int minutes) {
    setState(() => _intervalMinutes = minutes);
    AppPreferencesService.setLigaMonitoringIntervalMinutes(minutes);
    ref.read(ligaRadarBackgroundProvider).configure();
  }

  void _onIntervalChanged(String value) {
    final minutes = int.tryParse(value);
    if (minutes != null && minutes >= 5) {
      _setInterval(minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = getStrings(ref.watch(languageProvider));
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.radar, size: 22, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.radarBackgroundSettings,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: strings.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: SwitchListTile(
                value: _enabled,
                onChanged: _setEnabled,
                activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
                activeThumbColor: colorScheme.primary,
                title: Text(
                  strings.radarBackgroundEnabledLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(strings.radarBackgroundEnabledDesc),
              ),
            ),
            if (_enabled) ...[
              const SizedBox(height: 20),
              Text(
                strings.radarBackgroundIntervalLabel,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                strings.radarBackgroundIntervalDesc,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onIntervalChanged,
                decoration: InputDecoration(
                  labelText: strings.radarBackgroundIntervalLabel,
                  prefixIcon: const Icon(Icons.schedule, size: 20),
                  suffixText: 'min',
                  helperText: strings.radarBackgroundIntervalTypeHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      strings.radarBackgroundNote,
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}