import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_sort_button.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../../core/widgets/quick_currency_toggle.dart';
import '../../catalog/models/pokemon_card_item.dart';

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
                value: WishlistSortMode.priority,
                label: strings.wishlistSortPriority,
                icon: Icons.flag_outlined,
              ),
              SortOptionItem(
                value: WishlistSortMode.setName,
                label: strings.wishlistSortSetName,
                icon: Icons.style_outlined,
              ),
            ],
          ),
          const QuickCurrencyToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistAsync.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            return AppEmptyState(
              icon: Icons.bookmark_border,
              title: strings.wishlistEmptyTitle,
              message: strings.wishlistEmptySubtitle,
            );
          }

          // Extract distinct folder names
          final folders = <String>{'Todas'};
          for (final item in allItems) {
            folders.add(item.folderName.isNotEmpty ? item.folderName : 'Geral');
          }

          // Filter by selected folder
          final filteredItems = _selectedFolder == 'Todas'
              ? List<WishlistItem>.from(allItems)
              : allItems.where((i) {
                  final fName = i.folderName.isNotEmpty ? i.folderName : 'Geral';
                  return fName == _selectedFolder;
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
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              case WishlistSortMode.priority:
                final pOrder = {'Alta': 3, 'High': 3, 'Média': 2, 'Medium': 2, 'Baixa': 1, 'Low': 1};
                final pA = pOrder[a.priority] ?? 0;
                final pB = pOrder[b.priority] ?? 0;
                return pB.compareTo(pA);
              case WishlistSortMode.setName:
                return a.setName.toLowerCase().compareTo(b.setName.toLowerCase());
            }
          });

          // Calculate total budget for displayed items
          double totalTargetBrl = 0.0;
          int opportunityCount = 0;

          for (final item in filteredItems) {
            totalTargetBrl += item.targetPriceBrl;
            final estMarketBrl = item.targetPriceBrl > 0 ? (item.targetPriceBrl * 0.95) : 25.0;
            if (item.targetPriceBrl > 0 && estMarketBrl <= item.targetPriceBrl) {
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
                        final displayName = folder == 'Todas' ? strings.wishlistFolderAll : folder;
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
                          onPressed: () => _showCreateFolderDialog(context, strings),
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

              // Wishlist Items List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      final title = SemanticSearchHelper.formatCardIdentifier(
                        rawName: item.name,
                        number: item.number,
                      );

                      // Comparison between market and target price
                      final estMarketBrl = item.targetPriceBrl > 0 ? (item.targetPriceBrl * 0.95) : 25.0;
                      final isOpportunity = item.targetPriceBrl > 0 && estMarketBrl <= item.targetPriceBrl;

                      final targetPriceDisplay = isUsd
                          ? CurrencyFormatter.toUsd(item.targetPriceBrl / exchangeRate)
                          : CurrencyFormatter.toBrl(item.targetPriceBrl);

                      final currentMarketDisplay = isUsd
                          ? CurrencyFormatter.toUsd(estMarketBrl / exchangeRate)
                          : CurrencyFormatter.toBrl(estMarketBrl);

                      Color priorityColor;
                      switch (item.priority) {
                        case 'Alta':
                        case 'High':
                          priorityColor = AppColors.lossRed;
                          break;
                        case 'Média':
                        case 'Medium':
                          priorityColor = AppColors.warningYellow;
                          break;
                        default:
                          priorityColor = AppColors.profitGreen;
                      }

                      String displayPriority = item.priority;
                      if (item.priority == 'Alta' || item.priority == 'High') {
                        displayPriority = strings.priorityHigh;
                      } else if (item.priority == 'Média' || item.priority == 'Medium') {
                        displayPriority = strings.priorityMedium;
                      } else if (item.priority == 'Baixa' || item.priority == 'Low') {
                        displayPriority = strings.priorityLow;
                      }

                      final folderBadge = item.folderName.isNotEmpty ? item.folderName : 'Geral';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isOpportunity
                                ? AppColors.profitGreen.withValues(alpha: 0.5)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            final catalogCard = PokemonCardItem(
                              id: item.cardApiId,
                              name: item.name,
                              number: item.number,
                              setId: item.setName.toLowerCase().replaceAll(' ', '-'),
                              setName: item.setName,
                              rarity: 'Rare',
                              imageUrlSmall: item.imageUrl,
                              imageUrlLarge: item.imageUrl,
                              types: const ['Colorless'],
                              supertype: 'Pokémon',
                              artist: '',
                              tcgMarketUsd: estMarketBrl / exchangeRate,
                            );
                            AppNavigator.toCardDetails(context, catalogCard);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Thumbnail
                                PokemonCardImage(
                                  imageUrl: item.imageUrl,
                                  width: 48,
                                  height: 66,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 14),

                                // Card info & prices
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Folder Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.folder_outlined, size: 10, color: theme.colorScheme.primary),
                                                const SizedBox(width: 3),
                                                Text(
                                                  folderBadge,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.setName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          // Priority Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: priorityColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              displayPriority,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: priorityColor,
                                              ),
                                            ),
                                          ),

                                          // Target Price
                                          Text(
                                            '${strings.targetPricePrefix}$targetPriceDisplay',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          // Current Market
                                          Text(
                                            '(${strings.currentMarketPrice}: $currentMarketDisplay)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
                                          ),

                                          // Opportunity Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: (isOpportunity ? AppColors.profitGreen : Colors.orange)
                                                  .withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: (isOpportunity ? AppColors.profitGreen : Colors.orange)
                                                    .withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              isOpportunity ? strings.goodOpportunity : strings.aboveTarget,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isOpportunity ? AppColors.profitGreen : Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions Popup Menu
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                  onSelected: (val) async {
                                    if (val == 'edit') {
                                      _showEditTargetPriceDialog(
                                        context,
                                        db,
                                        item,
                                        strings,
                                        isUsd,
                                        exchangeRate,
                                      );
                                    } else if (val == 'move_to_collection') {
                                      _moveToCollection(context, db, item, strings);
                                    } else if (val == 'delete') {
                                      await db.deleteWishlistItem(item.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(strings.itemRemovedFromWishlist(item.name)),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_outlined, size: 18),
                                          const SizedBox(width: 8),
                                          Text(strings.editWishlistItem),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'move_to_collection',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.profitGreen),
                                          const SizedBox(width: 8),
                                          Text(strings.wishlistMoveToCollection),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_outline, size: 18, color: AppColors.lossRed),
                                          const SizedBox(width: 8),
                                          Text(strings.tooltipRemoveFromWishlist),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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

  void _showCreateFolderDialog(BuildContext context, AppStrings strings) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.wishlistNewFolder),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.wishlistFolderNamePrompt, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: strings.wishlistFolderNameLabel,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => _selectedFolder = text);
              }
              Navigator.pop(ctx);
            },
            child: Text(strings.save),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToCollection(
    BuildContext context,
    AppDatabase db,
    WishlistItem item,
    AppStrings strings,
  ) async {
    // Insert into UserCards (independent collection)
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

    // Delete from Wishlist
    await db.deleteWishlistItem(item.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.wishlistMoveToCollectionSuccess)),
      );
    }
  }

  void _showEditTargetPriceDialog(
    BuildContext context,
    AppDatabase db,
    WishlistItem item,
    AppStrings strings,
    bool isUsd,
    double exchangeRate,
  ) {
    final initialPrice = isUsd ? (item.targetPriceBrl / exchangeRate) : item.targetPriceBrl;
    final controller = TextEditingController(text: initialPrice > 0 ? initialPrice.toStringAsFixed(2) : '');
    final folderController = TextEditingController(text: item.folderName.isNotEmpty ? item.folderName : 'Geral');
    String priority = item.priority;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${strings.editWishlistItem} - ${item.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.targetPricePrompt,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: isUsd ? '\$ ' : 'R\$ ',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: folderController,
                  decoration: InputDecoration(
                    labelText: strings.wishlistFolderNameLabel,
                    prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: strings.labelPriority,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: priority,
                  items: [
                    DropdownMenuItem(value: strings.priorityLow, child: Text(strings.priorityLow)),
                    DropdownMenuItem(value: strings.priorityMedium, child: Text(strings.priorityMedium)),
                    DropdownMenuItem(value: strings.priorityHigh, child: Text(strings.priorityHigh)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => priority = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final inputVal = double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
                  final targetBrl = isUsd ? (inputVal * exchangeRate) : inputVal;
                  final updatedFolder = folderController.text.trim().isEmpty ? 'Geral' : folderController.text.trim();

                  await (db.update(db.wishlistItems)..where((t) => t.id.equals(item.id))).write(
                    WishlistItemsCompanion(
                      targetPriceBrl: drift.Value(targetBrl),
                      priority: drift.Value(priority),
                      folderName: drift.Value(updatedFolder),
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
}

