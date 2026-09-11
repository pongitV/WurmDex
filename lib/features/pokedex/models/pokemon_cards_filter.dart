class PokemonCardsFilter {
  final String? selectedSet;
  final String? selectedLanguage;
  final String? selectedType;

  const PokemonCardsFilter({
    this.selectedSet,
    this.selectedLanguage,
    this.selectedType,
  });

  bool get hasActiveFilters =>
      selectedSet != null || selectedLanguage != null || selectedType != null;

  int get activeFilterCount {
    int count = 0;
    if (selectedSet != null) count++;
    if (selectedLanguage != null) count++;
    if (selectedType != null) count++;
    return count;
  }

  PokemonCardsFilter copyWith({
    String? selectedSet,
    bool clearSet = false,
    String? selectedLanguage,
    bool clearLanguage = false,
    String? selectedType,
    bool clearType = false,
  }) {
    return PokemonCardsFilter(
      selectedSet: clearSet ? null : (selectedSet ?? this.selectedSet),
      selectedLanguage:
          clearLanguage ? null : (selectedLanguage ?? this.selectedLanguage),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
    );
  }

  PokemonCardsFilter reset() => const PokemonCardsFilter();
}