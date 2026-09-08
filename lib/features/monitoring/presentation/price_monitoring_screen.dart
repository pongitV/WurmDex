import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/app_sort_button.dart';
import '../../../../core/widgets/quick_currency_toggle.dart';
import '../models/monitored_card_item.dart';
import '../services/price_monitoring_service.dart';
import 'widgets/monitored_card_tile.dart';
import 'widgets/monitoring_collection_selector.dart';
import 'widgets/monitoring_kpi_card.dart';

enum MonitoringSortOption {
  gainPct,
  gainNominal,
  biggestLoss,
  highestValue,
  recentlyAdded,
}

enum MonitoringTrendFilter {
  all,
  surging,
  dropping,
  stable,
}

class PriceMonitoringScreen extends ConsumerStatefulWidget {
  const PriceMonitoringScreen({super.key});

  @override
  ConsumerState<PriceMonitoringScreen> createState() => _PriceMonitoringScreenState();
}

class _PriceMonitoringScreenState extends ConsumerState<PriceMonitoringScreen> {
  String? _selectedFolderId; // null = all, '__general__' = no folder, or folderId
  MonitoringTrendFilter _trendFilter = MonitoringTrendFilter.all;
  MonitoringSortOption _sortOption = MonitoringSortOption.gainPct;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final currency = ref.watch(currencyProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);

