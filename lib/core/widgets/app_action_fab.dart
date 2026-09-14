import 'package:flutter/material.dart';

class AppFabAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const AppFabAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Universal screen Floating Action Button hub.
///
/// Serves as the action button for each screen, exposing screen-specific
/// actions either directly or through a quick-action modal.
/// Always rendered as a round button with a three-dots icon.
class AppActionFab extends StatelessWidget {
  final String? sheetTitle;
  final String tooltip;
  final VoidCallback? onPressed;
  final List<AppFabAction>? actions;

  const AppActionFab({
    super.key,
    this.sheetTitle,
    required this.tooltip,
    this.onPressed,
    this.actions,
  });

  void _showActionModal(BuildContext context) {
    if (actions == null || actions!.isEmpty) return;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sheetTitle ?? tooltip,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...actions!.map((action) {
                    final itemColor = action.isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            action.onTap();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: itemColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    action.icon,
                                    size: 20,
                                    color: itemColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        action.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: action.isDestructive
                                              ? theme.colorScheme.error
                                              : null,
                                        ),
                                      ),
                                      if (action.subtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          action.subtitle!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: theme.hintColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (actions != null && actions!.length > 1) {
          _showActionModal(context);
        } else if (actions != null && actions!.length == 1) {
          actions!.first.onTap();
        } else if (onPressed != null) {
          onPressed!();
        }
      },
      tooltip: tooltip,
      shape: const CircleBorder(),
      child: const Icon(Icons.more_horiz),
    );
  }
}
