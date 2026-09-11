import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../models/pokemon_cards_filter.dart';

void showPokemonCardsFilterBottomSheet(
  BuildContext context, {
  required PokemonCardsFilter currentFilter,
  required List<String> sets,
  required List<String> languages,
  required List<String> types,
  required ValueChanged<PokemonCardsFilter> onApply,
  required AppStrings strings,
}) {
  showAppModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    builder: (ctx) => PokemonCardsFilterBottomSheet(
      currentFilter: currentFilter,
      sets: sets,
      languages: languages,
      types: types,
      onApply: onApply,
      strings: strings,
    ),
  );
}

class PokemonCardsFilterBottomSheet extends StatefulWidget {
  final PokemonCardsFilter currentFilter;
  final List<String> sets;
  final List<String> languages;
  final List<String> types;
  final ValueChanged<PokemonCardsFilter> onApply;
  final AppStrings strings;

  const PokemonCardsFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.sets,
    required this.languages,
    required this.types,
    required this.onApply,
    required this.strings,
  });

  @override
  State<PokemonCardsFilterBottomSheet> createState() => _PokemonCardsFilterBottomSheetState();
}

class _PokemonCardsFilterBottomSheetState extends State<PokemonCardsFilterBottomSheet> {
  late PokemonCardsFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;
    final isEn = strings.isEn;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BottomSheetDragHandle(bottomPadding: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.filtersAndMore,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = const PokemonCardsFilter();
                    });
                  },
                  child: Text(isEn ? 'Clear All' : 'Limpar Tudo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _sectionLabel(theme, isEn, 'COLLECTION', 'COLEÇÃO'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.sets.map((set) {
                      return _buildChip(
                        label: set,
                        selected: _filter.selectedSet == set,
                        onSelected: (selected) {
                          setState(() {
                            _filter = _filter.copyWith(
                              selectedSet: selected ? set : null,
                              clearSet: !selected,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel(theme, isEn, 'LANGUAGE', 'IDIOMA'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.languages.map((lang) {
                      final label = lang == 'pt' ? 'Português' : 'English';
                      return _buildChip(
                        label: label,
                        selected: _filter.selectedLanguage == lang,
                        onSelected: (selected) {
                          setState(() {
                            _filter = _filter.copyWith(
                              selectedLanguage: selected ? lang : null,
                              clearLanguage: !selected,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel(theme, isEn, 'ENERGY TYPE / CATEGORY', 'TIPO DE ENERGIA / CATEGORIA'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.types.map((type) {
                      return _buildChip(
                        label: type,
                        selected: _filter.selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _filter = _filter.copyWith(
                              selectedType: selected ? type : null,
                              clearType: !selected,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_filter);
                      Navigator.pop(context);
                    },
                    child: Text(isEn ? 'Apply Filters' : 'Aplicar Filtros'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, bool isEn, String en, String pt) {
    return Text(
      isEn ? en : pt,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}