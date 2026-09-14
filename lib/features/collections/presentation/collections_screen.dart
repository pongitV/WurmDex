import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/utils/file_storage_helper.dart';
import '../../../../core/utils/folder_icon_helper.dart';
import '../../../../core/widgets/app_action_fab.dart';
import '../../../../core/widgets/app_filter_modal.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../../core/widgets/app_screen_title.dart';
import '../../../../core/widgets/app_search_dialog.dart';
import '../../../../core/widgets/app_sort_button.dart';
import 'widgets/collection_dashboard_widget.dart';

enum CollectionsSortOption {
  nameAsc,
  nameDesc,
  countDesc,
  countAsc,
  newest,
  oldest,
}

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  bool _onlyNonEmpty = false;
  bool _showGeneral = true;
  CollectionsSortOption _sortOption = CollectionsSortOption.nameAsc;
  String _searchQuery = '';

  int get _activeFilterCount =>
      (_onlyNonEmpty ? 1 : 0) + (!_showGeneral ? 1 : 0);

  Future<void> _showSearchDialog(AppStrings strings) async {
    final query = await AppSearchDialog.show(
      context,
      initialQuery: _searchQuery,
      hintText: strings.isEn ? 'Search folders...' : 'Buscar pastas...',
      strings: strings,
    );
    if (query != null && mounted) {
      setState(() => _searchQuery = query.trim());
    }
  }

  void _showFilterDialog(AppStrings strings) {
    bool tempNonEmpty = _onlyNonEmpty;
    bool tempShowGeneral = _showGeneral;
    AppFilterModalDialog.show(
      context: context,
      title: strings.collectionsFilterTitle,
      hasActiveFilters: _activeFilterCount > 0,
      strings: strings,
      onClear: () => setState(() {
        _onlyNonEmpty = false;
        _showGeneral = true;
      }),
      onApply: () => setState(() {
        _onlyNonEmpty = tempNonEmpty;
        _showGeneral = tempShowGeneral;
      }),
      children: [
        StatefulBuilder(
          builder: (ctx, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(strings.collectionsFilterAll),
                      selected: !tempNonEmpty,
                      onSelected: (_) => setModalState(() => tempNonEmpty = false),
                    ),
                    FilterChip(
                      label: Text(strings.collectionsFilterNonEmpty),
                      selected: tempNonEmpty,
                      onSelected: (_) => setModalState(() => tempNonEmpty = true),
                    ),
                    FilterChip(
                      label: Text(strings.collectionsFilterShowGeneral),
                      selected: tempShowGeneral,
                      onSelected: (val) => setModalState(() => tempShowGeneral = val),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final foldersAsync = ref.watch(foldersStreamProvider);
    final allCardsAsync = ref.watch(userCardsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: strings.collectionsTitle),
        actions: [
          AppFilterButton(
            activeFilterCount: _activeFilterCount,
            tooltip: strings.collectionsFilterTitle,
            isFilledTonal: false,
            onPressed: () => _showFilterDialog(strings),
          ),
          AppSortButton<CollectionsSortOption>(
            currentOption: _sortOption,
            isCompact: true,
            tooltip: strings.collectionsSortTitle,
            onSelected: (val) => setState(() => _sortOption = val),
            options: [
              SortOptionItem(
                value: CollectionsSortOption.nameAsc,
                label: strings.collectionsSortNameAsc,
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: CollectionsSortOption.nameDesc,
                label: strings.collectionsSortNameDesc,
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: CollectionsSortOption.countDesc,
                label: strings.collectionsSortCountDesc,
                icon: Icons.format_list_numbered,
              ),
              SortOptionItem(
                value: CollectionsSortOption.countAsc,
                label: strings.collectionsSortCountAsc,
                icon: Icons.low_priority,
              ),
              SortOptionItem(
                value: CollectionsSortOption.newest,
                label: strings.collectionsSortNewest,
                icon: Icons.access_time,
              ),
              SortOptionItem(
                value: CollectionsSortOption.oldest,
                label: strings.collectionsSortOldest,
                icon: Icons.history,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: () {
              ref.invalidate(foldersStreamProvider);
              ref.invalidate(userCardsStreamProvider);
              ref.read(exchangeRateProvider.notifier).refreshRate();
            },
          ),
          const AppOverflowMenu(
            scaleTarget: CardScaleTarget.collection,
            showCurrency: true,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: AppActionFab(
        tooltip: strings.searchActionTitle,
        sheetTitle: strings.collectionsTitle,
        actions: [
          AppFabAction(
            icon: Icons.search,
            title: strings.searchActionTitle,
            subtitle: strings.isEn ? 'Search folders' : 'Buscar pastas',
            onTap: () => _showSearchDialog(strings),
          ),
          AppFabAction(
            icon: Icons.create_new_folder_outlined,
            title: strings.btnCreateFolderAction,
            subtitle: strings.dlgCreateFolderTitle,
            onTap: () => _showCreateFolderDialog(context, ref, strings),
          ),
          AppFabAction(
            icon: Icons.file_upload_outlined,
            title: strings.isEn ? 'Export Backup' : 'Exportar Backup',
            subtitle: strings.isEn ? 'Backup your collection' : 'Salvar cópia da coleção',
            onTap: () async {
              final db = ref.read(databaseProvider);
              final ok = await FileStorageHelper.exportBackup(db);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? strings.backupExportSuccess : strings.backupExportFailed,
                    ),
                  ),
                );
              }
            },
          ),
          AppFabAction(
            icon: Icons.file_download_outlined,
            title: strings.backupRestoreTitle,
            subtitle: strings.backupMerge,
            onTap: () async {
              final db = ref.read(databaseProvider);
              final count = await FileStorageHelper.restoreBackup(db, RestoreMode.merge);
              if (context.mounted && count > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.backupMergedCount(count))),
                );
              }
            },
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      strings.sectionFoldersAndBinders,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: InputChip(
                        avatar: const Icon(Icons.search, size: 14),
                        label: Text(
                          _searchQuery,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => setState(() => _searchQuery = ''),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Folders List
          foldersAsync.when(
            data: (folders) {
              final allCards = allCardsAsync.asData?.value ?? const <UserCard>[];
              int getCardCount(String folderId) =>
                  allCards.where((c) => c.folderId == folderId).length;

              var displayFolders = List<Folder>.from(folders);
              if (_onlyNonEmpty) {
                displayFolders = displayFolders.where((f) => getCardCount(f.id) > 0).toList();
              }
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                displayFolders = displayFolders.where((f) => f.name.toLowerCase().contains(q)).toList();
              }

              switch (_sortOption) {
                case CollectionsSortOption.nameAsc:
                  displayFolders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  break;
                case CollectionsSortOption.nameDesc:
                  displayFolders.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                  break;
                case CollectionsSortOption.countDesc:
                  displayFolders.sort((a, b) => getCardCount(b.id).compareTo(getCardCount(a.id)));
                  break;
                case CollectionsSortOption.countAsc:
                  displayFolders.sort((a, b) => getCardCount(a.id).compareTo(getCardCount(b.id)));
                  break;
                case CollectionsSortOption.newest:
                  displayFolders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  break;
                case CollectionsSortOption.oldest:
                  displayFolders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  break;
              }

              final unorganizedCount = allCards.where((c) => c.folderId == null).length;
              final showGeneral = _showGeneral && (!_onlyNonEmpty || unorganizedCount > 0);

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Default General Collection Item
                    if (showGeneral) ...[
                      _buildGeneralCollectionCard(context, ref, strings),
                      const SizedBox(height: 10),
                    ],

                    // Custom User Folders
                    ...displayFolders.map((folder) => Padding(
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
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: strings.isEn ? 'Edit folder' : 'Editar pasta',
              onPressed: () => _showEditFolderDialog(context, ref, folder, strings),
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
                          message: strings.folderIconLabel(item.key),
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
                  final folderName = nameCtrl.text.trim();
                  if (folderName.isEmpty) return;
                  final db = ref.read(databaseProvider);
                  await db.insertFolder(
                    FoldersCompanion(
                      id: drift.Value(const Uuid().v4()),
                      name: drift.Value(folderName),
                      description: drift.Value(descCtrl.text.trim()),
                      colorTag: drift.Value(colorTag),
                      iconName: drift.Value(iconKey),
                      displayMode: drift.Value(displayMode),
                      createdAt: drift.Value(DateTime.now()),
                    ),
                  );

                  // Easter Egg: If folder is named "DarkLugia", unlock & activate Dark Lugia theme!
                  if (folderName.toLowerCase() == 'darklugia') {
                    AppPreferencesService.setDarkLugiaUnlocked(true);
                    ref.read(themeProvider.notifier).setTheme(AppThemeMode.darkLugia);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF150D24),
                          content: Row(
                            children: [
                              Image.asset(
                                'assets/images/characters/dark_lugia.png',
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.nights_stay, color: Colors.purpleAccent),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  strings.easterEggDarkLugiaUnlocked,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }

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

  void _showEditFolderDialog(BuildContext context, WidgetRef ref, Folder folder, AppStrings strings) {
    final nameCtrl = TextEditingController(text: folder.name);
    final descCtrl = TextEditingController(text: folder.description);
    String displayMode = folder.displayMode;
    String colorTag = folder.colorTag;
    String iconKey = folder.iconName;

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
          Color currentColor;
          try {
            currentColor = Color(int.parse(colorTag.replaceAll('#', '0xFF')));
          } catch (_) {
            currentColor = AppColors.darkAccent;
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(strings.isEn ? 'Edit Folder' : 'Editar Pasta'),
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
                          message: strings.folderIconLabel(item.key),
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
                                color: isSelected ? currentColor : theme.colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: AppColors.lossRed, size: 18),
                    label: Text(
                      strings.btnDelete,
                      style: const TextStyle(color: AppColors.lossRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.lossRed),
                      minimumSize: const Size(double.infinity, 42),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteFolder(context, ref, folder, strings);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.btnCancel),
              ),
              FilledButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  final db = ref.read(databaseProvider);
                  await db.updateFolder(
                    folder.toCompanion(true).copyWith(
                      name: drift.Value(nameCtrl.text.trim()),
                      description: drift.Value(descCtrl.text.trim()),
                      colorTag: drift.Value(colorTag),
                      iconName: drift.Value(iconKey),
                      displayMode: drift.Value(displayMode),
                    ),
                  );
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: Text(strings.save),
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
