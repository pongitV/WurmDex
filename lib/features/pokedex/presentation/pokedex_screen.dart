import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/providers/card_scale_provider.dart';
import '../../../core/providers/card_view_mode_provider.dart';
import '../../../core/providers/grid_composition_provider.dart';
import '../../../core/widgets/app_overflow_menu.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/navigation/app_navigator.dart';
import '../data/pokedex_data.dart';
import '../models/pokedex_entry.dart';
import 'widgets/pokemon_grid_card.dart';
import 'widgets/pokemon_list_item.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedGeneration = 0; // 0 = All
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch fresh National Pokédex from billsarchive.com (falls back to the
    // bundled list offline); local display names are always preserved.
    PokedexData.refresh().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PokedexEntry> _getFilteredEntries() {
    return PokedexData.resolved.where((entry) {
      // Generation filter
      if (_selectedGeneration > 0 && entry.generation != _selectedGeneration) {
        return false;
      }
      // Text query filter (name, formatted number, or type)
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLanguage = ref.watch(languageProvider);
    final strings = getStrings(currentLanguage);

    final filteredEntries = _getFilteredEntries();

    // Max generation present in the data (e.g. 9 now, 10 once Gen X lands).
    final maxGeneration = PokedexData.resolved.fold<int>(
      1,
      (acc, e) => e.generation > acc ? e.generation : acc,
    );

    // Watch providers during build so the grid responds to scale/grid changes.
    final cardScale = ref.watch(menuCardScaleProvider);
    ref.watch(gridCompositionProvider);
    final viewMode = ref.watch(cardViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.pokedexTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const AppOverflowMenu(showCurrency: true, scaleTarget: CardScaleTarget.menu),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search Box (DRY)
          SliverToBoxAdapter(
            child: AppSearchBar(
              controller: _searchController,
              hintText: strings.pokedexSearchHint,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              onChanged: (val) => setState(() => _searchQuery = val),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),

          // Generation Filter Dropdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedGeneration,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                      items: [
                        for (int i = 0; i <= maxGeneration; i++)
                          DropdownMenuItem<int>(
                            value: i,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  i == 0 ? Icons.all_inclusive : Icons.catching_pokemon,
                                  size: 15,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(i == 0 ? strings.pokedexAllGens : strings.pokedexGen(i)),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (val) => setState(() => _selectedGeneration = val ?? 0),
                    ),
                  ),
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
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
