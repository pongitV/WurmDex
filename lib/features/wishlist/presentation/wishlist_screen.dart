import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/card_view_mode_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/providers/grid_composition_provider.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/marketplace_url_helper.dart';
import '../../../../core/widgets/app_action_fab.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_filter_modal.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../../core/widgets/app_screen_title.dart';
import '../../../../core/widgets/app_search_dialog.dart';
import '../../../../core/widgets/app_sort_button.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/folder_badge.dart';
import '../../../../core/widgets/language_flag_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../card_details/services/pricing_service.dart';
import '../services/wishlist_folder_service.dart';

import 'widgets/wishlist_background_settings_dialog.dart';
import 'widgets/wishlist_card_tile.dart';
import 'widgets/wishlist_edit_dialog.dart';
import 'widgets/wishlist_kpi_summary.dart';
import 'widgets/wishlist_manage_folders_dialog.dart';

enum WishlistSortMode {
  newest,
  priceAsc,
  priceDesc,
  nameAsc,
  setName,
}

enum WishlistFilterType { inRange, preSale }

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  String _selectedFolder = 'Todas';
  WishlistSortMode _sortMode = WishlistSortMode.newest;
  final Set<String> _createdFolders = {};
  String _searchQuery = '';
  bool _backgroundScanEnabled = false;
  bool _isCheckingAll = false;
  final Set<String> _checkingItemIds = {};
  final Set<WishlistFilterType> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _createdFolders.addAll(AppPreferencesService.getWishlistFolders());
    _backgroundScanEnabled =
        AppPreferencesService.isBackgroundWishlistScanEnabled();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoCheckStaleCardPrices();
    });
  }

  bool _isInRange(WishlistItem item) {
    final price = item.currentPriceBrl;
    if (price == null || price <= 0) return false;
    if (item.minTargetPriceBrl > 0 && price < item.minTargetPriceBrl) {
      return false;
    }
    return price <= item.targetPriceBrl;
  }

  (Color, String) _resolveStatus(
    WishlistItem item,
    AppStrings strings,
  ) {
    final price = item.currentPriceBrl;
    if (price != null && price > 0) {
      if (_isInRange(item)) {
        return (Colors.green, strings.statusInRange);
      }
      return (Colors.amber.shade800, strings.statusAboveRange);
    }
    return (
      Colors.grey,
      item.lastCheckedAt == null
          ? strings.statusPending
          : strings.statusOutOfStock,
    );
  }

  Future<void> _autoCheckStaleCardPrices() async {
    try {
      final db = ref.read(databaseProvider);
      final items = await db.getAllWishlist();
      final stale = items
          .where(
            (i) => i.currentPriceBrl == null || i.lastCheckedAt == null,
          )
          .toList();
      for (final item in stale) {
        if (!mounted) break;
        _checkSingleItem(item, notify: false);
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } catch (_) {
      // Keep the screen usable even if the local DB fails to open.
    }
  }

  Future<void> _checkSingleItem(
    WishlistItem item, {
    bool notify = true,
  }) async {
    setState(() => _checkingItemIds.add(item.id));
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    try {
      final result = await PricingService.getPricesForCard(
        cardName: item.name,
        cardNumber: item.number,
        cardId: item.cardApiId,
        setName: item.setName,
      );
      final price = result.ligaMinBrl ?? result.ligaAvgBrl;
      await (db.update(db.wishlistItems)
            ..where((t) => t.id.equals(item.id)))
          .write(
        WishlistItemsCompanion(
          currentPriceBrl: drift.Value(price),
          lastCheckedAt: drift.Value(DateTime.now()),
        ),
      );
      if (mounted && notify) {
        final theme = Theme.of(context);
        final isInRange = _isInRange(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isInRange ? Icons.check_circle : Icons.search,
                  size: 20,
                  color:
                      isInRange ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: _isCheckingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  tooltip: strings.btnCheckAllNow,
                  onPressed: _isCheckingAll ? null : _checkAllItems,
                ),
                Expanded(
                  child: Text(
                    isInRange
                        ? '${item.name}: ${strings.statusInRange}'
                        : '${item.name}: ${strings.lowestPriceUpdatedText}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(milliseconds: 1600),
          ),
        );
      }
    } catch (_) {
      // Persist the failed check timestamp so we don't retry forever on this
      // launch; the next manual check refreshes it.
      if (mounted) {
        await (db.update(db.wishlistItems)
              ..where((t) => t.id.equals(item.id)))
            .write(
          WishlistItemsCompanion(
            lastCheckedAt: drift.Value(DateTime.now()),
          ),
        );
      }
      if (mounted && notify) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.statusOutOfStock)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkingItemIds.remove(item.id));
      }
    }
  }

  Future<void> _checkAllItems() async {
    if (_isCheckingAll) return;
    setState(() => _isCheckingAll = true);
    final strings = getStrings(ref.read(languageProvider));

    try {
      final allItems =
          ref.read(wishlistStreamProvider).value ?? const <WishlistItem>[];
      for (final item in allItems) {
        if (!mounted) break;
        await _checkSingleItem(item);
        await Future.delayed(const Duration(milliseconds: 400));
      }
      if (mounted) {
        final refreshed =
            ref.read(wishlistStreamProvider).value ?? const <WishlistItem>[];
        final count = refreshed.where(_isInRange).length;
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  count > 0 ? Icons.check_circle : Icons.info_outline,
                  size: 20,
                  color: count > 0 ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.alertsCheckedSuccess(count),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingAll = false);
      }
    }
  }

  void _toggleFilter(WishlistFilterType filter) {
    setState(() {
      if (!_activeFilters.add(filter)) {
        _activeFilters.remove(filter);
      }
    });
  }

  Future<void> _openEditDialog(WishlistItem item) async {
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));
    await WishlistEditDialog.show(
      context,
      db: db,
      item: item,
      strings: strings,
      isUsd: ref.read(currencyProvider) == AppCurrency.usd,
      exchangeRate: ref.read(exchangeRateProvider),
      onMoveToCollection: () => _moveToCollection(db, item, strings),
    );
  }

  Future<void> _confirmDelete(WishlistItem item) async {
    final strings = getStrings(ref.read(languageProvider));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.deleteAlertTitle),
        content: Text('${strings.deleteAlertConfirm}\n\n"${item.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteWishlistItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.itemRemovedFromWishlist(item.name))),
        );
      }
    }
  }

  Future<void> _openExternalLiga(WishlistItem item) =>
      MarketplaceUrlHelper.openLigaPokemon(
        context,
        cardName: item.name,
        cardNumber: item.number,
        setName: item.setName,
      );

  Future<void> _openAddDialog() async {
    await AppNavigator.toCatalog(context, autoFocusSearch: true);
  }

  Future<void> _showSearchDialog() async {
    final strings = getStrings(ref.read(languageProvider));
    final query = await AppSearchDialog.show(
      context,
      initialQuery: _searchQuery,
      hintText: strings.filterProductsHint,
      strings: strings,
    );
    if (query != null && mounted) {
      setState(() => _searchQuery = query.trim());
    }
  }


  Future<void> _showCollectionManager(List<WishlistItem> allItems) async {
    final strings = getStrings(ref.read(languageProvider));
    final db = ref.read(databaseProvider);
    await WishlistManageFoldersDialog.show(
      context,
      db: db,
      allItems: allItems,
      strings: strings,
    );
    if (mounted) {
      final currentFolders =
          WishlistFolderService.getAllFolders(items: allItems);
      setState(() {
        _createdFolders.clear();
        _createdFolders.addAll(AppPreferencesService.getWishlistFolders());
        if (!currentFolders.contains(_selectedFolder) &&
            _selectedFolder != 'Todas' &&
            _selectedFolder != 'Geral') {
          _selectedFolder = 'Todas';
        }
      });
    }
  }

  Future<void> _showBackgroundDialog(AppStrings strings) async {
    await WishlistBackgroundSettingsDialog.show(
      context: context,
      enabled: _backgroundScanEnabled,
      onToggle: (value) {
        setState(() => _backgroundScanEnabled = value);
      },
      strings: strings,
    );
  }

  Future<void> _moveToCollection(
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
        condition: drift.Value(item.condition),
        language: drift.Value(item.language),
        finish: const drift.Value('Regular'),
        quantity: const drift.Value(1),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    await db.deleteWishlistItem(item.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.wishlistMoveToCollectionSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = getStrings(ref.watch(languageProvider));
    final currency = ref.watch(currencyProvider);
    final isUsd = currency == AppCurrency.usd;
    final exchangeRate = ref.watch(exchangeRateProvider);
    final wishlistAsync = ref.watch(wishlistStreamProvider);
    final db = ref.read(databaseProvider);
    final cardScale = ref.watch(collectionCardScaleProvider);
    ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);

    final allItems = wishlistAsync.value ?? const <WishlistItem>[];
    final folderList = WishlistFolderService.getAllFolders(items: allItems);

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: strings.wishlistTitle),
        actions: [
          AppFilterButton(
            activeFilterCount:
                _activeFilters.length + (_selectedFolder != 'Todas' ? 1 : 0),
            tooltip: strings.filtersAndMore,
            isFilledTonal: false,
            onPressed: () {
              AppFilterModalDialog.show(
                context: context,
                title: strings.filtersAndMore,
                hasActiveFilters:
                    _activeFilters.isNotEmpty || _selectedFolder != 'Todas',
                strings: strings,
                onClear: () => setState(() {
                  _activeFilters.clear();
                  _selectedFolder = 'Todas';
                }),
                onApply: () => setState(() {}),
                children: [
                  StatefulBuilder(
                    builder: (dialogContext, setDialogState) {
                      final primary = theme.colorScheme.primary;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.filterSectionStatusAndOptions,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChip(
                                showCheckmark: false,
                                selectedColor: primary.withValues(alpha: 0.18),
                                label: Text(strings.kpiInRangeTotal),
                                selected: _activeFilters
                                    .contains(WishlistFilterType.inRange),
                                onSelected: (_) {
                                  setState(() =>
                                      _toggleFilter(WishlistFilterType.inRange));
                                  setDialogState(() {});
                                },
                              ),
                              FilterChip(
                                showCheckmark: false,
                                selectedColor: primary.withValues(alpha: 0.18),
                                  label: Text(strings.preOrderLabel),
                                selected: _activeFilters
                                    .contains(WishlistFilterType.preSale),
                                onSelected: (_) {
                                  setState(() =>
                                      _toggleFilter(WishlistFilterType.preSale));
                                  setDialogState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.folder_outlined,
                                  size: 18, color: primary),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(
                                    strings.filterSectionFolders,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChip(
                                showCheckmark: false,
                                selectedColor: primary.withValues(alpha: 0.18),
                                avatar: Icon(
                                  Icons.apps,
                                  size: 16,
                                  color: _selectedFolder == 'Todas'
                                      ? primary
                                      : null,
                                ),
                                label: Text(strings.wishlistFolderAll),
                                selected: _selectedFolder == 'Todas',
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedFolder = 'Todas');
                                  }
                                  setDialogState(() {});
                                },
                              ),
                              ...folderList.map((folder) {
                                final displayName = folder == 'Geral'
                                    ? strings.wishlistFolderDefault
                                    : folder;
                                final isSelected = _selectedFolder == folder;
                                return FilterChip(
                                  showCheckmark: false,
                                  selectedColor:
                                      primary.withValues(alpha: 0.18),
                                  avatar: Icon(
                                    folder == 'Geral'
                                        ? Icons.folder
                                        : Icons.folder_outlined,
                                    size: 16,
                                    color: isSelected ? primary : null,
                                  ),
                                  label: Text(displayName),
                                  selected: isSelected,
                                  onSelected: (selectedWithOnly) {
                                    setState(() {
                                      _selectedFolder = selectedWithOnly
                                          ? folder
                                          : 'Todas';
                                    });
                                    setDialogState(() {});
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
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
                value: WishlistSortMode.setName,
                label: strings.wishlistSortSetName,
                icon: Icons.style,
              ),
            ],
          ),
          IconButton(
            icon: _isCheckingAll
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: _isCheckingAll ? null : _checkAllItems,
          ),
          const AppOverflowMenu(
            scaleTarget: CardScaleTarget.collection,
            showCurrency: true,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistAsync.when(
        data: (allItems) {
          if (allItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppEmptyState(
                      icon: Icons.favorite_border,
                      title: strings.wishlistEmptyTitle,
                      message: strings.wishlistEmptySubtitle,
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter by folder.
          var filteredItems = _selectedFolder == 'Todas'
              ? allItems
              : allItems.where((i) {
                  final folder = i.folderName.isNotEmpty
                      ? i.folderName
                      : 'Geral';
                  return folder == _selectedFolder;
                }).toList();

          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filteredItems = filteredItems.where((item) {
              return item.name.toLowerCase().contains(query) ||
                  item.setName.toLowerCase().contains(query);
            }).toList();
          }

          filteredItems = filteredItems.where((item) {
            if (_activeFilters.isEmpty) return true;
            return _activeFilters.any((filter) {
              switch (filter) {
                case WishlistFilterType.inRange:
                  return _isInRange(item);
                case WishlistFilterType.preSale:
                  return item.isPreSale;
              }
            });
          }).toList();

          // Sort items.
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
              case WishlistSortMode.setName:
                return a.setName.compareTo(b.setName);
            }
          });

          // KPIs (mirroring LigaRadar).
          final inRangeItems =
              filteredItems.where(_isInRange).toList();
          final totalPrice = filteredItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                (item.currentPriceBrl != null && item.currentPriceBrl! > 0
                    ? item.currentPriceBrl!
                    : item.targetPriceBrl),
          );
          final now = DateTime.now();
          final updatedToday = filteredItems
              .where(
                (item) =>
                    item.lastCheckedAt != null &&
                    item.lastCheckedAt!.year == now.year &&
                    item.lastCheckedAt!.month == now.month &&
                    item.lastCheckedAt!.day == now.day,
              )
              .length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    children: [
                      WishlistKpiSummary(
                        inRangeCount: inRangeItems.length,
                        totalPrice: totalPrice,
                        updatedToday: updatedToday,
                        totalCards: filteredItems.length,
                        isInRangeSelected: _activeFilters.contains(
                          WishlistFilterType.inRange,
                        ),
                        onToggleInRange: () => _toggleFilter(
                          WishlistFilterType.inRange,
                        ),
                        isUsd: isUsd,
                        exchangeRate: exchangeRate,
                        strings: strings,
                      ),
                      if (_selectedFolder != 'Todas' || _searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (_selectedFolder != 'Todas')
                                  InputChip(
                                    avatar: const Icon(Icons.folder_outlined, size: 14),
                                    label: Text(
                                      _selectedFolder == 'Geral'
                                          ? strings.wishlistFolderDefault
                                          : _selectedFolder,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onDeleted: () =>
                                        setState(() => _selectedFolder = 'Todas'),
                                  ),
                                if (_searchQuery.isNotEmpty)
                                  InputChip(
                                    avatar: const Icon(Icons.search, size: 14),
                                    label: Text(
                                      _searchQuery,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onDeleted: () =>
                                        setState(() => _searchQuery = ''),
                                  ),
                                ],
                              ),
                            ),
                          ),

                    ],
                  ),
                ),
              ),

              if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      strings.noFilterMatch,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else if (viewMode == CardViewMode.list)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = filteredItems[index];
                      return Transform.scale(
                        scale: cardScale / 0.85,
                        alignment: Alignment.topCenter,
                        child: _buildWishlistItem(
                          context,
                          item,
                          db,
                          strings,
                          isUsd,
                          exchangeRate,
                        ),
                      );
                    }, childCount: filteredItems.length),
                  ),
                )
              else
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = resolveCardGridCrossAxisCount(
                      context: context,
                      ref: ref,
                      availableWidth: constraints.crossAxisExtent,
                      cardScale: cardScale,
                    );
                    final adjustedAspect = (0.64 * (1.15 / cardScale))
                        .clamp(0.50, 1.05)
                        .toDouble();
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = filteredItems[index];
                          return _buildWishlistGridItem(
                            theme,
                            strings,
                            item,
                            isUsd,
                            exchangeRate,
                            _checkingItemIds.contains(item.id),
                            cardScale: cardScale,
                          );
                        }, childCount: filteredItems.length),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: adjustedAspect,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text(strings.errorMessage(err.toString()))),
      ),
      floatingActionButton: AppActionFab(
        tooltip: strings.searchActionTitle,
        sheetTitle: strings.wishlistTitle,
        actions: [
          AppFabAction(
            icon: Icons.search,
            title: strings.searchActionTitle,
            subtitle: strings.searchHint,
            onTap: _showSearchDialog,
          ),
          AppFabAction(
            icon: Icons.add_card_outlined,
            title: strings.btnAddCard,
            subtitle: strings.searchCardsPlaceholder,
            onTap: _openAddDialog,
          ),
          AppFabAction(
            icon: Icons.wallpaper_outlined,
            title: strings.radarBackgroundSettings,
            subtitle: strings.personalizeBackgroundSubtitle,
            onTap: () => _showBackgroundDialog(strings),
          ),
          AppFabAction(
            icon: Icons.folder_copy_outlined,
            title: strings.manageFoldersTitle,
            subtitle: '${_createdFolders.length} ${strings.labelFolder}',
            onTap: () {
              final currentItems =
                  ref.read(wishlistStreamProvider).value ?? const [];
              _showCollectionManager(currentItems);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    WishlistItem item,
    AppDatabase db,
    AppStrings strings,
    bool isUsd,
    double exchangeRate,
  ) {
    return WishlistCardTile(
      item: item,
      isUsd: isUsd,
      exchangeRate: exchangeRate,
      strings: strings,
      isChecking: _checkingItemIds.contains(item.id),
      onEdit: () => _openEditDialog(item),
      onRefresh: () => _checkSingleItem(item),
      onOpenLiga: () => _openExternalLiga(item),
      onDelete: () => _confirmDelete(item),
    );
  }

  Widget _buildWishlistGridItem(
    ThemeData theme,
    AppStrings strings,
    WishlistItem item,
    bool isUsd,
    double exchangeRate,
    bool isChecking, {
    required double cardScale,
  }) {
    final price = item.currentPriceBrl;
    final priceEnabled = price != null && price > 0;
    final priceText = priceEnabled
        ? (isUsd
            ? CurrencyFormatter.toUsd(price / exchangeRate)
            : CurrencyFormatter.toBrl(price))
        : (item.lastCheckedAt == null
            ? strings.statusPending
            : strings.statusOutOfStock);
    final (statusColor, statusText) = _resolveStatus(item, strings);
    final isInRange = _isInRange(item);

    return Card(
      margin: EdgeInsets.zero,
      color: isInRange
          ? Colors.green.withValues(alpha: 0.12)
          : priceEnabled
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : null,
      elevation: priceEnabled ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isInRange
              ? Colors.green
              : priceEnabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
          width: isInRange || priceEnabled ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openEditDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: PokemonCardImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isInRange
                          ? Colors.green.withValues(alpha: 0.12)
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isInRange
                            ? Colors.green.withValues(alpha: 0.4)
                            : theme.colorScheme.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        priceText,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: isInRange
                              ? Colors.green.shade700
                              : (priceEnabled
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: [
                  FolderBadge(
                    folderName: item.folderName.isNotEmpty && item.folderName != 'Geral'
                        ? item.folderName
                        : strings.wishlistFolderDefault,
                    compact: true,
                  ),
                  ConditionBadge(
                    condition: item.condition,
                    compact: true,
                  ),
                  LanguageFlagBadge(
                    language: item.language,
                    compact: true,
                    showCode: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    icon: isChecking
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 17),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    tooltip: strings.refreshTooltip,
                    onPressed: isChecking
                        ? null
                        : () => _checkSingleItem(item),
                  ),
                  const Spacer(),
                  Icon(
                    isInRange
                        ? Icons.check_circle
                        : Icons.notifications_active_outlined,
                    color: isInRange
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}