class TcgNewsItem {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String date;
  final String? url;
  final String? imageUrl;
  final String source;

  const TcgNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.date,
    this.url,
    this.imageUrl,
    this.source = 'Pokémon TCG',
  });
}

