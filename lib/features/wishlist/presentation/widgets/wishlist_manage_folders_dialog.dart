import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../services/wishlist_folder_service.dart';

/// Full-screen dialog to manage (create / rename / delete) wishlist folders.
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
    _refreshFolders();
  }

  void _refreshFolders() {
    _folders = WishlistFolderService.getAllFolders(items: widget.allItems)
        .where((f) => f != 'Geral')
        .toList();
  }

  Future<void> _createFolder() async {
    final strings = widget.strings;
    final controller = TextEditingController();

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.dlgCreateFolderTitle),
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

    if (newName == null || !mounted) return;

    final success = WishlistFolderService.addFolder(newName);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.folderAlreadyExistsOrInvalid),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _refreshFolders();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.folderCreatedSuccess),
        ),
      );
    }
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

    await WishlistFolderService.renameFolder(
      db: widget.db,
      oldName: oldName,
      newName: newName,
    );

    if (mounted) {
      setState(() {
        _refreshFolders();
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

    await WishlistFolderService.deleteFolder(
      db: widget.db,
      folderName: folderName,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.wishlistFolderDeleted)),
      );
    }
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
          Expanded(child: Text(strings.manageWishlistFolders)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _folders.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.noWishlistCustomFoldersSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: _folders.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final folder = _folders[index];
                  final count = widget.allItems
                      .where(
                        (i) =>
                            (i.folderName.isNotEmpty
                                ? i.folderName
                                : 'Geral') ==
                            folder,
                      )
                      .length;
                  return ListTile(
                    leading: const Icon(Icons.folder_outlined, size: 20),
                    title: Text(folder),
                    subtitle: Text(strings.cardsCountLabel(count)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rename
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: strings.editWishlistFolder,
                          onPressed: () => _renameFolder(folder),
                        ),
                        // Delete
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          tooltip: strings.confirmDeleteWishlistFolderTitle,
                          onPressed: () => _deleteFolder(folder),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: Text(strings.newFolderAction),
          onPressed: _createFolder,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.close),
        ),
      ],
    );
  }
}
