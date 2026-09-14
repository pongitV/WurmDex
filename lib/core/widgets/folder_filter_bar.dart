import 'package:flutter/material.dart';

/// Compact, bordered folder filter used by both the Liga Radar and Wishlist
/// screens (radar style). No floating label on the top border.
///
/// `selected == null` means "all folders". When a specific folder is selected
/// and [onEdit] is provided, a pencil action is shown next to the dropdown.
class FolderFilterBar extends StatelessWidget {
  final String? selected;
  final List<String> folders;
  final String hint;
  final String allLabel;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onEdit;

  const FolderFilterBar({
    super.key,
    required this.selected,
    required this.folders,
    required this.hint,
    required this.allLabel,
    required this.onChanged,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEdit = selected != null && onEdit != null;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selected,
                hint: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hint,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(allLabel),
                  ),
                  ...folders.map(
                    (folder) => DropdownMenuItem<String?>(
                      value: folder,
                      child: Text(folder),
                    ),
                  ),
                ],
                onChanged: onChanged,
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
              ),
            ),
          ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: '$hint: $selected!',
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}