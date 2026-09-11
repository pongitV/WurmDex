import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';

/// Full-screen dialog to manage (rename / delete) wishlist folders.
///
/// Derives the folder list from the current wishlist items (since folders
/// are stored inline, not as separate table rows).
class WishlistManageFoldersDialog extends StatefulWidget {
  final AppDatabase db;
  final List<WishlistItem> allItems;
  final AppStrings strings;

  const WishlistManageFoldersDialog({
    super.key,
    required this.db,
    required this.allItems,
    required this.strings,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase db,
    required List<WishlistItem> allItems,
    required AppStrings strings,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => WishlistManageFoldersDialog(
        db: db,
        allItems: allItems,
        strings: strings,
      ),
    );
  }

  @override
  State<WishlistManageFoldersDialog> createState() =>
      _WishlistManageFoldersDialogState();
}

class _WishlistManageFoldersDialogState
    extends State<WishlistManageFoldersDialog> {
  late List<String> _folders;

  @override
  void initState() {
    super.initState();
    _folders = _extractFolders();
  }

  List<String> _extractFolders() {
    final folders = <String>{};
    for (final item in widget.allItems) {
      final f = item.folderName.isNotEmpty ? item.folderName : 'Geral';
      if (f != 'Geral') folders.add(f);
    }
    return folders.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.folder_copy_outlined, size: 22),
          const SizedBox(width: 8),
          Text(strings.manageWishlistFolders),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _folders.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_off_outlined,
                      size: 48,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    strings.isEn
                        ? 'No custom folders yet.\nCards are in the General folder.'
                        : 'Nenhuma pasta personalizada.\nAs cartas estão na pasta Geral.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _folders.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final folder = _folders[index];
                  final count = widget.allItems
                      .where((i) =>
                          (i.folderName.isNotEmpty
                              ? i.folderName
                              : 'Geral') ==
                          folder)
                      .length;
                  return ListTile(
                    leading: const Icon(Icons.folder_outlined, size: 20),
                    title: Text(folder),
                    subtitle:
                        Text(strings.cardsCountLabel(count)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rename
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: strings.editWishlistFolder,
                          onPressed: () =>
                              _renameFolder(folder),
                        ),
                        // Delete
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18,
                              color: theme.colorScheme.error),
                          tooltip: strings.confirmDeleteWishlistFolderTitle,
                          onPressed: () =>
                              _deleteFolder(folder),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.close),
        ),
      ],
    );
  }

  Future<void> _renameFolder(String oldName) async {
    final strings = widget.strings;
    final controller = TextEditingController(text: oldName);

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.editWishlistFolder),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: strings.wishlistNewFolderName,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx, text.isNotEmpty ? text : null);
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );

    if (newName == null || newName == oldName || !mounted) return;

    // Rename all wishlist items in this folder
    final itemsInFolder =
        widget.allItems.where((i) => i.folderName == oldName);
    for (final item in itemsInFolder) {
      await (widget.db.update(widget.db.wishlistItems)
            ..where((t) => t.id.equals(item.id)))
          .write(
        WishlistItemsCompanion(folderName: drift.Value(newName)),
      );
    }

    if (mounted) {
      setState(() {
        final idx = _folders.indexOf(oldName);
        if (idx >= 0) _folders[idx] = newName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.wishlistFolderRenamed)),
      );
    }
  }

  Future<void> _deleteFolder(String folderName) async {
    final strings = widget.strings;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteWishlistFolderTitle),
        content: Text(strings.confirmDeleteWishlistFolderMsg(folderName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.btnDelete),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Move all items in this folder to 'Geral'
    final itemsInFolder =
        widget.allItems.where((i) => i.folderName == folderName);
    for (final item in itemsInFolder) {
      await (widget.db.update(widget.db.wishlistItems)
            ..where((t) => t.id.equals(item.id)))
          .write(
        const WishlistItemsCompanion(folderName: drift.Value('Geral')),
      );
    }

    if (mounted) {
      setState(() => _folders.remove(folderName));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.wishlistFolderDeleted)),
      );
    }
  }
}
