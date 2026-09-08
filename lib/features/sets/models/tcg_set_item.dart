class TcgSetItem {
  final String id;
  final String name;
  final int totalCards;
  final int officialCards;
  final int year;
  final String? releaseDate;
  final String? logoUrl;
  final String? symbolUrl;
  final String? serieId;
  final String? serieName;
  final bool isUpcoming;

  const TcgSetItem({
    required this.id,
    required this.name,
    required this.totalCards,
    this.officialCards = 0,
    required this.year,
    this.releaseDate,
    this.logoUrl,
    this.symbolUrl,
    this.serieId,
    this.serieName,
    this.isUpcoming = false,
  });

  /// User requested format: "Name (X)" where X is the number of prints/cards
  String get displayNameWithCount {
    if (totalCards > 0) {
      return '$name ($totalCards)';
    }
    return name;
  }

  factory TcgSetItem.fromJson(Map<String, dynamic> json, {int? inferredYear, bool isUpcoming = false}) {
    final cardCount = json['cardCount'] is Map ? json['cardCount'] as Map : {};
    final total = (cardCount['total'] as num?)?.toInt() ?? 0;
    final official = (cardCount['official'] as num?)?.toInt() ?? 0;

    String? logo = json['logo']?.toString();
    if (logo != null && !logo.endsWith('.png') && !logo.endsWith('.webp')) {
      logo = '$logo.png';
    }

    String? symbol = json['symbol']?.toString();
    if (symbol != null && !symbol.endsWith('.png') && !symbol.endsWith('.webp')) {
      symbol = '$symbol.png';
    }

    final release = json['releaseDate']?.toString();
    int year = inferredYear ?? 2024;
    if (release != null && release.length >= 4) {
      final parsedYear = int.tryParse(release.substring(0, 4));
      if (parsedYear != null) {
        year = parsedYear;
      }
    }

    return TcgSetItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      totalCards: total,
      officialCards: official,
      year: year,
      releaseDate: release,
      logoUrl: logo,
      symbolUrl: symbol,
      serieId: (json['serie'] is Map) ? json['serie']['id']?.toString() : null,
      serieName: (json['serie'] is Map) ? json['serie']['name']?.toString() : null,
      isUpcoming: isUpcoming,
    );
  }
}
