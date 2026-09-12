import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/app_image_headers.dart';
import '../../../core/network/dio_client.dart';
import '../models/tcg_news_item.dart';

class TcgNewsService {
  static List<TcgNewsItem> _cachedNews = [];
  static DateTime? _lastFetchTime;

  /// Curated thematic images for official Pokémon news when RSS feed does not embed an image
  static const List<String> _thematicImages = [
    'https://images.pokemontcg.io/sv3pt5/logo.png',
    'https://images.pokemontcg.io/sv4pt5/logo.png',
    'https://images.pokemontcg.io/sv06/logo.png',
    'https://images.pokemontcg.io/sv07/logo.png',
    'https://images.pokemontcg.io/sv08/logo.png',
    'https://images.pokemontcg.io/swsh12pt5/logo.png',
  ];

  static String _selectThematicImage(String title, int index) {
    final lower = title.toLowerCase();
    if (lower.contains('rocket')) {
      return 'https://images.pokemontcg.io/base5/logo.png';
    }
    if (lower.contains('151') || lower.contains('mew') || lower.contains('charizard')) {
      return 'https://images.pokemontcg.io/sv3pt5/logo.png';
    }
    if (lower.contains('championship') || lower.contains('world') || lower.contains('play!')) {
      return 'https://images.pokemontcg.io/sv4pt5/logo.png';
    }
    if (lower.contains('product') || lower.contains('release') || lower.contains('lançamento')) {
      return 'https://images.pokemontcg.io/sv07/logo.png';
    }
    return _thematicImages[index % _thematicImages.length];
  }

  /// Fetches real, live news from Official Pokemon.com (EN & PT-BR via Google News RSS) and Bill's Archive
  static Future<List<TcgNewsItem>> fetchLiveNews({bool forceRefresh = false, bool isEn = true}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedNews.isNotEmpty &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inMinutes < 15) {
      return _cachedNews;
    }

    final officialUrl = isEn
        ? 'https://news.google.com/rss/search?q=site:pokemon.com/us/pokemon-tcg+OR+site:tcg.pokemon.com+OR+site:pokemon.com+TCG&hl=en-US&gl=US&ceid=US:en'
        : 'https://news.google.com/rss/search?q=Pokemon+Estampas+Ilustradas+OR+Pokemon+TCG+site:pokemon.com/br&hl=pt-BR&gl=BR&ceid=BR:pt-419';

    final sceneUrl = isEn
        ? 'https://news.google.com/rss/search?q=Pokemon+TCG+competitive+OR+Pokemon+TCG+tournament+OR+Pokemon+TCG+meta+OR+Pokemon+TCG+deck&hl=en-US&gl=US&ceid=US:en'
        : 'https://news.google.com/rss/search?q=Pokemon+Estampas+Ilustradas+torneio+OR+Pokemon+TCG+competitivo+OR+Pokemon+TCG+regional&hl=pt-BR&gl=BR&ceid=BR:pt-419';
    final tcgTalkUrl =
        'https://news.google.com/rss/search?q=site%3Atcgtalk.com+Pokemon+TCG&hl=${isEn ? 'en-US' : 'pt-BR'}&gl=${isEn ? 'US' : 'BR'}&ceid=${isEn ? 'US:en' : 'BR:pt-419'}';

    // Fetch in parallel for maximum speed and responsiveness
    final results = await Future.wait([
      _fetchGoogleNewsRss(
        url: officialUrl,
        feedGroup: 'pokemon',
        sourceName: isEn ? 'Pokemon.com' : 'Pokemon.com Oficial',
        defaultCategory: isEn ? 'OFFICIAL NEWS' : 'LANÇAMENTOS',
      ).catchError((e) {
        debugPrint('Error fetching Pokemon.com official news: $e');
        return <TcgNewsItem>[];
      }),
      _fetchBillsArchive().catchError((e) {
        debugPrint('Error fetching Bills Archive news: $e');
        return <TcgNewsItem>[];
      }),
      _fetchGoogleNewsRss(
        url: sceneUrl,
        feedGroup: 'scene',
        sourceName: isEn ? 'TCG Scene' : 'Cenário TCG',
        defaultCategory: isEn ? 'COMPETITIVE' : 'MERCADO',
      ).catchError((e) {
        debugPrint('Error fetching TCG Scene news: $e');
        return <TcgNewsItem>[];
      }),
      _fetchGoogleNewsRss(
        url: tcgTalkUrl,
        feedGroup: 'tcgtalk',
        sourceName: 'TCGTalk',
        defaultCategory: isEn ? 'TCG TALK' : 'NOTÍCIAS TCG',
      ).catchError((e) {
        debugPrint('Error fetching TCGTalk news: $e');
        return <TcgNewsItem>[];
      }),
    ]);

