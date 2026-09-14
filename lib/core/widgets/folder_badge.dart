import 'package:flutter/material.dart';

/// Reusable, standardized badge displaying the folder a card belongs to (DRY).
///
/// Shares the exact geometry, padding, border-radius, and font sizing of
/// [ConditionBadge] and [LanguageFlagBadge] for a perfectly balanced visual layout.
class FolderBadge extends StatelessWidget {
  final String folderName;
  final bool compact;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;

  const FolderBadge({
    super.key,
    required this.folderName,
    this.compact = false,
    this.color,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4.5 : 7.0,
        vertical: compact ? 1.0 : 2.5,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 4.0 : 6.0),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.55),
          width: compact ? 0.7 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.folder_outlined,
            size: compact ? 9.5 : 12.0,
            color: effectiveColor,
          ),
          SizedBox(width: compact ? 3 : 4),
          Flexible(
            child: Text(
              folderName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 8.5 : 10.5,
                fontWeight: FontWeight.w700,
                color: effectiveColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 4.0 : 6.0),
        child: Tooltip(
          message: folderName,
          child: badge,
        ),
      );
    }

    return Tooltip(
      message: folderName,
      child: badge,
    );
  }
}
