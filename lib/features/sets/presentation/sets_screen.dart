import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/quick_currency_toggle.dart';
import '../models/tcg_set_item.dart';
import '../services/set_completion_helper.dart';
import '../services/tcg_sets_service.dart';
import '../../../core/navigation/app_navigator.dart';
import 'widgets/set_card_widget.dart';

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

  int _calculateSetGridColumns(double width) {
    return width > 1100
        ? 5
        : width > 800
            ? 4
            : width > 550
                ? 3
                : 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLanguage = ref.watch(languageProvider);
    final strings = getStrings(currentLanguage);
    final userCards = ref.watch(userCardsStreamProvider).asData?.value ?? [];

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
          // Quick Currency Switcher (USD / BRL)
          const QuickCurrencyToggle(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.btnTryAgain,
            onPressed: _loadSets,
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
                    _buildReleasedTab(theme, colorScheme, strings, userCards),

                    // Tab 2: Upcoming releases
                    _buildUpcomingTab(theme, colorScheme, strings, userCards),
                  ],
                ),
    );
  }

  Widget _buildReleasedTab(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings strings,
    List<UserCard> userCards,
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

        // Year Filter Chips ("elas sao separadas por ano")
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: availableYears.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = _selectedYear == null;
                return FilterChip(
                  label: Text(strings.txtAllYears),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedYear = null);
                  },
                  visualDensity: VisualDensity.compact,
                );
              }

              final year = availableYears[index - 1];
              final isSelected = _selectedYear == year;

              return FilterChip(
                label: Text('$year'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedYear = selected ? year : null;
                  });
                },
                visualDensity: VisualDensity.compact,
              );
            },
          ),
        ),

        const SizedBox(height: 6),

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
                                '${setsForYear.length} ${setsForYear.length == 1 ? "coleção" : "coleções"}',
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

                      // Responsive Grid of Sets for this year
                      SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = _calculateSetGridColumns(constraints.crossAxisExtent);

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.95,
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
  ) {
    final upcomingSets = _getFilteredUpcomingSets();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: colorScheme.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Futuros Lançamentos Oficiais Pokémon TCG (2025 - 2026)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondaryContainer,
                    ),
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _calculateSetGridColumns(constraints.maxWidth);

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.95,
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
