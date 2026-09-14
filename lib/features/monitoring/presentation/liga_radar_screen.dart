import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/marketplace_url_helper.dart';
import '../../../core/widgets/app_action_fab.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_filter_modal.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_screen_title.dart';
import '../../../core/widgets/app_search_dialog.dart';
import '../../../core/widgets/app_sort_button.dart';
import '../../../core/widgets/card_description_badges.dart';
import '../../../core/widgets/language_flag_badge.dart';
import '../services/liga_scraper_service.dart';
import 'widgets/add_edit_liga_alert_dialog.dart';
import 'widgets/radar_background_settings_sheet.dart';
import 'widgets/radar_kpi_summary.dart';

enum LigaFilterType { inRange, preSale, active }
enum LigaRadarSortOption { targetDiff, priceAsc, priceDesc, nameAsc, newest }

class LigaRadarScreen extends ConsumerStatefulWidget {
  const LigaRadarScreen({super.key});

  @override
  ConsumerState<LigaRadarScreen> createState() => _LigaRadarScreenState();
}

class _LigaRadarScreenState extends ConsumerState<LigaRadarScreen> {
  final Set<LigaFilterType> _activeFilters = {};
  String? _collectionFilter;
  LigaRadarSortOption _sortOption = LigaRadarSortOption.targetDiff;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isCheckingAll = false;
  final Set<String> _checkingItemIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoCheckStaleAlerts();
    });
  }

  Future<void> _autoCheckStaleAlerts() async {
    final db = ref.read(databaseProvider);
    final alerts = await db.getAllLigaAlerts();
    final stale = alerts
        .where(
          (a) =>
              a.lastCheckedAt == null ||
              a.currentLowestPrice == null ||
              a.imageUrl.isEmpty,
        )
        .toList();
    for (final alert in stale) {
      if (!mounted) break;
      _checkSingleItem(alert);
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      setState(() {
        _searchQuery = query.trim();
        _searchController.text = _searchQuery;
      });
    }
  }

  Future<void> _openAddDialog() async {
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AddEditLigaAlertDialog(db: db, strings: strings),
    );

    if (result == true && mounted) {
      _autoCheckStaleAlerts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.purchasePriceUpdatedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openEditDialog(LigaPriceAlert alert) async {
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    await showDialog<bool>(
      context: context,
      builder: (ctx) => AddEditLigaAlertDialog(
        db: db,
        strings: strings,
        existingAlert: alert,
      ),
    );
  }

  Future<void> _openBackgroundSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const RadarBackgroundSettingsSheet(),
    );
    // Refresh the toolbar icon state after the sheet closes.
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkSingleItem(LigaPriceAlert alert) async {
    setState(() => _checkingItemIds.add(alert.id));
    final db = ref.read(databaseProvider);

    final strings = getStrings(ref.read(languageProvider));

    try {
      final result = await LigaScraperService.checkAlert(
        alert: alert,
        db: db,
        notify: true,
      );
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  result.isInRange ? Icons.check_circle : Icons.search,
                  size: 20,
                  color: result.isInRange
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.isInRange
                        ? '${alert.title}: ${strings.statusInRange}'
                        : '${alert.title}: ${strings.lowestPriceUpdatedText}',
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
    } finally {
      if (mounted) {
        setState(() => _checkingItemIds.remove(alert.id));
      }
    }
  }

  Future<void> _checkAllItems() async {
    if (_isCheckingAll) return;
    setState(() => _isCheckingAll = true);
    final db = ref.read(databaseProvider);
    final strings = getStrings(ref.read(languageProvider));

    try {
      final count = await LigaScraperService.checkAllActiveAlerts(
        db: db,
        notify: true,
      );
      if (mounted) {
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

  void _toggleFilter(LigaFilterType filter) {
    setState(() {
      if (!_activeFilters.add(filter)) {
        _activeFilters.remove(filter);
      }
    });
  }

  Future<void> _confirmDelete(LigaPriceAlert alert) async {
    final strings = getStrings(ref.read(languageProvider));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.deleteAlertTitle),
        content: Text('${strings.deleteAlertConfirm}\n\n"${alert.title}"'),
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
      await db.deleteLigaAlert(alert.id);
    }
  }

  Future<void> _openExternalLiga(String url) =>
      MarketplaceUrlHelper.launchExternalUrl(
        context,
        url,
        platformName: 'LigaPokémon',
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = getStrings(ref.watch(languageProvider));
    final alertsAsync = ref.watch(ligaAlertsStreamProvider);

    // Watch display providers so the list/grid and scale react to the menu.
    final cardScale = ref.watch(collectionCardScaleProvider);
    ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);
    final currency = ref.watch(currencyProvider);
    final isUsd = currency == AppCurrency.usd;
    final exchangeRate = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: strings.ligaRadarTitle),
        actions: [
          AppFilterButton(
            activeFilterCount:
                _activeFilters.length + (_collectionFilter != null ? 1 : 0),
            tooltip: strings.filtersAndMore,
            isFilledTonal: false,
            onPressed: () {
              AppFilterModalDialog.show(
                context: context,
                title: strings.filtersAndMore,
                hasActiveFilters:
                    _activeFilters.isNotEmpty || _collectionFilter != null,
                strings: strings,
                onClear: () => setState(() {
                  _activeFilters.clear();
                  _collectionFilter = null;
                }),
                onApply: () => setState(() {}),
                children: [
                  Text(
                    strings.isEn ? 'Status & Options' : 'Status e Opções',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(strings.kpiInRangeTotal),
                        selected:
                            _activeFilters.contains(LigaFilterType.inRange),
                        onSelected: (_) => _toggleFilter(LigaFilterType.inRange),
                      ),
                      FilterChip(
                        label: Text(strings.isEn ? 'Pre-order' : 'Pré-venda'),
                        selected:
                            _activeFilters.contains(LigaFilterType.preSale),
                        onSelected: (_) => _toggleFilter(LigaFilterType.preSale),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          AppSortButton<LigaRadarSortOption>(
            currentOption: _sortOption,
            isCompact: true,
            tooltip: strings.radarSortTitle,
            onSelected: (val) => setState(() => _sortOption = val),
            options: [
              SortOptionItem(
                value: LigaRadarSortOption.targetDiff,
                label: strings.radarSortTargetDiff,
                icon: Icons.trending_down,
              ),
              SortOptionItem(
                value: LigaRadarSortOption.priceAsc,
                label: strings.radarSortPriceAsc,
                icon: Icons.arrow_upward,
              ),
              SortOptionItem(
                value: LigaRadarSortOption.priceDesc,
                label: strings.radarSortPriceDesc,
                icon: Icons.arrow_downward,
              ),
              SortOptionItem(
                value: LigaRadarSortOption.nameAsc,
                label: strings.radarSortNameAsc,
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: LigaRadarSortOption.newest,
                label: strings.radarSortNewest,
                icon: Icons.access_time,
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
      floatingActionButton: AppActionFab(
        tooltip: strings.searchActionTitle,
        sheetTitle: strings.ligaRadarTitle,
        actions: [
          AppFabAction(
            icon: Icons.search,
            title: strings.searchActionTitle,
            subtitle: strings.filterProductsHint,
            onTap: _showSearchDialog,
          ),
          AppFabAction(
            icon: Icons.add_alert_outlined,
            title: strings.btnAddAlert,
            subtitle: 'LigaPokémon',
            onTap: _openAddDialog,
          ),
          AppFabAction(
            icon: Icons.wallpaper_outlined,
            title: strings.radarBackgroundSettings,
            subtitle: strings.isEn ? 'Automatic price checks' : 'Verificação automática',
            onTap: _openBackgroundSettings,
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppEmptyState(
                      icon: Icons.radar,
                      title: strings.emptyRadarTitle,
                      message: strings.emptyRadarSubtitle,
                    ),
                  ],
                ),
              ),
            );
          }

          // Compute KPIs
          final totalInRange = alerts
              .where((a) => a.isAvailableInRange && a.isActive)
              .length;
          // Filter items
          final filtered = alerts.where((a) {
            if (_searchQuery.isNotEmpty) {
              if (!a.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
                return false;
              }
            }
            if (_collectionFilter != null &&
                a.collectionTag != _collectionFilter) {
              return false;
            }
            if (_activeFilters.isNotEmpty &&
                !_activeFilters.any((filter) {
                  switch (filter) {
                    case LigaFilterType.inRange:
                      return a.isAvailableInRange;
                    case LigaFilterType.preSale:
                      return a.isPreSale;
                    case LigaFilterType.active:
                      return a.isActive;
                  }
                })) {
              return false;
            }
            return true;
          }).toList();

          // Apply Sorting
          switch (_sortOption) {
            case LigaRadarSortOption.targetDiff:
              filtered.sort((a, b) {
                final diffA = a.currentLowestPrice != null && a.maxTargetPrice > 0
                    ? (a.maxTargetPrice - a.currentLowestPrice!) / a.maxTargetPrice
                    : -999.0;
                final diffB = b.currentLowestPrice != null && b.maxTargetPrice > 0
                    ? (b.maxTargetPrice - b.currentLowestPrice!) / b.maxTargetPrice
                    : -999.0;
                return diffB.compareTo(diffA);
              });
              break;
            case LigaRadarSortOption.priceAsc:
              filtered.sort((a, b) => (a.currentLowestPrice ?? 999999).compareTo(b.currentLowestPrice ?? 999999));
              break;
            case LigaRadarSortOption.priceDesc:
              filtered.sort((a, b) => (b.currentLowestPrice ?? 0).compareTo(a.currentLowestPrice ?? 0));
              break;
            case LigaRadarSortOption.nameAsc:
              filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
              break;
            case LigaRadarSortOption.newest:
              filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
          }

          // Distinct collections for the dropdown filter
          final collections =
              alerts
                  .map((a) => a.collectionTag)
                  .where((c) => c.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

          final totalPrice = filtered.fold<double>(
            0,
            (sum, a) =>
                sum +
                (a.currentLowestPrice != null && a.currentLowestPrice! > 0
                    ? a.currentLowestPrice!
                    : (a.maxTargetPrice > 0
                        ? a.maxTargetPrice
                        : a.minTargetPrice)),
          );

          final now = DateTime.now();
          final updatedToday = filtered
              .where(
                (a) =>
                    a.lastCheckedAt != null &&
                    a.lastCheckedAt!.year == now.year &&
                    a.lastCheckedAt!.month == now.month &&
                    a.lastCheckedAt!.day == now.day,
              )
              .length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    children: [
                      RadarKpiSummary(
                        totalInRange: totalInRange,
                        totalPrice: totalPrice,
                        updatedToday: updatedToday,
                        totalProducts: filtered.length,
                        isInRangeSelected: _activeFilters.contains(
                          LigaFilterType.inRange,
                        ),
                        isProductsSelected: _activeFilters.contains(
                          LigaFilterType.active,
                        ),
                        onToggleInRange: () =>
                            _toggleFilter(LigaFilterType.inRange),
                        onToggleProducts: () =>
                            _toggleFilter(LigaFilterType.active),
                        isUsd: isUsd,
                        exchangeRate: exchangeRate,
                        strings: strings,
                      ),
                      if (_searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: InputChip(
                              avatar: const Icon(Icons.search, size: 14),
                              label: Text(
                                _searchQuery,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: collections.isEmpty
                              ? const SizedBox.shrink()
                              : _buildFilterDropdown(
                                  value: _collectionFilter,
                                  icon: Icons.style_outlined,
                                  hint: strings.filterByCollection,
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(strings.filterAllCollections),
                                    ),
                                    ...collections.map(
                                      (c) => DropdownMenuItem<String?>(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _collectionFilter = val),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Monitored items list (grid or list, responsive to scale/grid settings)
              if (filtered.isEmpty)
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
                      final alert = filtered[index];
                      final isChecking = _checkingItemIds.contains(alert.id);
                      return Transform.scale(
                        scale: cardScale / 0.85,
                        alignment: Alignment.topCenter,
                        child: _buildAlertCard(
                          theme,
                          strings,
                          alert,
                          isChecking,
                        ),
                      );
                    }, childCount: filtered.length),
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
                    final adjustedAspect = (0.70 * (1.15 / cardScale))
                        .clamp(0.55, 1.10)
                        .toDouble();
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final alert = filtered[index];
                          return _buildAlertGridCard(
                            theme,
                            strings,
                            alert,
                            _checkingItemIds.contains(alert.id),
                            cardScale: cardScale,
                          );
                        }, childCount: filtered.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }

  Widget _buildFilterDropdown({
    required String? value,
    required IconData icon,
    required List<DropdownMenuItem<String?>> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: hint != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
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
                )
              : null,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          items: items.isEmpty ? null : items,
          onChanged: onChanged,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }


  (Color, String) _resolveStatus(
    LigaPriceAlert alert,
    double? price,
    AppStrings strings,
  ) {
    if (alert.isAvailableInRange) {
      return (Colors.green, strings.statusInRange);
    }
    if (price != null && price > 0) {
      if (alert.minTargetPrice > 0 && price < alert.minTargetPrice) {
        return (Colors.blue, strings.statusBelowRange);
      }
      return (Colors.amber.shade800, strings.statusAboveRange);
    }
    return (
      Colors.grey,
      alert.lastCheckedAt == null
          ? strings.statusPending
          : strings.statusOutOfStock,
    );
  }

  Widget _buildAlertGridCard(
    ThemeData theme,
    AppStrings strings,
    LigaPriceAlert alert,
    bool isChecking, {
    required double cardScale,
  }) {
    final price = alert.currentLowestPrice;
    final priceText = (price != null && price > 0)
        ? CurrencyFormatter.toBrl(price)
        : (alert.lastCheckedAt == null
              ? strings.statusPending
              : strings.statusOutOfStock);
    final (statusColor, statusText) = _resolveStatus(alert, price, strings);

    final isGreen = alert.isAvailableInRange;
    final tinted = isGreen || alert.isActive;

    return Card(
      margin: EdgeInsets.zero,
      color: isGreen
          ? Colors.green.withValues(alpha: 0.12)
          : alert.isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : null,
      elevation: tinted ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isGreen
              ? Colors.green
              : alert.isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
          width: tinted ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openEditDialog(alert),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product image filling the available tile space
              Expanded(
                child: Opacity(
                  opacity: alert.isActive ? 1.0 : 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AppNetworkImage(
                      imageUrl: alert.imageUrl,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.circular(10),
                      fallbackIcon: Icons.inventory_2_outlined,
                      fallbackIconSize: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                alert.title,
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
                      color: alert.isAvailableInRange
                          ? Colors.green.withValues(alpha: 0.12)
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: alert.isAvailableInRange
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
                          color: alert.isAvailableInRange
                              ? Colors.green.shade700
                              : (price != null && price > 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Bottom actions: refresh + monitor switch
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
                        : () => _checkSingleItem(alert),
                  ),
                  const Spacer(),
                  Icon(
                    alert.isAvailableInRange
                        ? Icons.check_circle
                        : Icons.notifications_active_outlined,
                    color: alert.isAvailableInRange
                        ? Colors.green
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    ThemeData theme,
    AppStrings strings,
    LigaPriceAlert alert,
    bool isChecking,
  ) {
    final price = alert.currentLowestPrice;
    final priceText = (price != null && price > 0)
        ? CurrencyFormatter.toBrl(price)
        : (alert.lastCheckedAt == null
              ? strings.statusPending
              : strings.statusOutOfStock);
    final minText = alert.minTargetPrice > 0
        ? CurrencyFormatter.toBrl(alert.minTargetPrice)
        : 'R\$ 0';
    final maxText = alert.maxTargetPrice > 0
        ? CurrencyFormatter.toBrl(alert.maxTargetPrice)
        : strings.noPriceCeiling;
    final storeName = alert.currentStoreName.isNotEmpty
        ? alert.currentStoreName
        : (price != null && price > 0
              ? strings.marketplaceFallback
              : strings.statusOutOfStock);

    final (statusColor, statusText) = _resolveStatus(alert, price, strings);
    final isGreen = alert.isAvailableInRange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isGreen ? Colors.green.withValues(alpha: 0.12) : null,
      elevation: isGreen ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isGreen
              ? Colors.green
              : theme.colorScheme.outlineVariant,
          width: isGreen ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image stays to the left of the product information.
            SizedBox(
              width: 92,
              height: 124,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppNetworkImage(
                  imageUrl: alert.imageUrl,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(14),
                  fallbackIcon: Icons.inventory_2_outlined,
                  fallbackIconSize: 44,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Last checked: above the name in the information column
                  Text(
                    alert.lastCheckedAt != null
                        ? '${strings.lastCheckedPrefix}${alert.lastCheckedAt!.hour.toString().padLeft(2, '0')}:${alert.lastCheckedAt!.minute.toString().padLeft(2, '0')}'
                        : '${strings.lastCheckedPrefix}${strings.neverChecked}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Name below the image
                  Text(
                    alert.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badges: status / pre-sale / allow pre-sale / collection / language
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Status Badge
                      RangeStatusBadge(
                        color: statusColor,
                        text: statusText,
                        compact: true,
                      ),

                      // Pre-Sale Indicator if current offer is pre-sale
                      if (alert.isPreSale)
                        PreSaleStatusBadge(
                          label: strings.statusPreSale.toUpperCase(),
                          compact: true,
                        ),

                      // Allow Pre-Sale Tag
                      if (alert.allowPreSale && !alert.isPreSale)
                        PreSaleAcceptedBadge(
                          label: strings.preSaleAcceptedTag,
                          compact: true,
                        ),

                      // Collection tag
                      if (alert.collectionTag.isNotEmpty)
                        CollectionTagBadge(
                          name: alert.collectionTag,
                          compact: true,
                        ),

                      // Language tag
                      if (alert.languageTag.isNotEmpty)
                        LanguageFlagBadge(
                          language: alert.languageTag,
                          compact: true,
                          showCode: true,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price & Store Monitoring Section (Barra de Destaque do Preço & Loja)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: alert.isAvailableInRange
                          ? Colors.green.withValues(alpha: 0.12)
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: alert.isAvailableInRange
                            ? Colors.green.withValues(alpha: 0.4)
                            : theme.colorScheme.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                      ),
                    ),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Lowest Price Column
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.price_check,
                                          size: 14,
                                          color: alert.isAvailableInRange
                                              ? Colors.green.shade700
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            strings.currentLowestPriceHeader,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.4,
                                              color: alert.isAvailableInRange
                                                  ? Colors.green.shade700
                                                  : theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        priceText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                          color: alert.isAvailableInRange
                                              ? Colors.green.shade700
                                              : (price != null && price > 0
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.6),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                              ),
                              // Store Name Column
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storefront_outlined,
                                          size: 14,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            strings.storeSellerHeader,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.4,
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface
                                            .withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: theme
                                              .colorScheme
                                              .outlineVariant
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      child: Text(
                                        storeName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Target range footer
                        Row(
                          children: [
                            Icon(
                              Icons.tune,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              strings.targetRangeLabelText,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '$minText - $maxText',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bottom Actions Bar (item actions)
                  Row(
                    children: [
                      const Spacer(),

                      // Check single item now button
                      IconButton(
                        icon: isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 20),
                        tooltip: strings.refreshTooltip,
                        onPressed: isChecking
                            ? null
                            : () => _checkSingleItem(alert),
                      ),

                      // Open in Liga button (now white)
                      IconButton(
                        icon: const Icon(
                          Icons.open_in_new,
                          size: 20,
                          color: Colors.white,
                        ),
                        tooltip: strings.openInLiga,
                        onPressed: () => _openExternalLiga(alert.targetUrl),
                      ),

                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: strings.isEn ? 'Edit' : 'Editar',
                        onPressed: () => _openEditDialog(alert),
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        tooltip: strings.remove,
                        onPressed: () => _confirmDelete(alert),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
