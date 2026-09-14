import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/widgets/app_action_fab.dart';
import '../../../core/widgets/app_filter_modal.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_screen_title.dart';
import '../../../core/widgets/app_search_dialog.dart';
import '../../../core/widgets/app_sort_button.dart';
import '../../../core/navigation/app_navigator.dart';
import '../data/pokedex_data.dart';
import '../models/pokedex_entry.dart';
import 'widgets/pokemon_grid_card.dart';
import 'widgets/pokemon_list_item.dart';

enum PokedexSortOption {
  numberAsc,
  numberDesc,
  nameAsc,
  nameDesc,
}

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  int _selectedGeneration = 0; // 0 = All
  String? _selectedType;
  String _searchQuery = '';
  PokedexSortOption _sortOption = PokedexSortOption.numberAsc;

  int get _activeFilterCount =>
      (_selectedGeneration > 0 ? 1 : 0) + (_selectedType != null ? 1 : 0);

  void _clearFilters() {
    setState(() {
      _selectedGeneration = 0;
      _selectedType = null;
    });
  }

  @override
  void initState() {
    super.initState();
    PokedexData.refresh().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _showSearchDialog(AppStrings strings) async {
    final query = await AppSearchDialog.show(
      context,
      initialQuery: _searchQuery,
      hintText: strings.pokedexSearchHint,
      strings: strings,
      suggestions: const ['Pikachu', 'Charizard', 'Mewtwo', 'Gengar', 'Eevee', 'Lucario'],
    );
    if (query != null && mounted) {
      setState(() => _searchQuery = query.trim());
    }
  }

  void _showFilterDialog(AppStrings strings, int maxGeneration) {
    int tempGen = _selectedGeneration;
    String? tempType = _selectedType;

    const pokemonTypes = [
      'Normal', 'Fire', 'Water', 'Grass', 'Electric', 'Ice',
      'Fighting', 'Poison', 'Ground', 'Flying', 'Psychic', 'Bug',
      'Rock', 'Ghost', 'Dark', 'Dragon', 'Steel', 'Fairy'
    ];

    AppFilterModalDialog.show(
      context: context,
      title: strings.filtersAndMore,
      hasActiveFilters: _activeFilterCount > 0,
      strings: strings,
      onClear: _clearFilters,
      onApply: () {
        setState(() {
          _selectedGeneration = tempGen;
          _selectedType = tempType;
        });
      },
      children: [
        StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.isEn ? 'Generation' : 'Geração',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(strings.pokedexAllGens),
                      selected: tempGen == 0,
                      onSelected: (_) => setDialogState(() => tempGen = 0),
                    ),
                    for (int i = 1; i <= maxGeneration; i++)
                      FilterChip(
                        label: Text(strings.pokedexGen(i)),
                        selected: tempGen == i,
                        onSelected: (selected) {
                          setDialogState(() => tempGen = selected ? i : 0);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  strings.isEn ? 'Pokémon Type' : 'Tipo do Pokémon',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pokemonTypes.map((type) {
                    final isSelected = tempType == type;
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() => tempType = selected ? type : null);
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<PokedexEntry> _getFilteredEntries() {
    final filtered = PokedexData.resolved.where((entry) {
      if (_selectedGeneration > 0 && entry.generation != _selectedGeneration) {
        return false;
      }
      if (_selectedType != null &&
          !entry.types.any((t) => t.toLowerCase() == _selectedType!.toLowerCase())) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchesName = entry.name.toLowerCase().contains(query);
        final matchesNumber = entry.id.toString() == query ||
            entry.formattedNumber.toLowerCase().contains(query);
        final matchesType = entry.types.any((t) => t.toLowerCase().contains(query));
        if (!matchesName && !matchesNumber && !matchesType) {
          return false;
        }
      }
      return true;
    }).toList();

    switch (_sortOption) {
      case PokedexSortOption.numberAsc:
        filtered.sort((a, b) => a.id.compareTo(b.id));
        break;
      case PokedexSortOption.numberDesc:
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case PokedexSortOption.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PokedexSortOption.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLanguage = ref.watch(languageProvider);
    final strings = getStrings(currentLanguage);

    final filteredEntries = _getFilteredEntries();

    final maxGeneration = PokedexData.resolved.fold<int>(
      1,
      (acc, e) => e.generation > acc ? e.generation : acc,
    );

    final cardScale = ref.watch(menuCardScaleProvider);
    ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppScreenTitle(title: strings.pokedexTitle),
        actions: [
          AppFilterButton(
            activeFilterCount: _activeFilterCount,
            tooltip: strings.filtersAndMore,
            isFilledTonal: false,
            onPressed: () => _showFilterDialog(strings, maxGeneration),
          ),
          AppSortButton<PokedexSortOption>(
            currentOption: _sortOption,
            isCompact: true,
            tooltip: strings.isEn ? 'Sort Pokédex' : 'Ordenar Pokédex',
            onSelected: (val) => setState(() => _sortOption = val),
            options: [
              SortOptionItem(
                value: PokedexSortOption.numberAsc,
                label: strings.isEn ? 'Number (#1 → #1025)' : 'Número (#1 → #1025)',
                icon: Icons.tag,
              ),
              SortOptionItem(
                value: PokedexSortOption.numberDesc,
                label: strings.isEn ? 'Number (#1025 → #1)' : 'Número (#1025 → #1)',
                icon: Icons.tag,
              ),
              SortOptionItem(
                value: PokedexSortOption.nameAsc,
                label: strings.isEn ? 'Name (A → Z)' : 'Nome (A → Z)',
                icon: Icons.sort_by_alpha,
              ),
              SortOptionItem(
                value: PokedexSortOption.nameDesc,
                label: strings.isEn ? 'Name (Z → A)' : 'Nome (Z → A)',
                icon: Icons.sort_by_alpha,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refreshTooltip,
            onPressed: () {
              setState(() {});
              ref.read(exchangeRateProvider.notifier).refreshRate();
            },
          ),
          const AppOverflowMenu(showCurrency: true, scaleTarget: CardScaleTarget.menu),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: AppActionFab(
        tooltip: strings.searchActionTitle,
        sheetTitle: strings.pokedexTitle,
        actions: [
          AppFabAction(
            icon: Icons.search,
            title: strings.searchActionTitle,
            subtitle: strings.pokedexSearchHint,
            onTap: () => _showSearchDialog(strings),
          ),
          AppFabAction(
            icon: Icons.casino_outlined,
            title: strings.isEn ? 'Random Pokémon' : 'Pokémon Aleatório',
            subtitle: strings.isEn ? 'Surprise discovery' : 'Descobrir Pokémon',
            onTap: () {
              final randomId = (1 + math.Random().nextInt(1025));
              setState(() => _searchQuery = '$randomId');
            },
          ),
          if (_searchQuery.isNotEmpty || _selectedGeneration != 0 || _selectedType != null)
            AppFabAction(
              icon: Icons.clear_all,
              title: strings.btnClearFilters,
              subtitle: strings.reset,
              isDestructive: true,
              onTap: _clearFilters,
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Active search and filter chips bar
          if (_searchQuery.isNotEmpty || _activeFilterCount > 0)
            SliverToBoxAdapter(
              child: Padding(
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
                      if (_selectedGeneration > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text(strings.pokedexGen(_selectedGeneration), style: const TextStyle(fontSize: 12)),
                            onDeleted: () => setState(() => _selectedGeneration = 0),
                          ),
                        ),
                      if (_selectedType != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InputChip(
                            label: Text(_selectedType!, style: const TextStyle(fontSize: 12)),
                            onDeleted: () => setState(() => _selectedType = null),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Pokémon Grid (3x3 on mobile, responsive on wider screens)
          if (filteredEntries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          Icon(
                            Icons.catching_pokemon,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(strings.noCardsFound, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            )
          else if (viewMode == CardViewMode.list)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverList.separated(
                itemCount: filteredEntries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final pokemon = filteredEntries[index];
                  return PokemonListItem(
                    pokemon: pokemon,
                    onTap: () => AppNavigator.toPokemonGallery(context, pokemon: pokemon),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = resolveCardGridCrossAxisCount(
                    context: context,
                    ref: ref,
                    availableWidth: constraints.crossAxisExtent,
                  );

                  final adjustedAspect =
                          (0.85 * (1.15 / cardScale)).clamp(0.6, 1.4).toDouble();

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: adjustedAspect,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                              final pokemon = filteredEntries[index];
                              return PokemonGridCard(
                                pokemon: pokemon,
                                onTap: () => AppNavigator.toPokemonGallery(context, pokemon: pokemon),
                              );
                    }, childCount: filteredEntries.length),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
