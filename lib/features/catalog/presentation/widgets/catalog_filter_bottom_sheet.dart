import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../models/catalog_filter_state.dart';

void showCatalogFilterDialog(
  BuildContext context, {
  required CatalogFilterState currentState,
  required ValueChanged<CatalogFilterState> onApply,
  required AppStrings strings,
}) {
  showDialog(
    context: context,
    builder: (ctx) => CatalogFilterDialog(
      initialState: currentState,
      onApply: onApply,
      strings: strings,
    ),
  );
}

/// Backward-compatible alias
void showCatalogFilterBottomSheet(
  BuildContext context, {
  required CatalogFilterState currentState,
  required ValueChanged<CatalogFilterState> onApply,
  required AppStrings strings,
}) => showCatalogFilterDialog(
  context,
  currentState: currentState,
  onApply: onApply,
  strings: strings,
);

class CatalogFilterDialog extends StatefulWidget {
  final CatalogFilterState initialState;
  final ValueChanged<CatalogFilterState> onApply;
  final AppStrings strings;

  const CatalogFilterDialog({
    super.key,
    required this.initialState,
    required this.onApply,
    required this.strings,
  });

  @override
  State<CatalogFilterDialog> createState() => _CatalogFilterDialogState();
}

class _CatalogFilterDialogState extends State<CatalogFilterDialog> {
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
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.filtersAndMore,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _state = const CatalogFilterState();
                      });
                    },
                    child: Text(
                      strings.btnClearFilters,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SORT OPTIONS ---
                    Text(
                      strings.labelSortBy,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip(isEn ? 'Number (Asc)' : 'Número (Crescente)', CatalogSortOption.numberAsc),
                        _buildSortChip(isEn ? 'Price (High to Low)' : 'Preço (Maior)', CatalogSortOption.priceDesc),
                        _buildSortChip(isEn ? 'Price (Low to High)' : 'Preço (Menor)', CatalogSortOption.priceAsc),
                        _buildSortChip(isEn ? 'Name (A-Z)' : 'Nome (A-Z)', CatalogSortOption.nameAsc),
                        _buildSortChip(isEn ? 'Name (Z-A)' : 'Nome (Z-A)', CatalogSortOption.nameDesc),
                        _buildSortChip(isEn ? 'Release Date' : 'Lançamento', CatalogSortOption.releaseDateDesc),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // --- ENERGY TYPE ---
                    Text(
                      strings.filterTypeLabel.replaceAll(': ', ''),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: types.map((t) {
                        final val = t['value']!;
                        final isSelected = _state.selectedType == val;
                        return FilterChip(
                          label: Text(t['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _state = _state.copyWith(
                                selectedType: selected ? val : null,
                                clearType: !selected,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // --- RARITY ---
                    Text(
                      strings.filterRarityLabel.replaceAll(': ', ''),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: rarities.map((r) {
                        final val = r['value']!;
                        final isSelected = _state.selectedRarity == val;
                        return FilterChip(
                          label: Text(r['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _state = _state.copyWith(
                                selectedRarity: selected ? val : null,
                                clearRarity: !selected,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // --- LANGUAGE ---
                    Text(
                      strings.languageLabel.replaceAll(': ', ''),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: languages.map((l) {
                        final val = l['value']!;
                        final isSelected = _state.selectedLanguage == val;
                        return FilterChip(
                          label: Text(l['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _state = _state.copyWith(
                                selectedLanguage: selected ? val : null,
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
            ),

            // Footer Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.cancel),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    onPressed: () {
                      widget.onApply(_state);
                      Navigator.pop(context);
                    },
                    label: Text(isEn ? 'Apply Filters' : 'Aplicar Filtros'),
                  ),
                ],
              ),
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
