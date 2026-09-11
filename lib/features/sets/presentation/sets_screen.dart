import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../models/tcg_set_item.dart';
import '../services/set_completion_helper.dart';
import '../services/tcg_sets_service.dart';
import '../../../core/navigation/app_navigator.dart';
import 'widgets/set_card_widget.dart';
import 'widgets/set_list_tile.dart';

class SetsScreen extends ConsumerStatefulWidget {
  const SetsScreen({super.key});

  @override
  ConsumerState<SetsScreen> createState() => _SetsScreenState();
}

class _SetsScreenState extends ConsumerState<SetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<TcgSetItem> _allSets = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedYear; // null = all years
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
    return _allSets.where((s) {
      if (s.isUpcoming) return false;
      if (_selectedYear != null && s.year != _selectedYear) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        return s.name.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<TcgSetItem> _getFilteredUpcomingSets() {
    return _allSets.where((s) {
      if (!s.isUpcoming) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        return s.name.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
      }
      return true;
    }).toList();
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
        title: Text(
          strings.setsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
          AppOverflowMenu(
            scaleTarget: CardScaleTarget.menu,
            showCurrency: true,
            showRefresh: true,
            onRefresh: _loadSets,
          ),
          const SizedBox(width: 4),
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
    final availableYears = _getAvailableYears();

    return Column(
      children: [
        // Search Bar (DRY)
        AppSearchBar(
          controller: _searchController,
          hintText: strings.searchSetsPlaceholder,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),

        // Year Filter Dropdown (")
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedYear,
                  isDense: true,
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                  hint: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        strings.txtAllYears,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            size: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(strings.txtAllYears),
                        ],
                      ),
                    ),
                    for (final year in availableYears)
                      DropdownMenuItem<int?>(
                        value: year,
                        child: Text('$year'),
                      ),
                  ],
                  onChanged: (val) => setState(() => _selectedYear = val),
                ),
              ),
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

    return upcomingSets.isEmpty
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
                    );
  }
}