    final allCardsAsync = ref.watch(userCardsStreamProvider);
    final foldersAsync = ref.watch(foldersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.monitoringTabTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              strings.monitoringTabSubtitle,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
            tooltip: strings.searchMonitoredHint,
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          AppSortButton<MonitoringSortOption>(
            currentOption: _sortOption,
            isCompact: true,
            tooltip: strings.sortingMenuTooltip,
            onSelected: (opt) => setState(() => _sortOption = opt),
            options: [
              SortOptionItem(
                value: MonitoringSortOption.gainPct,
                label: strings.sortGainPct,
                icon: Icons.trending_up,
              ),
              SortOptionItem(
                value: MonitoringSortOption.gainNominal,
                label: strings.sortGainNominal,
                icon: Icons.attach_money,
              ),
              SortOptionItem(
                value: MonitoringSortOption.biggestLoss,
                label: strings.sortLoss,
                icon: Icons.trending_down,
              ),
              SortOptionItem(
                value: MonitoringSortOption.highestValue,
                label: strings.sortCurrentValue,
                icon: Icons.account_balance_wallet_outlined,
              ),
              SortOptionItem(
                value: MonitoringSortOption.recentlyAdded,
                label: strings.sortRecentlyAdded,
                icon: Icons.schedule,
              ),
            ],
          ),
          const QuickCurrencyToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: allCardsAsync.when(
        data: (allCards) {
          return foldersAsync.when(
            data: (folders) {
              if (allCards.isEmpty) {
                return _buildEmptyState(context, strings, theme);
              }

              // Pre-calculate card counts by folder for badges
              final Map<String?, int> countsByFolder = {};
              for (final c in allCards) {
                countsByFolder[c.folderId] = (countsByFolder[c.folderId] ?? 0) + 1;
              }

              // Filter cards by selected folder
              final List<UserCard> folderFilteredCards;
              if (_selectedFolderId == null) {
                folderFilteredCards = allCards;
              } else if (_selectedFolderId == '__general__') {
                folderFilteredCards = allCards.where((c) => c.folderId == null).toList();
              } else {
                folderFilteredCards = allCards.where((c) => c.folderId == _selectedFolderId).toList();
              }

              // Generate enriched monitored card items
              final monitoredItems = PriceMonitoringService.generateMonitoredItems(
                cards: folderFilteredCards,
                folders: folders,
              );

              // Calculate overall collection KPI stats
              double collectionInvestedBrl = 0.0;
              double collectionCurrentValBrl = 0.0;
              int surgingCount = 0;
              int droppingCount = 0;

              for (final item in monitoredItems) {
                final qty = item.card.quantity;
                collectionInvestedBrl += (item.purchasePriceBrl * qty);
                collectionCurrentValBrl += (item.estimatedCurrentPriceBrl * qty);
                if (item.isSurging) surgingCount += qty;
                if (item.isDropping) droppingCount += qty;
              }

              // Apply trend & search filters
              List<MonitoredCardItem> displayItems = monitoredItems.where((item) {
                // Trend filter
                if (_trendFilter == MonitoringTrendFilter.surging && !item.isSurging) return false;
                if (_trendFilter == MonitoringTrendFilter.dropping && !item.isDropping) return false;
                if (_trendFilter == MonitoringTrendFilter.stable && !item.isStable) return false;

                // Search query
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  final matchesName = item.card.name.toLowerCase().contains(q);
                  final matchesNum = item.card.number.toLowerCase().contains(q);
                  final matchesSet = item.card.setName.toLowerCase().contains(q);
                  if (!matchesName && !matchesNum && !matchesSet) return false;
                }

                return true;
              }).toList();

              // Sort
              displayItems.sort((a, b) {
                switch (_sortOption) {
                  case MonitoringSortOption.gainPct:
                    return b.percentageChange.compareTo(a.percentageChange);
                  case MonitoringSortOption.gainNominal:
                    return b.nominalDifferenceBrl.compareTo(a.nominalDifferenceBrl);
                  case MonitoringSortOption.biggestLoss:
                    return a.percentageChange.compareTo(b.percentageChange);
                  case MonitoringSortOption.highestValue:
                    return b.estimatedCurrentPriceBrl.compareTo(a.estimatedCurrentPriceBrl);
                  case MonitoringSortOption.recentlyAdded:
                    return b.card.createdAt.compareTo(a.card.createdAt);
                }
              });

              return Column(
                children: [
                  // 1. Horizontal Collection Selector (Por Coleção)
                  MonitoringCollectionSelector(
                    folders: folders,
                    selectedFolderId: _selectedFolderId,
                    onFolderSelected: (folderId) => setState(() => _selectedFolderId = folderId),
                    strings: strings,
                    cardCountsByFolder: countsByFolder,
                  ),                  // 2. Search Field (Collapsible)
                  if (_isSearchVisible)
                    AppSearchBar(
                      controller: _searchController,
                      autofocus: true,
                      hintText: strings.searchMonitoredHint,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      onClear: () => setState(() => _searchQuery = ''),
                    ),

                  // 3. Collection KPI Performance Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: MonitoringKpiCard(
                      totalInvestedBrl: collectionInvestedBrl,
                      totalCurrentValueBrl: collectionCurrentValBrl,
                      exchangeRate: exchangeRate,
                      currency: currency,
                      strings: strings,
                      totalCards: monitoredItems.length,
                      surgingCount: surgingCount,
                      droppingCount: droppingCount,
                    ),
                  ),

                  // 4. Trend Filter Pills (Todas, Em Alta, Em Baixa, Estáveis)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        _buildTrendPill(
                          label: strings.filterAllTrend,
                          filter: MonitoringTrendFilter.all,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        _buildTrendPill(
                          label: strings.filterGainers,
                          filter: MonitoringTrendFilter.surging,
                          color: AppColors.profitGreen,
                        ),
                        const SizedBox(width: 6),
                        _buildTrendPill(
                          label: strings.filterLosers,
                          filter: MonitoringTrendFilter.dropping,
                          color: AppColors.lossRed,
                        ),
                        const SizedBox(width: 6),
                        _buildTrendPill(
                          label: strings.filterStableTrend,
                          filter: MonitoringTrendFilter.stable,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ),

                  // 5. Monitored Cards List
                  Expanded(
                    child: displayItems.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.filter_list_off,
                                    size: 48,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    strings.noMonitoredCardsFound,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: displayItems.length,
                            itemBuilder: (context, index) {
                              final item = displayItems[index];
                              return MonitoredCardTile(
                                item: item,
                                exchangeRate: exchangeRate,
                                currency: currency,
                                strings: strings,
                                showFolderTag: _selectedFolderId == null,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(strings.errorLoadingWithMsg(err))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(strings.errorLoadingWithMsg(err))),
      ),
    );
  }

  Widget _buildTrendPill({
    required String label,
    required MonitoringTrendFilter filter,
    required Color color,
  }) {
    final isSelected = _trendFilter == filter;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _trendFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppStrings strings, ThemeData theme) {
    return AppEmptyState(
      icon: Icons.trending_up,
      iconSize: 64,
      title: strings.portfolioActiveMonitoring,
      message: strings.portfolioMonitoringSubtitle,
    );
  }
}
