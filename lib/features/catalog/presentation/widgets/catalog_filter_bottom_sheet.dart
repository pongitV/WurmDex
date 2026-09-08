import 'package:flutter/material.dart';
import '../../../../core/widgets/bottom_sheet_drag_handle.dart';
import '../../models/catalog_filter_state.dart';

void showCatalogFilterBottomSheet(
  BuildContext context, {
  required CatalogFilterState currentState,
  required ValueChanged<CatalogFilterState> onApply,
}) {
  showAppModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    builder: (ctx) => CatalogFilterBottomSheet(
      initialState: currentState,
      onApply: onApply,
    ),
  );
}

class CatalogFilterBottomSheet extends StatefulWidget {
  final CatalogFilterState initialState;
  final ValueChanged<CatalogFilterState> onApply;

  const CatalogFilterBottomSheet({
    super.key,
    required this.initialState,
    required this.onApply,
  });

  @override
  State<CatalogFilterBottomSheet> createState() => _CatalogFilterBottomSheetState();
}

class _CatalogFilterBottomSheetState extends State<CatalogFilterBottomSheet> {
  late CatalogFilterState _state;

  static const List<Map<String, String>> _types = [
    {'label': 'Grama', 'value': 'Grass'},
    {'label': 'Fogo', 'value': 'Fire'},
    {'label': 'Água', 'value': 'Water'},
    {'label': 'Elétrico', 'value': 'Lightning'},
    {'label': 'Psíquico', 'value': 'Psychic'},
    {'label': 'Luta', 'value': 'Fighting'},
    {'label': 'Escuridão', 'value': 'Darkness'},
    {'label': 'Metal', 'value': 'Metal'},
    {'label': 'Dragão', 'value': 'Dragon'},
    {'label': 'Incolor', 'value': 'Colorless'},
    {'label': 'Treinador', 'value': 'Trainer'},
    {'label': 'Energia', 'value': 'Energy'},
  ];

  static const List<Map<String, String>> _rarities = [
    {'label': 'Comum', 'value': 'Common'},
    {'label': 'Incomum', 'value': 'Uncommon'},
    {'label': 'Rara', 'value': 'Rare'},
    {'label': 'Rara Holo', 'value': 'Rare Holo'},
    {'label': 'Ultra Rara (ex/V)', 'value': 'Ultra Rare'},
    {'label': 'Ilustração Rara', 'value': 'Illustration Rare'},
    {'label': 'Secreta Dourada', 'value': 'Secret Rare'},
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Filtros e Ordenação',
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
                  child: const Text('Limpar Tudo'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView(
                children: [
                  // Section: Ordenação
                  Text(
                    'ORDENAR POR',
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
                        _buildSortChip('Maior Preço', CatalogSortOption.priceDesc),
                        _buildSortChip('Menor Preço', CatalogSortOption.priceAsc),
                        _buildSortChip('Mais Vendidas', CatalogSortOption.popularityDesc),
                        _buildSortChip('Lançamento (Recentes)', CatalogSortOption.releaseDateDesc),
                        _buildSortChip('Lançamento (Antigas)', CatalogSortOption.releaseDateAsc),
                        _buildSortChip('Nome (A-Z)', CatalogSortOption.nameAsc),
                        _buildSortChip('Nome (Z-A)', CatalogSortOption.nameDesc),
                        _buildSortChip('Número (#)', CatalogSortOption.numberAsc),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Section: Tipo de Energia / Supertipo
                  Text(
                    'TIPO DE ENERGIA / CATEGORIA',
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
                    children: _types.map((t) {
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
                    'RARIDADE',
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
                    children: _rarities.map((r) {
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
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_state);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar Filtros'),
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
