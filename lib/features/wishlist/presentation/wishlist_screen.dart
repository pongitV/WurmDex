import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_sort_button.dart';
import '../../../../core/widgets/app_overflow_menu.dart';

import 'widgets/wishlist_card_tile.dart';
import 'widgets/wishlist_edit_dialog.dart';
import 'widgets/wishlist_folder_dialog.dart';

enum WishlistSortMode {
  newest,
  priceAsc,
  priceDesc,
  nameAsc,
  priority,
  setName,
}

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  String _selectedFolder = 'Todas';
  WishlistSortMode _sortMode = WishlistSortMode.newest;
  final Set<String> _createdFolders = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final currency = ref.watch(currencyProvider);
    final strings = getStrings(language);
    final wishlistAsync = ref.watch(wishlistStreamProvider);
    final db = ref.read(databaseProvider);
    final isUsd = currency == AppCurrency.usd;
    final exchangeRate = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.wishlistTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          AppSortButton<WishlistSortMode>(
            currentOption: _sortMode,
            isCompact: true,
            tooltip: strings.wishlistSortTitle,
            onSelected: (mode) => setState(() => _sortMode = mode),
            options: [
              SortOptionItem(
                value: WishlistSortMode.newest,
                label: strings.wishlistSortNewest,
                icon: Icons.access_time,
              ),
              SortOptionItem(
                value: WishlistSortMode.priority,
                label: strings.wishlistSortPriority,
                icon: Icons.priority_high,
              ),
              SortOptionItem(
                value: WishlistSortMode.priceAsc,
                label: strings.wishlistSortPriceAsc,
                icon: Icons.arrow_upward,
              ),
              SortOptionItem(
                value: WishlistSortMode.priceDesc,
                label: strings.wishlistSortPriceDesc,
                icon: Icons.arrow_downward,
              ),
              SortOptionItem(
                value: WishlistSortMode.nameAsc,
                label: strings.wishlistSortNameAsc,
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: WishlistSortMode.setName,
                label: strings.wishlistSortSetName,
                icon: Icons.style,
              ),
            ],
          ),
          // Secondary display controls always available via the overflow menu
          const AppOverflowMenu(
            scaleTarget: CardScaleTarget.menu,
            showCurrency: true,
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            tooltip: strings.wishlistNewFolder,
            onPressed: () => _createFolder(context, strings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistAsync.when(
        data: (allItems) {
          // Extract distinct folders
          final folders = <String>{'Todas'};
          folders.addAll(_createdFolders);
          for (final item in allItems) {
            if (item.folderName.isNotEmpty) {
              folders.add(item.folderName);
            } else {
              folders.add('Geral');
            }
          }

          // Filter by folder
          var filteredItems = _selectedFolder == 'Todas'
              ? allItems
              : allItems.where((i) {
                  final folder = i.folderName.isNotEmpty
                      ? i.folderName
                      : 'Geral';
                  return folder == _selectedFolder;
                }).toList();

          // Sort items
          filteredItems.sort((a, b) {
            switch (_sortMode) {
              case WishlistSortMode.newest:
                return b.createdAt.compareTo(a.createdAt);
              case WishlistSortMode.priceAsc:
                return a.targetPriceBrl.compareTo(b.targetPriceBrl);
              case WishlistSortMode.priceDesc:
                return b.targetPriceBrl.compareTo(a.targetPriceBrl);
              case WishlistSortMode.nameAsc:
                return a.name.compareTo(b.name);
              case WishlistSortMode.priority:
                final pMap = {
                  'Alta': 3,
                  'High': 3,
                  'Média': 2,
                  'Medium': 2,
                  'Baixa': 1,
                  'Low': 1,
                };
                final pA = pMap[a.priority] ?? 0;
                final pB = pMap[b.priority] ?? 0;
                return pB.compareTo(pA);
              case WishlistSortMode.setName:
                return a.setName.compareTo(b.setName);
            }
          });

          // Metrics calculation
          double totalTargetBrl = 0;
          int opportunityCount = 0;
          for (final item in filteredItems) {
            totalTargetBrl += item.targetPriceBrl;
            final estMarket = item.targetPriceBrl > 0
                ? (item.targetPriceBrl * 0.95)
                : 25.0;
            if (item.targetPriceBrl > 0 && estMarket <= item.targetPriceBrl) {
              opportunityCount++;
            }
          }

          final totalBudgetDisplay = isUsd
              ? CurrencyFormatter.toUsd(totalTargetBrl / exchangeRate)
              : CurrencyFormatter.toBrl(totalTargetBrl);

          if (allItems.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildFolderFilter(
                    context,
                    db,
                    allItems,
                    folders,
                    strings,
                  ),
                ),
                Expanded(
                  child: AppEmptyState(
                    icon: Icons.favorite_border,
                    title: strings.wishlistEmptyTitle,
                    message: strings.wishlistEmptySubtitle,
                  ),
                ),
              ],
            );
          }

          return CustomScrollView(
            slivers: [
              // Wishlist Summary Banner
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryStat(
                          strings.labelTotalCards,
                          '${filteredItems.length} ${strings.unitPcs}',
                          theme.colorScheme.primary,
                        ),
                        _buildSummaryStat(
                          strings.targetBudget,
                          totalBudgetDisplay,
                          AppColors.profitGreen,
                        ),
                        _buildSummaryStat(
                          strings.goodOpportunity,
                          strings.cardsCountLabel(opportunityCount),
                          Colors.amber.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Folder filter below the summary statistics.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _buildFolderFilter(
                    context,
                    db,
                    allItems,
                    folders,
                    strings,
                  ),
                ),
              ),

              // Wishlist Items — Always list view
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = filteredItems[index];
                    return WishlistCardTile(
                      item: item,
                      isUsd: isUsd,
                      exchangeRate: exchangeRate,
                      strings: strings,
                      onEdit: () => WishlistEditDialog.show(
                        context,
                        db: db,
                        item: item,
                        strings: strings,
                        isUsd: isUsd,
                        exchangeRate: exchangeRate,
                      ),
                      onMoveToCollection: () =>
                          _moveToCollection(context, db, item, strings),
                      onDelete: () async {
                        await db.deleteWishlistItem(item.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                strings.itemRemovedFromWishlist(item.name),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }, childCount: filteredItems.length),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(strings.errorWithMsg(err))),
      ),
    );
  }

  Widget _buildFolderFilter(
    BuildContext context,
    AppDatabase db,
    List<WishlistItem> allItems,
    Set<String> folders,
    AppStrings strings,
  ) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: folders.contains(_selectedFolder)
                ? _selectedFolder
                : 'Todas',
            decoration: InputDecoration(
              labelText: strings.wishlistFolderAll,
              prefixIcon: const Icon(Icons.folder_outlined),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: folders.map((folder) {
              final displayName = folder == 'Todas'
                  ? strings.wishlistFolderAll
                  : (folder == 'Geral'
                        ? strings.wishlistFolderDefault
                        : folder);
              final count = folder == 'Todas'
                  ? allItems.length
                  : allItems
                        .where(
                          (i) =>
                              (i.folderName.isNotEmpty
                                  ? i.folderName
                                  : 'Geral') ==
                              folder,
                        )
                        .length;
              return DropdownMenuItem(
                value: folder,
                child: Text('$displayName ($count)'),
              );
            }).toList(),
            onChanged: (folder) {
              if (folder != null) setState(() => _selectedFolder = folder);
            },
          ),
        ),
        if (_selectedFolder != 'Todas' && _selectedFolder != 'Geral')
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: strings.editWishlistFolder,
            onPressed: () =>
                _renameFolder(context, db, allItems, _selectedFolder, strings),
          ),
      ],
    );
  }

  Future<void> _createFolder(BuildContext context, AppStrings strings) async {
    final newFolder = await WishlistFolderDialog.show(context, strings);
    if (newFolder == null ||
        newFolder == 'Geral' ||
        newFolder == 'Todas' ||
        !mounted) {
      return;
    }

    setState(() {
      _createdFolders.add(newFolder);
      _selectedFolder = newFolder;
    });
  }

  Future<void> _renameFolder(
    BuildContext context,
    AppDatabase db,
    List<WishlistItem> allItems,
    String oldName,
    AppStrings strings,
  ) async {
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(dialogContext, value.isNotEmpty ? value : null);
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newName == null || newName == oldName || !mounted) return;
    if (newName == 'Geral' || newName == 'Todas') return;

    for (final item in allItems.where((item) => item.folderName == oldName)) {
      await (db.update(db.wishlistItems)
            ..where((table) => table.id.equals(item.id)))
          .write(WishlistItemsCompanion(folderName: drift.Value(newName)));
    }
    if (!mounted) return;

    setState(() {
      _createdFolders
        ..remove(oldName)
        ..add(newName);
      _selectedFolder = newName;
    });
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _moveToCollection(
    BuildContext context,
    AppDatabase db,
    WishlistItem item,
    AppStrings strings,
  ) async {
    await db.insertCard(
      UserCardsCompanion(
        id: drift.Value(const Uuid().v4()),
        cardApiId: drift.Value(item.cardApiId),
        name: drift.Value(item.name),
        number: drift.Value(item.number),
        setName: drift.Value(item.setName),
        rarity: const drift.Value('Rare'),
        imageUrl: drift.Value(item.imageUrl),
        purchasePriceBrl: drift.Value(item.targetPriceBrl),
        condition: const drift.Value('NM'),
        language: const drift.Value('PT'),
        finish: const drift.Value('Regular'),
        quantity: const drift.Value(1),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await db.deleteWishlistItem(item.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.wishlistMoveToCollectionSuccess)),
      );
    }
  }
}
