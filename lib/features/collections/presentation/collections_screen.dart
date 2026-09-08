import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/folder_icon_helper.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/quick_currency_toggle.dart';
import 'widgets/collection_dashboard_widget.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final foldersAsync = ref.watch(foldersStreamProvider);
    final allCardsAsync = ref.watch(userCardsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.collectionsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          const QuickCurrencyToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Global Portfolio Dashboard
          SliverToBoxAdapter(
            child: allCardsAsync.when(
              data: (cards) => CollectionDashboardWidget(cards: cards),
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.sectionFoldersAndBinders,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(strings.btnCreateFolderAction),
                    onPressed: () => _showCreateFolderDialog(context, ref, strings),
                  ),
                ],
              ),
            ),
          ),

          // Folders List
          foldersAsync.when(
            data: (folders) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Default General Collection Item
                    _buildGeneralCollectionCard(context, ref, strings),
                    const SizedBox(height: 10),

                    // Custom User Folders
                    ...folders.map((folder) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildFolderCard(context, ref, folder, strings),
                        )),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralCollectionCard(BuildContext context, WidgetRef ref, AppStrings strings) {
    final theme = Theme.of(context);
    final unorganizedCards = ref.watch(folderCardsProvider(null));

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.all_inbox, color: theme.colorScheme.primary),
        ),
        title: Text(strings.generalCollectionTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(strings.generalCollectionSubtitle),
        trailing: unorganizedCards.when(
          data: (cards) => Chip(
            label: Text(strings.cardsCount(cards.length)),
            backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
          ),
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
        onTap: () {
          AppNavigator.toFolder(context, folder: null);
        },
      ),
    );
  }

  Widget _buildFolderCard(BuildContext context, WidgetRef ref, Folder folder, AppStrings strings) {
    final theme = Theme.of(context);
    final folderCards = ref.watch(folderCardsProvider(folder.id));

    Color folderColor;
    try {
      folderColor = Color(int.parse(folder.colorTag.replaceAll('#', '0xFF')));
    } catch (_) {
      folderColor = AppColors.darkAccent;
    }

    final modeLabel = folder.displayMode == 'binder' ? strings.modeBinder : strings.modeGrid;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: folderColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            FolderIconHelper.getIcon(folder.iconName),
            color: folderColor,
          ),
        ),
        title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          folder.description.isNotEmpty ? folder.description : '${strings.modePrefix}$modeLabel',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            folderCards.when(
              data: (cards) => Chip(
                label: Text('${cards.length}'),
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.lossRed,
              tooltip: strings.tooltipDeleteFolder,
              onPressed: () => _confirmDeleteFolder(context, ref, folder, strings),
            ),
          ],
        ),
        onTap: () {
          AppNavigator.toFolder(context, folder: folder);
        },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String displayMode = 'grid';
    String colorTag = '#7C3AED';
    String iconKey = 'folder';

    final colors = [
      '#7C3AED',
      '#D92656',
      '#FACC15',
      '#10B981',
      '#3B82F6',
      '#EC4899',
      '#F59E0B',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final currentColor = Color(int.parse(colorTag.replaceAll('#', '0xFF')));

          return AlertDialog(
            title: Text(strings.dlgCreateFolderTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: strings.inputFolderName,
                      hintText: strings.inputFolderNameHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: strings.inputFolderDesc,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display Mode Choice
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: strings.inputInitialMode),
                    initialValue: displayMode,
                    items: [
                      DropdownMenuItem(
                        value: 'grid',
                        child: Text(strings.optGridMode),
                      ),
                      DropdownMenuItem(
                        value: 'binder',
                        child: Text(strings.optBinderMode),
                      ),
                    ],
                    onChanged: (val) => setState(() => displayMode = val!),
                  ),
                  const SizedBox(height: 16),
                  // Color Picker
                  Text(
                    strings.labelFolderColor,
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: colors.map((c) {
                      final isSelected = colorTag == c;
                      final col = Color(int.parse(c.replaceAll('#', '0xFF')));
                      return GestureDetector(
                        onTap: () => setState(() => colorTag = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: col,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Icon Picker
                  Text(
                    strings.labelFolderIcon,
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: FolderIconHelper.availableIcons.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final item = FolderIconHelper.availableIcons[i];
                        final isSelected = iconKey == item.key;
                        return Tooltip(
                          message: item.label,
                          child: InkWell(
                            onTap: () => setState(() => iconKey = item.key),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? currentColor.withValues(alpha: 0.25)
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? currentColor : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                size: 22,
                                color: isSelected ? currentColor : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.btnCancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final db = ref.read(databaseProvider);
                  await db.insertFolder(
                    FoldersCompanion(
                      id: drift.Value(const Uuid().v4()),
                      name: drift.Value(nameCtrl.text.trim()),
                      description: drift.Value(descCtrl.text.trim()),
                      colorTag: drift.Value(colorTag),
                      iconName: drift.Value(iconKey),
                      displayMode: drift.Value(displayMode),
                      createdAt: drift.Value(DateTime.now()),
                    ),
                  );
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: Text(strings.btnCreate),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context, WidgetRef ref, Folder folder, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${strings.btnDelete} "${folder.name}"?'),
        content: Text(strings.confirmDeleteFolderMsg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(strings.btnCancel)),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.deleteFolder(folder.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Text(strings.btnDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
