import 'package:flutter/material.dart';
import '../localization/app_strings.dart';

/// Universal Filter Button for WurmDex (DRY).
///
/// Features:
/// - Consistent `Icons.tune` icon
/// - Reactive badge showing the number of active filters
/// - Standard tooltip and tap response
class AppFilterButton extends StatelessWidget {
  final int activeFilterCount;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isFilledTonal;

  const AppFilterButton({
    super.key,
    required this.activeFilterCount,
    required this.onPressed,
    this.tooltip,
    this.isFilledTonal = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = activeFilterCount > 0;
    final iconWidget = Badge(
      isLabelVisible: hasFilters,
      label: Text('$activeFilterCount'),
      child: const Icon(Icons.tune, size: 20),
    );

    if (isFilledTonal) {
      return IconButton.filledTonal(
        icon: iconWidget,
        tooltip: tooltip,
        onPressed: onPressed,
      );
    }

    return IconButton(
      icon: iconWidget,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

/// Generic, standard filter modal window that fills most of the screen
/// without covering it completely (NOT a bottom sheet).
class AppFilterModalDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final bool hasActiveFilters;
  final AppStrings strings;

  const AppFilterModalDialog({
    super.key,
    required this.title,
    required this.children,
    required this.onApply,
    required this.onClear,
    required this.hasActiveFilters,
    required this.strings,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required VoidCallback onApply,
    required VoidCallback onClear,
    required bool hasActiveFilters,
    required AppStrings strings,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AppFilterModalDialog(
        title: title,
        onApply: onApply,
        onClear: onClear,
        hasActiveFilters: hasActiveFilters,
        strings: strings,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: onClear,
                      child: Text(
                        strings.btnClearFilters,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.cancel),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(strings.btnApplyFilters),
                    onPressed: () {
                      Navigator.pop(context);
                      onApply();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
