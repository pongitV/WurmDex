import 'package:flutter/material.dart';

/// Universal Empty and Error state widget for WurmDex (DRY).
///
/// Provides a visually rich, consistent layout for screens or lists with no content,
/// failed searches, or offline states, featuring a themed icon halo, typography hierarchy,
/// and an optional call-to-action button.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final String? buttonLabel;
  final IconData? buttonIcon;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.buttonLabel,
    this.buttonIcon,
    this.onAction,
    this.iconSize = 48.0,
    this.iconColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.primary.withValues(alpha: 0.7);

    Widget? effectiveAction = action;
    if (effectiveAction == null && buttonLabel != null && onAction != null) {
      if (buttonIcon != null) {
        effectiveAction = FilledButton.icon(
          onPressed: onAction,
          icon: Icon(buttonIcon, size: 18),
          label: Text(buttonLabel!),
        );
      } else {
        effectiveAction = FilledButton(
          onPressed: onAction,
          child: Text(buttonLabel!),
        );
      }
    }

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Soft halo container around the icon
            Container(
              width: iconSize * 1.8,
              height: iconSize * 1.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: effectiveIconColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (effectiveAction != null) ...[
              const SizedBox(height: 24),
              effectiveAction,
            ],
          ],
        ),
      ),
    );
  }
}
