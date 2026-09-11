import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../models/catalog_filter_state.dart';

void showCatalogFilterBottomSheet(
  BuildContext context, {
  required CatalogFilterState currentState,
  required ValueChanged<CatalogFilterState> onApply,
  required AppStrings strings,
}) {
  showAppModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    builder: (ctx) => CatalogFilterBottomSheet(
      initialState: currentState,
      onApply: onApply,
      strings: strings,
    ),
  );
}

class CatalogFilterBottomSheet extends StatefulWidget {
  final CatalogFilterState initialState;
  final ValueChanged<CatalogFilterState> onApply;
  final AppStrings strings;

  const CatalogFilterBottomSheet({
    super.key,
    required this.initialState,
    required this.onApply,
    required this.strings,
  });

  @override
  State<CatalogFilterBottomSheet> createState() => _CatalogFilterBottomSheetState();
}

class _CatalogFilterBottomSheetState extends State<CatalogFilterBottomSheet> {
  late CatalogFilterState _state;

  List<Map<String, String>> _getTypes(bool isEn) => [
    {'label': isEn ? 'Grass' : 'Grama', 'value': 'Grass'},
    {'label': isEn ? 'Fire' : 'Fogo', 'value': 'Fire'},
    {'label': isEn ? 'Water' : 'Água', 'value': 'Water'},
    {'label': isEn ? 'Lightning' : 'Elétrico', 'value': 'Lightning'},
    {'label': isEn ? 'Psychic' : 'Psíquico', 'value': 'Psychic'},
    {'label': isEn ? 'Fighting' : 'Luta', 'value': 'Fighting'},
    {'label': isEn ? 'Darkness' : 'Escuridão', 'value': 'Darkness'},
    {'label': isEn ? 'Metal' : 'Metal', 'value': 'Metal'},
    {'label': isEn ? 'Dragon' : 'Dragão', 'value': 'Dragon'},
    {'label': isEn ? 'Colorless' : 'Incolor', 'value': 'Colorless'},
    {'label': isEn ? 'Trainer' : 'Treinador', 'value': 'Trainer'},
    {'label': isEn ? 'Energy' : 'Energia', 'value': 'Energy'},
  ];

  List<Map<String, String>> _getRarities(bool isEn) => [
    {'label': isEn ? 'Common' : 'Comum', 'value': 'Common'},
    {'label': isEn ? 'Uncommon' : 'Incomum', 'value': 'Uncommon'},
    {'label': isEn ? 'Rare' : 'Rara', 'value': 'Rare'},
    {'label': isEn ? 'Rare Holo' : 'Rara Holo', 'value': 'Rare Holo'},
    {'label': isEn ? 'Ultra Rare (ex/V)' : 'Ultra Rara (ex/V)', 'value': 'Ultra Rare'},
    {'label': isEn ? 'Illustration Rare' : 'Ilustração Rara', 'value': 'Illustration Rare'},
    {'label': isEn ? 'Secret Rare' : 'Secreta Dourada', 'value': 'Secret Rare'},
  ];

  List<Map<String, String>> _getLanguages(bool isEn) => [
    {'label': isEn ? 'English' : 'Inglês', 'value': 'en'},
    {'label': 'Português', 'value': 'pt'},
    {'label': 'Español', 'value': 'es'},
    {'label': 'Français', 'value': 'fr'},
    {'label': 'Deutsch', 'value': 'de'},
    {'label': 'Italiano', 'value': 'it'},
    {'label': '日本語', 'value': 'ja'},
    {'label': '한국어', 'value': 'ko'},
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = widget.strings;
    final isEn = strings.isEn;
    final types = _getTypes(isEn);
    final rarities = _getRarities(isEn);
    final languages = _getLanguages(isEn);

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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.filtersAndMore,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _state = const CatalogFilterState();
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
                  // Section: Ordenação
                  Text(
                    isEn ? 'SORT BY' : 'ORDENAR POR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip(isEn ? 'Highest Price' : 'Maior Preço', CatalogSortOption.priceDesc),
                      _buildSortChip(isEn ? 'Lowest Price' : 'Menor Preço', CatalogSortOption.priceAsc),
                      _buildSortChip(isEn ? 'Most Popular' : 'Mais Vendidas', CatalogSortOption.popularityDesc),
                      _buildSortChip(isEn ? 'Release (Newest)' : 'Lançamento (Recentes)', CatalogSortOption.releaseDateDesc),
                      _buildSortChip(isEn ? 'Release (Oldest)' : 'Lançamento (Antigas)', CatalogSortOption.releaseDateAsc),
                      _buildSortChip(isEn ? 'Name (A-Z)' : 'Nome (A-Z)', CatalogSortOption.nameAsc),
                      _buildSortChip(isEn ? 'Name (Z-A)' : 'Nome (Z-A)', CatalogSortOption.nameDesc),
                      _buildSortChip(isEn ? 'Card Number (#)' : 'Número (#)', CatalogSortOption.numberAsc),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section: Tipo de Energia / Supertipo
                  Text(
                    isEn ? 'ENERGY TYPE / CATEGORY' : 'TIPO DE ENERGIA / CATEGORIA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: types.map((t) {
                      final isSelected = _state.selectedType == t['value'];
                      return FilterChip(
                        label: Text(t['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _state = _state.copyWith(
                              selectedType: selected ? t['value'] : null,
                              clearType: !selected,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Section: Raridade
                  Text(
                    isEn ? 'RARITY' : 'RARIDADE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rarities.map((r) {
                      final isSelected = _state.selectedRarity == r['value'];
                      return FilterChip(
                        label: Text(r['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _state = _state.copyWith(
                              selectedRarity: selected ? r['value'] : null,
                              clearRarity: !selected,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Section: Idioma da Carta
                  Text(
                    isEn ? 'CARD LANGUAGE' : 'IDIOMA DA CARTA',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: languages.map((l) {
                      final isSelected = _state.selectedLanguage == l['value'];
                      return FilterChip(
                        label: Text(l['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _state = _state.copyWith(
                              selectedLanguage: selected ? l['value'] : null,
                              clearLanguage: !selected,
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

            // Action Buttons
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
                      widget.onApply(_state);
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

  Widget _buildSortChip(String label, CatalogSortOption option) {
    final isSelected = _state.sortOption == option;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _state = _state.copyWith(sortOption: option);
          });
        }
      },
    );
  }
}
