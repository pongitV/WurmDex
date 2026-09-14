import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../services/radar_folder_service.dart';

/// Full-screen dialog to manage (create / rename / delete) LigaRadar folders (DRY).
class RadarManageFoldersDialog extends StatefulWidget {
  final AppDatabase db;
  final List<LigaPriceAlert> allAlerts;
  final AppStrings strings;

  const RadarManageFoldersDialog({
    super.key,
    required this.db,
    required this.allAlerts,
    required this.strings,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase db,
    required List<LigaPriceAlert> allAlerts,
    required AppStrings strings,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => RadarManageFoldersDialog(
        db: db,
        allAlerts: allAlerts,
        strings: strings,
      ),
    );
  }

  @override
  State<RadarManageFoldersDialog> createState() =>
      _RadarManageFoldersDialogState();
}

class _RadarManageFoldersDialogState extends State<RadarManageFoldersDialog> {
  late List<String> _folders;

  @override
  void initState() {
    super.initState();
    _refreshFolders();
  }

  void _refreshFolders() {
    _folders = RadarFolderService.getAllFolders(alerts: widget.allAlerts)
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

    final success = RadarFolderService.addFolder(newName);
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
        title: Text(strings.renameFolderTitle),
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

    final success = await RadarFolderService.renameFolder(
      db: widget.db,
      oldName: oldName,
      newName: newName,
    );

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
          content: Text(strings.folderRenamedSuccess),
        ),
      );
    }
  }

  Future<void> _deleteFolder(String folderName) async {
    final strings = widget.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteWishlistFolderTitle),
        content: Text(strings.confirmDeleteRadarFolderMsg(folderName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.btnDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await RadarFolderService.deleteFolder(
      db: widget.db,
      folderName: folderName,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.folderDeletedSuccess),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_copy_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.manageFoldersTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(strings.wishlistNewFolder),
                    onPressed: _createFolder,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _folders.isEmpty
                    ? Center(
                        child: Text(
                          strings.noCustomFoldersYet,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _folders.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final folder = _folders[index];
                          final count = widget.allAlerts
                              .where((a) => a.folderName == folder)
                              .length;

                          return ListTile(
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(folder),
                            subtitle: Text(
                              strings.folderItemsCount(count),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  tooltip: strings.tooltipRename,
                                  onPressed: () => _renameFolder(folder),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  tooltip: strings.btnDelete,
                                  onPressed: () => _deleteFolder(folder),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(strings.btnClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
