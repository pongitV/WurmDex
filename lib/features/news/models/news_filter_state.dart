enum NewsSortOption {
  newest,
  oldest,
  titleAsc,
  source,
}

class NewsFilterState {
  final String selectedSource;
  final String selectedCategory;
  final NewsSortOption sortOption;

  const NewsFilterState({
    this.selectedSource = 'ALL',
    this.selectedCategory = 'ALL',
    this.sortOption = NewsSortOption.newest,
  });

  bool get hasActiveFilters => selectedSource != 'ALL' || selectedCategory != 'ALL';
  int get activeFilterCount => (selectedSource != 'ALL' ? 1 : 0) + (selectedCategory != 'ALL' ? 1 : 0);

  NewsFilterState copyWith({
    String? selectedSource,
    String? selectedCategory,
    NewsSortOption? sortOption,
  }) {
    return NewsFilterState(
      selectedSource: selectedSource ?? this.selectedSource,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
