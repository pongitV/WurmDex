import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/widgets/app_action_fab.dart';
import '../../../core/widgets/app_filter_modal.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_screen_title.dart';
import '../../../core/widgets/app_search_dialog.dart';
import '../../../core/widgets/app_sort_button.dart';
import '../models/tcg_set_item.dart';
import '../services/set_completion_helper.dart';
import '../services/tcg_sets_service.dart';
import '../../../core/navigation/app_navigator.dart';
import 'widgets/set_card_widget.dart';
import 'widgets/set_list_tile.dart';

enum SetsSortOption {
  releaseDateDesc,
  releaseDateAsc,
  nameAsc,
  nameDesc,
  cardCountDesc,
}

class SetsScreen extends ConsumerStatefulWidget {
  const SetsScreen({super.key});

  @override
  ConsumerState<SetsScreen> createState() => _SetsScreenState();
}

class _SetsScreenState extends ConsumerState<SetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TcgSetItem> _allSets = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedYear; // null = all years
  String? _selectedSeries;
  String _searchQuery = '';
  SetsSortOption _sortOption = SetsSortOption.releaseDateDesc;

  int get _activeFilterCount =>
      (_selectedYear != null ? 1 : 0) + (_selectedSeries != null ? 1 : 0);

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedSeries = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showSearchDialog(AppStrings strings) async {
    final suggestions = _allSets.take(8).map((s) => s.name).toList();
    final query = await AppSearchDialog.show(
      context,
      initialQuery: _searchQuery,
      hintText: strings.searchSetsPlaceholder,
      strings: strings,
      suggestions: suggestions,
    );
    if (query != null && mounted) {
      setState(() => _searchQuery = query.trim());
    }
  }

  void _showFilterDialog(AppStrings strings) {
    int? tempYear = _selectedYear;
    String? tempSeries = _selectedSeries;
    final availableYears = _getAvailableYears();
    final availableSeries = _allSets
        .map((s) => s.serieName)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    AppFilterModalDialog.show(
      context: context,
      title: strings.filtersAndMore,
      hasActiveFilters: _activeFilterCount > 0,
      strings: strings,
      onClear: _clearFilters,
      onApply: () {
        setState(() {
          _selectedYear = tempYear;
          _selectedSeries = tempSeries;
        });
      },
      children: [
        StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (availableSeries.isNotEmpty) ...[
                  Text(
                    strings.isEn ? 'Series / Era' : 'Série / Era',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSeries.map((series) {
                      final isSelected = tempSeries == series;
                      return FilterChip(
                        label: Text(series),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() => tempSeries = selected ? series : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  strings.isEn ? 'Release Year' : 'Ano de Lançamento',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(strings.txtAllYears),
                      selected: tempYear == null,
                      onSelected: (_) => setDialogState(() => tempYear = null),
                    ),
                    for (final year in availableYears)
                      FilterChip(
                        label: Text('$year'),
                        selected: tempYear == year,
                        onSelected: (selected) {
                          setDialogState(() => tempYear = selected ? year : null);
                        },
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

  Future<void> _loadSets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sets = await TcgSetsService.fetchAllSets();
      if (mounted) {
        setState(() {
          _allSets = sets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<TcgSetItem> _getFilteredReleasedSets() {
    final list = _allSets.where((s) {
      if (s.isUpcoming) return false;
      if (_selectedYear != null && s.year != _selectedYear) return false;
      if (_selectedSeries != null && s.serieName != _selectedSeries) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        return s.name.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_sortOption) {
      case SetsSortOption.releaseDateDesc:
        list.sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
        break;
      case SetsSortOption.releaseDateAsc:
        list.sort((a, b) => (a.releaseDate ?? '').compareTo(b.releaseDate ?? ''));
        break;
      case SetsSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SetsSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SetsSortOption.cardCountDesc:
        list.sort((a, b) => b.totalCards.compareTo(a.totalCards));
        break;
    }
    return list;
  }

  List<TcgSetItem> _getFilteredUpcomingSets() {
    final list = _allSets.where((s) {
      if (!s.isUpcoming) return false;
      if (_selectedYear != null && s.year != _selectedYear) return false;
      if (_selectedSeries != null && s.serieName != _selectedSeries) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        return s.name.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_sortOption) {
      case SetsSortOption.releaseDateDesc:
        list.sort((a, b) => (b.releaseDate ?? '').compareTo(a.releaseDate ?? ''));
        break;
      case SetsSortOption.releaseDateAsc:
        list.sort((a, b) => (a.releaseDate ?? '').compareTo(b.releaseDate ?? ''));
        break;
      case SetsSortOption.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SetsSortOption.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SetsSortOption.cardCountDesc:
        list.sort((a, b) => b.totalCards.compareTo(a.totalCards));
        break;
    }
    return list;
  }

  Map<int, List<TcgSetItem>> _groupByYear(List<TcgSetItem> sets) {
    final Map<int, List<TcgSetItem>> map = {};
    for (final s in sets) {
      map.putIfAbsent(s.year, () => []).add(s);
    }
    return map;
  }

  List<int> _getAvailableYears() {
    final years = _allSets
        .where((s) => !s.isUpcoming)
        .map((s) => s.year)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLanguage = ref.watch(languageProvider);
    final strings = getStrings(currentLanguage);
    final userCards = ref.watch(userCardsStreamProvider).asData?.value ?? [];

    // Watch during build so the grids respond to scale/grid changes.
    final menuCardScale = ref.watch(menuCardScaleProvider);
    ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: strings.setsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.collections_bookmark_outlined),
              text: strings.tabReleasedSets,
            ),
            Tab(
              icon: const Icon(Icons.rocket_launch_outlined),
              text: strings.tabUpcomingReleases,
            ),
          ],
        ),
        actions: [
          AppFilterButton(
            activeFilterCount: _activeFilterCount,
            tooltip: strings.filtersAndMore,
            isFilledTonal: false,
            onPressed: () => _showFilterDialog(strings),
          ),
          AppSortButton<SetsSortOption>(
            currentOption: _sortOption,
            isCompact: true,
            tooltip: strings.isEn ? 'Sort Sets' : 'Ordenar Expansões',
            onSelected: (val) => setState(() => _sortOption = val),
            options: [
              SortOptionItem(
                value: SetsSortOption.releaseDateDesc,
                label: strings.isEn ? 'Newest Release' : 'Mais Recentes',
                icon: Icons.calendar_today,
              ),
              SortOptionItem(
                value: SetsSortOption.releaseDateAsc,
                label: strings.isEn ? 'Oldest Release' : 'Mais Antigos',
                icon: Icons.history,
              ),
              SortOptionItem(
                value: SetsSortOption.nameAsc,
                label: strings.isEn ? 'Name (A → Z)' : 'Nome (A → Z)',
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: SetsSortOption.nameDesc,
                label: strings.isEn ? 'Name (Z → A)' : 'Nome (Z → A)',
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: SetsSortOption.cardCountDesc,
                label: strings.isEn ? 'Total Cards' : 'Total de Cartas',
                icon: Icons.layers,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: _loadSets,
          ),
          const AppOverflowMenu(
            scaleTarget: CardScaleTarget.menu,
            showCurrency: true,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: AppActionFab(
        tooltip: strings.searchActionTitle,
        sheetTitle: strings.setsTitle,
        actions: [
          AppFabAction(
            icon: Icons.search,
            title: strings.searchActionTitle,
            subtitle: strings.searchSetsPlaceholder,
            onTap: () => _showSearchDialog(strings),
          ),
          AppFabAction(
            icon: _tabController.index == 0
                ? Icons.rocket_launch_outlined
                : Icons.collections_bookmark_outlined,
            title: _tabController.index == 0
                ? strings.tabUpcomingReleases
                : strings.tabReleasedSets,
            subtitle: strings.setsTitle,
            onTap: () => setState(() => _tabController.index = _tabController.index == 0 ? 1 : 0),
          ),
          if (_searchQuery.isNotEmpty || _selectedYear != null || _selectedSeries != null)
            AppFabAction(
              icon: Icons.clear_all,
              title: strings.btnClearFilters,
              subtitle: strings.reset,
              isDestructive: true,
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _selectedYear = null;
                  _selectedSeries = null;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '${strings.loadingCatalog}...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(strings.errorLoadingNews, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _loadSets,
                        icon: const Icon(Icons.refresh),
                        label: Text(strings.btnTryAgain),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Released sets separated by year
                    _buildReleasedTab(theme, colorScheme, strings, userCards, menuCardScale, viewMode),

                    // Tab 2: Upcoming releases
                    _buildUpcomingTab(theme, colorScheme, strings, userCards, menuCardScale, viewMode),
                  ],
                ),
    );
  }

  Widget _buildReleasedTab(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
    List<UserCard> userCards,
    double menuCardScale,
    CardViewMode viewMode,
  ) {
    final releasedSets = _getFilteredReleasedSets();
    final groupedByYear = _groupByYear(releasedSets);
    final sortedYears = groupedByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // Active search and filter chips bar (compact, dismissible)
        if (_searchQuery.isNotEmpty || _activeFilterCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        avatar: const Icon(Icons.search, size: 14),
                        label: Text(_searchQuery, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _searchQuery = ''),
                      ),
                    ),
                  if (_selectedSeries != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text(_selectedSeries!, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _selectedSeries = null),
                      ),
                    ),
                  if (_selectedYear != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text('$_selectedYear', style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _selectedYear = null),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Sets list grouped/separated by year
        Expanded(
          child: releasedSets.isEmpty
              ? Center(
                  child: Text(
                    strings.noCardsFound,
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  child: CustomScrollView(
                    slivers: sortedYears.expand((year) {
                    final setsForYear = groupedByYear[year]!;

                    return [
                      // Year Header Banner ("separadas por ano")
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$year',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                strings.setsCount(setsForYear.length),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Responsive Grid or List of Sets for this year
                      SliverLayoutBuilder(
                        builder: (context, constraints) {
                          if (viewMode == CardViewMode.list) {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final set = setsForYear[index];
                                  final ownedCount = SetCompletionHelper.getOwnedDistinctCount(userCards, set);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SetListTile(
                                      set: set,
                                      ownedCount: ownedCount,
                                      onTap: () => AppNavigator.toSet(context, set: set),
                                    ),
                                  );
                                },
                                childCount: setsForYear.length,
                              ),
                            );
                          }

                          final crossAxisCount = resolveCardGridCrossAxisCount(
                            context: context,
                            ref: ref,
                            availableWidth: constraints.crossAxisExtent,
                            cardScale: menuCardScale,
                          );

                          // Scale grows the whole tile so the change is visible
                          // even when the column count stays the same on small widths.
                          final adjustedAspect =
                              (0.95 * (1.15 / menuCardScale)).clamp(0.6, 1.4).toDouble();

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: adjustedAspect,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final set = setsForYear[index];
                                final ownedCount = SetCompletionHelper.getOwnedDistinctCount(userCards, set);
                                return SetCardWidget(
                                  set: set,
                                  ownedCount: ownedCount,
                                  isEn: strings.isEn,
                                  onTap: () => AppNavigator.toSet(context, set: set),
                                );
                              },
                              childCount: setsForYear.length,
                            ),
                          );
                        },
                      ),
                    ];
                  }).toList(),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTab(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
    List<UserCard> userCards,
    double menuCardScale,
    CardViewMode viewMode,
  ) {
    final upcomingSets = _getFilteredUpcomingSets();

    return Column(
      children: [
        if (_searchQuery.isNotEmpty || _activeFilterCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        avatar: const Icon(Icons.search, size: 14),
                        label: Text(_searchQuery, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _searchQuery = ''),
                      ),
                    ),
                  if (_selectedSeries != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text(_selectedSeries!, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _selectedSeries = null),
                      ),
                    ),
                  if (_selectedYear != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InputChip(
                        label: Text('$_selectedYear', style: const TextStyle(fontSize: 12)),
                        onDeleted: () => setState(() => _selectedYear = null),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Expanded(
          child: upcomingSets.isEmpty
              ? Center(
                  child: Text(
                    strings.noCardsFound,
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : viewMode == CardViewMode.list
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: upcomingSets.length,
                      itemBuilder: (context, index) {
                        final set = upcomingSets[index];
                        final ownedCount = SetCompletionHelper.getOwnedDistinctCount(userCards, set);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SetListTile(
                            set: set,
                            ownedCount: ownedCount,
                            onTap: () => AppNavigator.toSet(context, set: set),
                          ),
                        );
                      },
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = resolveCardGridCrossAxisCount(
                          context: context,
                          ref: ref,
                          availableWidth: constraints.maxWidth,
                          cardScale: menuCardScale,
                        );

                        final adjustedAspect =
                            (0.95 * (1.15 / menuCardScale)).clamp(0.6, 1.4).toDouble();

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: adjustedAspect,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: upcomingSets.length,
                          itemBuilder: (context, index) {
                            final set = upcomingSets[index];
                            final ownedCount = SetCompletionHelper.getOwnedDistinctCount(userCards, set);
                            return SetCardWidget(
                              set: set,
                              ownedCount: ownedCount,
                              isEn: strings.isEn,
                              onTap: () => AppNavigator.toSet(context, set: set),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
