import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Item definition for generic sorting options.
class SortOptionItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SortOptionItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Generic, reusable Sort Button / Dropdown (DRY).
///
/// Supports both:
/// - Compact icon mode (`isCompact: true`): Ideal for crowded AppBars (renders an icon button with `Icons.sort` or custom icon).
/// - Chip/Badge mode (`isCompact: false`): Shows the current selected option icon + text + dropdown arrow.
class AppSortButton<T> extends StatelessWidget {
  final T currentOption;
  final List<SortOptionItem<T>> options;
  final ValueChanged<T> onSelected;
  final String? tooltip;
  final bool isCompact;
  final IconData? customIcon;

  const AppSortButton({
    super.key,
    required this.currentOption,
    required this.options,
    required this.onSelected,
    this.tooltip,
    this.isCompact = false,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    SortOptionItem<T>? currentItem;
    for (final opt in options) {
      if (opt.value == currentOption) {
        currentItem = opt;
        break;
      }
    }

    final activeIcon = customIcon ?? (isCompact ? Icons.sort : (currentItem?.icon ?? Icons.sort));
    final activeLabel = currentItem?.label ?? '';

    return PopupMenuButton<T>(
      initialValue: currentOption,
      tooltip: tooltip,
      onSelected: (val) {
        HapticFeedback.selectionClick();
        onSelected(val);
      },
      icon: isCompact
          ? Icon(activeIcon)
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    activeIcon,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) {
        return options.map((option) {
          final isSelected = option.value == currentOption;
          return PopupMenuItem<T>(
            value: option.value,
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 18,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    size: 18,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