    final List<TcgNewsItem> combined = [];
    final officialArticles = results[0];
    final billsArticles = results[1];
    final sceneArticles = results[2];
    final tcgTalkArticles = results[3];

    combined.addAll(officialArticles);
    combined.addAll(billsArticles);

    for (final art in sceneArticles) {
      if (!combined.any((item) => item.title.toLowerCase() == art.title.toLowerCase())) {
        combined.add(art);
      }
      for (final art in tcgTalkArticles) {
        if (!combined.any((item) => item.title.toLowerCase() == art.title.toLowerCase())) {
          combined.add(art);
        }
      }
    }

    if (combined.isNotEmpty) {
      _cachedNews = combined;
      _lastFetchTime = now;
      return combined;
    }

    if (_cachedNews.isNotEmpty) {
      return _cachedNews;
    }

    // Reliable fallback news items with guaranteed working sources & links
    final fallback = _getCuratedFallbackNews(isEn);
    _cachedNews = fallback;
    return fallback;
  }

  static List<TcgNewsItem> _getCuratedFallbackNews(bool isEn) {
    if (isEn) {
      return [
        TcgNewsItem(
          id: 'fb_1',
          title: 'Scarlet & Violet—Prismatic Evolutions Expansion Announced with Stellar Eeveelutions',
          summary: 'Explore dazzling new Tera Pokémon ex featuring all nine beloved Eevee evolutions and premium Special Illustration Rares.',
          category: 'OFFICIAL NEWS',
          date: 'Recent',
          url: 'https://www.pokemon.com/us/pokemon-tcg',
          imageUrl: 'https://images.pokemontcg.io/sv08/logo.png',
          source: 'Pokemon.com',
        ),
        TcgNewsItem(
          id: 'fb_2',
          title: 'The Bill’s Archive Complete Retrospective: Evolution of Pokémon TCG Rarities and Holos',
          summary: 'In-depth historical analysis of secret rares, holographic patterns, and market shifts from Base Set to the Scarlet & Violet era.',
          category: 'MARKET ARCHIVE',
          date: 'Recent',
          url: 'https://billsarchive.com/articles.html',
          imageUrl: 'https://images.pokemontcg.io/sv3pt5/logo.png',
          source: "Bill's Archive",
        ),
        TcgNewsItem(
          id: 'fb_3',
          title: 'Play! Pokémon Championship Series: Metagame Shifts and Top Deck Strategies',
          summary: 'Regional breakdown and tier list analysis for current standard tournament competitive decks.',
          category: 'COMPETITIVE',
          date: 'Recent',
          url: 'https://www.pokemon.com/us/play-pokemon',
          imageUrl: 'https://images.pokemontcg.io/sv4pt5/logo.png',
          source: 'Pokemon.com',
        ),
      ];
    } else {
      return [
        TcgNewsItem(
          id: 'fb_pt_1',
          title: 'Expansão Escarlate e Violeta — Evoluções Prismáticas anunciada no Brasil',
          summary: 'Descubra as novas cartas de Pokémon Tera ex com todas as formas evolutivas do Eevee e raras especiais de ilustração.',
          category: 'LANÇAMENTOS',
          date: 'Recente',
          url: 'https://www.pokemon.com/br/pokemon-estampas-ilustradas',
          imageUrl: 'https://images.pokemontcg.io/sv08/logo.png',
          source: 'Pokemon.com Oficial',
        ),
        TcgNewsItem(
          id: 'fb_pt_2',
          title: 'Bill’s Archive: Análise Retrospectiva do Mercado de Raridades e Colecionismo',
          summary: 'Estudo aprofundado sobre padrões holográficos, valor histórico e cartas secretas desde a Coleção Básica.',
          category: 'MERCADO',
          date: 'Recente',
          url: 'https://billsarchive.com/articles.html',
          imageUrl: 'https://images.pokemontcg.io/sv3pt5/logo.png',
          source: "Bill's Archive",
        ),
        TcgNewsItem(
          id: 'fb_pt_3',
          title: 'Campeonatos Oficiais Pokémon TCG: Visão Geral do Metagame Nacional',
          summary: 'Estratégias de ponta, listas competitivas e guia de preparação para torneios do circuito oficial.',
          category: 'COMPETITIVO',
          date: 'Recente',
          url: 'https://www.pokemon.com/br/play-pokemon',
          imageUrl: 'https://images.pokemontcg.io/sv4pt5/logo.png',
          source: 'Pokemon.com Oficial',
        ),
      ];
    }
  }

  /// Fetches Google News RSS items for live official Pokemon and competitive scene coverage
  static Future<List<TcgNewsItem>> _fetchGoogleNewsRss({
    required String url,
    required String feedGroup,
    required String sourceName,
    required String defaultCategory,
  }) async {
    final response = await DioClient.instance.get(
      url,
      options: Options(
        headers: {
          'User-Agent': AppImageHeaders.browserUserAgent,
          'Accept': 'application/rss+xml,application/xml,text/xml',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      return [];
    }

    final xml = response.data.toString();
    final List<TcgNewsItem> items = [];

    // Match <item> elements
    final itemRegex = RegExp(r'<item>([\s\S]*?)</item>');
    final matches = itemRegex.allMatches(xml);

    int idx = 0;
    for (final m in matches) {
      final itemContent = m.group(1) ?? '';

      final titleMatch = RegExp(r'<title>([\s\S]*?)</title>').firstMatch(itemContent);
      final linkMatch = RegExp(r'<link>([\s\S]*?)</link>').firstMatch(itemContent);
      final pubDateMatch = RegExp(r'<pubDate>([\s\S]*?)</pubDate>').firstMatch(itemContent);
      final sourceMatch = RegExp(r'<source[^>]*>([\s\S]*?)</source>').firstMatch(itemContent);

      if (titleMatch != null && linkMatch != null) {
        var rawTitle = _stripCdata(titleMatch.group(1) ?? '');
        var link = _stripCdata(linkMatch.group(1) ?? '').trim();
        var rawDate = _stripCdata(pubDateMatch?.group(1) ?? '').trim();
        var sourceExt = _stripCdata(sourceMatch?.group(1) ?? '').trim();

        // Clean trailing source from title (e.g. "Title - Pokemon.com")
        if (rawTitle.contains(' - ')) {
          final parts = rawTitle.split(' - ');
          if (parts.length > 1) {
            rawTitle = parts.sublist(0, parts.length - 1).join(' - ');
          }
        }

        final title = _decodeHtml(rawTitle.trim());
        if (title.isEmpty) continue;

        // Simplify publication date (e.g. "01 Sep 2026")
        String formattedDate = 'Recente';
        if (rawDate.isNotEmpty) {
          final dateParts = rawDate.split(' ');
          if (dateParts.length >= 4) {
            formattedDate = '${dateParts[1]} ${dateParts[2]} ${dateParts[3]}';
          }
        }

        final effectiveSource = sourceExt.isNotEmpty ? '$sourceName ($sourceExt)' : sourceName;
        final imageUrl = _selectThematicImage(title, idx);

        if (!items.any((it) => it.title.toLowerCase() == title.toLowerCase())) {
          items.add(
            TcgNewsItem(
              id: '${feedGroup}_${idx++}_${title.hashCode.abs()}',
              title: title,
              summary: 'Comunicado e cobertura sobre Pokémon TCG em $effectiveSource.',
              category: defaultCategory,
              date: formattedDate,
              url: link,
              imageUrl: imageUrl,
              source: effectiveSource,
            ),
          );
        }
      }

      if (items.length >= 12) break;
    }

    return items;
  }

  /// Scrapes genuine TCG articles, market data, and release analyses from Bill's Archive
  static Future<List<TcgNewsItem>> _fetchBillsArchive() async {
    final List<TcgNewsItem> items = [];

    // Try fetching from /articles.html first, fallback to homepage
    for (final path in ['articles.html', '']) {
      try {
        final response = await DioClient.instance.get(
          'https://billsarchive.com/$path',
          options: Options(
            headers: {
              'User-Agent': AppImageHeaders.browserUserAgent,
              'Accept': 'text/html,application/xhtml+xml,application/xml',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != 200 || response.data == null) continue;

        final html = response.data.toString();
        final linkRegex = RegExp(r'''<a\s+[^>]*href=["']([^"']+)["'][^>]*>([\s\S]*?)</a>''');
        final matches = linkRegex.allMatches(html);

        int idx = items.length;
        for (final match in matches) {
          final href = match.group(1) ?? '';
          final inner = match.group(2) ?? '';

          if (!href.contains('article') && !inner.contains('article-card') && !inner.contains('featured')) {
            continue;
          }

          final titleMatch = RegExp(r'<h[234][^>]*>([\s\S]*?)</h[234]>').firstMatch(inner);
          if (titleMatch == null) continue;

          final rawTitle = titleMatch.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim() ?? '';
          if (rawTitle.isEmpty) continue;

          final title = _decodeHtml(rawTitle);

          final categoryMatch = RegExp(r'''class=["'][^"']*(?:article-category|card-tag|badge)[^"']*["'][^>]*>([\s\S]*?)<''').firstMatch(inner);
          final rawCategory = categoryMatch?.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim() ?? '';
          final category = rawCategory.isNotEmpty ? _decodeHtml(rawCategory).toUpperCase() : 'TCG';

          final excerptMatch = RegExp(r'''class=["'][^"']*(?:article-excerpt|featured__dek|card-excerpt)[^"']*["'][^>]*>([\s\S]*?)<''').firstMatch(inner);
          final rawExcerpt = excerptMatch?.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim() ?? '';
          final excerpt = rawExcerpt.isNotEmpty
              ? _decodeHtml(rawExcerpt)
              : "Análise de cartas, mercado e colecionismo no Bill's Archive.";

          final imgMatch = RegExp(r'''<img\s+[^>]*src=["']([^"']+)["']''').firstMatch(inner);
          var imgUrl = imgMatch?.group(1)?.trim();
          if (imgUrl != null && !imgUrl.startsWith('http')) {
            imgUrl = 'https://billsarchive.com${imgUrl.startsWith('/') ? '' : '/'}$imgUrl';
          }

          var articleUrl = href.trim();
          if (!articleUrl.startsWith('http')) {
            articleUrl = 'https://billsarchive.com${articleUrl.startsWith('/') ? '' : '/'}$articleUrl';
          }

          // Filter strictly for Pokémon TCG, cards, sets, and market content
          final combinedText = '$title $category $excerpt'.toLowerCase();
          final isAnimationOnly = (category.contains('ANIMATION') || category.contains('GAMES') || category.contains('FILM')) &&
              !combinedText.contains('card') &&
              !combinedText.contains('tcg') &&
              !combinedText.contains('set');

          if (isAnimationOnly) continue;

          if (!items.any((it) => it.title.toLowerCase() == title.toLowerCase())) {
            items.add(
              TcgNewsItem(
                id: 'bills_${idx++}_${title.hashCode.abs()}',
                title: title,
                summary: excerpt,
                category: category.isNotEmpty ? category : 'TCG',
                date: 'Recente',
                url: articleUrl,
                imageUrl: imgUrl,
                source: "Bill's Archive",
              ),
            );
          }

          if (items.length >= 16) break;
        }

        if (items.isNotEmpty) break;
      } catch (e) {
        debugPrint('Error parsing Bills Archive on $path: $e');
      }
    }

    return items;
  }

  static String _stripCdata(String input) {
    return input.replaceAll('<![CDATA[', '').replaceAll(']]>', '').trim();
  }

  /// Comprehensive HTML entity decoder handling named, decimal, and hex entities
  static String _decodeHtml(String input) {
    var result = input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '...')
        .replaceAll('&middot;', '·')
        .replaceAll('&bull;', '•')
        .replaceAll('&rarr;', '→')
        .replaceAll('&larr;', '←')
        .replaceAll('&trade;', '™')
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');

    // Decode decimal numeric entities: &#123;
    result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      if (code != null) {
        return String.fromCharCode(code);
      }
      return match.group(0)!;
    });

    // Decode hexadecimal entities: &#x1f;
    result = result.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      if (code != null) {
        return String.fromCharCode(code);
      }
      return match.group(0)!;
    });

    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
