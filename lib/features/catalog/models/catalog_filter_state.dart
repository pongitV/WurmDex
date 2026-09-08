enum CatalogSortOption {
  nameAsc, // Name A-Z
  nameDesc, // Name Z-A
  priceDesc, // Price: High to Low
  priceAsc, // Price: Low to High
  releaseDateDesc, // Release Date: Newest first
  releaseDateAsc, // Release Date: Oldest first
  popularityDesc, // Sales / Popularity
  numberAsc, // Card Number: Low to High
}

class CatalogFilterState {
  final String? selectedType; // e.g., 'Grass', 'Fire', 'Water', etc.
  final String? selectedRarity; // e.g., 'Rare', 'Ultra Rare', 'Secret Rare', etc.
  final CatalogSortOption sortOption;

  const CatalogFilterState({
    this.selectedType,
    this.selectedRarity,
    this.sortOption = CatalogSortOption.priceDesc,
  });

  bool get hasActiveFilters => selectedType != null || selectedRarity != null;

  int get activeFilterCount {
    int count = 0;
    if (selectedType != null) count++;
    if (selectedRarity != null) count++;
    return count;
  }

  CatalogFilterState copyWith({
    String? selectedType,
    bool clearType = false,
    String? selectedRarity,
    bool clearRarity = false,
    CatalogSortOption? sortOption,
  }) {
    return CatalogFilterState(
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedRarity: clearRarity ? null : (selectedRarity ?? this.selectedRarity),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  CatalogFilterState resetFilters() {
    return const CatalogFilterState();
  }
}
