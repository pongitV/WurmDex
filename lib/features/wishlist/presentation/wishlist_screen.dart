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
import 'widgets/wishlist_manage_folders_dialog.dart';

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
        title: Text(strings.wishlistTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          // Manage wishlist folders
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined),
            tooltip: strings.manageWishlistFolders,
            onPressed: () => WishlistManageFoldersDialog.show(
              context,
              db: db,
              allItems: wishlistAsync.asData?.value ?? [],
              strings: strings,
            ),
          ),
          // Secondary display controls always available via the overflow menu
          const AppOverflowMenu(scaleTarget: CardScaleTarget.menu, showCurrency: true),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistAsync.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            return Center(
              child: AppEmptyState(
                icon: Icons.favorite_border,
                title: strings.wishlistEmptyTitle,
                message: strings.wishlistEmptySubtitle,
              ),
            );
          }

          // Extract distinct folders
          final folders = <String>{'Todas'};
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
                  final folder = i.folderName.isNotEmpty ? i.folderName : 'Geral';
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
                final pMap = {'Alta': 3, 'High': 3, 'Média': 2, 'Medium': 2, 'Baixa': 1, 'Low': 1};
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
            final estMarket = item.targetPriceBrl > 0 ? (item.targetPriceBrl * 0.95) : 25.0;
            if (item.targetPriceBrl > 0 && estMarket <= item.targetPriceBrl) {
              opportunityCount++;
            }
          }

          final totalBudgetDisplay = isUsd
              ? CurrencyFormatter.toUsd(totalTargetBrl / exchangeRate)
              : CurrencyFormatter.toBrl(totalTargetBrl);

          return CustomScrollView(
            slivers: [
              // Folder Selector Horizontal Bar
              SliverToBoxAdapter(
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...folders.map((folder) {
                        final isSelected = _selectedFolder == folder;
                        final displayName = folder == 'Todas'
                            ? strings.wishlistFolderAll
                            : (folder == 'Geral' ? strings.wishlistFolderDefault : folder);
                        final count = folder == 'Todas'
                            ? allItems.length
                            : allItems.where((i) => (i.folderName.isNotEmpty ? i.folderName : 'Geral') == folder).length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('$displayName ($count)'),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedFolder = folder);
                            },
                            avatar: isSelected
                                ? null
                                : const Icon(Icons.folder_outlined, size: 16),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.create_new_folder_outlined, size: 16),
                          label: Text(strings.wishlistNewFolder),
                          onPressed: () async {
                            final newFolder = await WishlistFolderDialog.show(context, strings);
                            if (newFolder != null && mounted) {
                              setState(() => _selectedFolder = newFolder);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Wishlist Summary Banner
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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

              // Wishlist Items — Always list view
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                        onMoveToCollection: () => _moveToCollection(context, db, item, strings),
                        onDelete: () async {
                          await db.deleteWishlistItem(item.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(strings.itemRemovedFromWishlist(item.name)),
                              ),
                            );
                          }
                        },
                      );
                    },
                    childCount: filteredItems.length,
                  ),
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
