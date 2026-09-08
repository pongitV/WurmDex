import 'package:flutter_test/flutter_test.dart';
import 'package:wurmdex/features/news/services/tcg_news_service.dart';

void main() {
  test('Test fetchLiveNews and Bills Archive delivers TCG news', () async {
    final news = await TcgNewsService.fetchLiveNews(forceRefresh: true);
    expect(news, isNotEmpty);
    final bills = news.where((n) => n.source.contains("Bill")).toList();
    expect(bills, isNotEmpty);
    for (final b in bills) {
      expect(b.title, isNotEmpty);
      expect(b.url, startsWith('https://billsarchive.com/'));
      expect(b.summary, isNotEmpty);
    }
  });

  test('Test fetchLiveNews delivers TCG Scene competitive news', () async {
    final news = await TcgNewsService.fetchLiveNews(forceRefresh: true);
    final scene = news.where((n) =>
        n.id.startsWith('scene_') ||
        n.source.contains('Scene') ||
        n.source.contains('Cenário') ||
        n.category == 'COMPETITIVE' ||
        n.category == 'MERCADO').toList();
    expect(scene, isNotEmpty);
    for (final s in scene) {
      expect(s.title, isNotEmpty);
      expect(s.url, isNotEmpty);
    }
  });
}
