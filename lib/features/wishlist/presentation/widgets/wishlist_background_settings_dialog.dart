import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/app_preferences_service.dart';

class WishlistBackgroundSettingsDialog extends StatefulWidget {
  final bool initialEnabled;
  final ValueChanged<bool> onToggle;
  final AppStrings strings;

  const WishlistBackgroundSettingsDialog({
    super.key,
    required this.initialEnabled,
    required this.onToggle,
    required this.strings,
  });

  static Future<void> show({
    required BuildContext context,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required AppStrings strings,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => WishlistBackgroundSettingsDialog(
        initialEnabled: enabled,
        onToggle: onToggle,
        strings: strings,
      ),
    );
  }

  @override
  State<WishlistBackgroundSettingsDialog> createState() =>
      _WishlistBackgroundSettingsDialogState();
}

class _WishlistBackgroundSettingsDialogState
    extends State<WishlistBackgroundSettingsDialog> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strings.radarBackgroundSettings),
      content: CheckboxListTile(
        value: _enabled,
        title: Text(widget.strings.radarBackgroundEnabledLabel),
        onChanged: (value) {
          final enabled = value ?? false;
          setState(() => _enabled = enabled);
          AppPreferencesService.setBackgroundWishlistScanEnabled(enabled);
          widget.onToggle(enabled);
        },
        controlAffinity: ListTileControlAffinity.trailing,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.strings.close),
        ),
      ],
    );
  }
}
