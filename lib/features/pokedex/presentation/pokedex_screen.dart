import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/quick_currency_toggle.dart';
import '../../../core/navigation/app_navigator.dart';
import '../data/pokedex_data.dart';
import '../models/pokedex_entry.dart';
import 'widgets/pokemon_grid_card.dart';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PokedexEntry> _getFilteredEntries() {
    return PokedexData.entries.where((entry) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.pokedexTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          QuickCurrencyToggle(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Box (DRY)
          AppSearchBar(
            controller: _searchController,
            hintText: strings.pokedexSearchHint,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            onChanged: (val) => setState(() => _searchQuery = val),
            onClear: () => setState(() => _searchQuery = ''),
          ),

          // Generation Filter Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: 10, // 0 is All, 1-9 are Gens
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedGeneration == index;
                final label = index == 0
                    ? strings.pokedexAllGens
                    : strings.pokedexGen(index);

                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGeneration = selected ? index : 0;
                    });
                  },
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Pokémon Grid (3x3 on mobile, responsive on wider screens)
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
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
                          Text(
                            strings.noCardsFound,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      // Enforce 3x3 layout on standard mobile/narrow displays
                      final crossAxisCount = width > 1100
                          ? 7
                          : width > 800
                              ? 5
                              : width > 550
                                  ? 4
                                  : 3;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final pokemon = filteredEntries[index];
                          return PokemonGridCard(
                            pokemon: pokemon,
                            onTap: () => AppNavigator.toPokemonGallery(context, pokemon: pokemon),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
