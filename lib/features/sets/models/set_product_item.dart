class SetProductItem {
  final String id;
  final String name;
  final String productType;
  final String imageUrl;
  final double? msrpUsd;
  final int? packCount;
  final String description;
  final String? releaseDate;

  const SetProductItem({
    required this.id,
    required this.name,
    required this.productType,
    required this.imageUrl,
    this.msrpUsd,
    this.packCount,
    required this.description,
    this.releaseDate,
  });
}
