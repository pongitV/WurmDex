import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/app_image_headers.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/currency_formatter.dart';

class LigaScrapedProduct {
  final String title;
  final String imageUrl;
  final double? lowestPrice;
  final double? averagePrice;
  final double? highestPrice;
  final bool isPreSale;
  final String? storeName;
  final String productUrl;
  final bool hasStock;

  const LigaScrapedProduct({
    required this.title,
    required this.imageUrl,
    this.lowestPrice,
    this.averagePrice,
    this.highestPrice,
    this.isPreSale = false,
    this.storeName,
    required this.productUrl,
    this.hasStock = false,
  });
}

class LigaCheckResult {
  final bool success;
  final LigaScrapedProduct? product;
  final bool isInRange;
  final String? message;

  const LigaCheckResult({
    required this.success,
    this.product,
    this.isInRange = false,
    this.message,
  });
}

class LigaScraperService {
  /// Dedicated reusable Dio client for proxy-assisted scraping with connection pooling
  static final Dio _jinaDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: AppImageHeaders.scraper,
    ),
  );

  /// Normalizes LigaPokemon URL or constructs a valid search URL from card/item name
  static String normalizeUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // If it looks like a domain path without schema
    if (trimmed.contains('ligapokemon.com.br')) {
      return 'https://$trimmed';
    }

    // Default to card search on LigaPokemon
    final cleanQuery = Uri.encodeComponent(trimmed);
    return 'https://www.ligapokemon.com.br/?view=cards/card&card=$cleanQuery';
  }

  /// Parses a Brazilian currency string like "R$ 1.450,90" or "45,50" into a double
  static double? parseBrlPrice(String? raw) => CurrencyFormatter.parseCurrency(raw);

  /// Scrapes product details, prices, stock and pre-sale status from a LigaPokemon page.
  /// Uses Jina Reader proxy with tool User-Agent to reliably bypass Cloudflare anti-bot.
  static Future<LigaScrapedProduct?> fetchProductDetails(String input) async {
    final targetUrl = normalizeUrl(input);
    if (targetUrl.isEmpty) return null;

    String content = '';

    // Attempt 1: Jina Reader proxy with dedicated tool client (bypasses Cloudflare)
    try {
      final proxyUrl = 'https://r.jina.ai/$targetUrl';
      final proxyResponse = await _jinaDio.get(proxyUrl);
      final raw = proxyResponse.data?.toString() ?? '';
      if (proxyResponse.statusCode == 200 &&
          raw.isNotEmpty &&
          !raw.contains('Just a moment...') &&
          !raw.contains('challenge-platform')) {
        content = raw;
      }
    } catch (proxyError) {
      debugPrint('Jina proxy fetch error: $proxyError');
    }

    // Attempt 2: If full URL failed, try canonical query on Jina (view=prod/view&pcode=...)
    if (content.isEmpty) {
      try {
        final uri = Uri.tryParse(targetUrl);
        if (uri != null) {
          final pcode = uri.queryParameters['pcode'];
          final card = uri.queryParameters['card'];
          String? canonical;
          if (pcode != null) {
            canonical = 'https://www.ligapokemon.com.br/?view=prod/view&pcode=$pcode';
          } else if (card != null) {
            canonical = 'https://www.ligapokemon.com.br/?view=cards/card&card=${Uri.encodeComponent(card)}';
          }

          if (canonical != null && canonical != targetUrl) {
            final res = await _jinaDio.get('https://r.jina.ai/$canonical');
            final raw = res.data?.toString() ?? '';
            if (res.statusCode == 200 && raw.isNotEmpty && !raw.contains('challenge-platform')) {
              content = raw;
            }
          }
        }
      } catch (e) {
        debugPrint('Canonical Liga proxy notice: $e');
      }
    }

    // Attempt 3: Direct fetch fallback via DioClient
    if (content.isEmpty) {
      try {
        final response = await DioClient.instance.get(targetUrl);
        final raw = response.data?.toString() ?? '';
        if (response.statusCode == 200 &&
            !raw.contains('Just a moment...') &&
            !raw.contains('challenge-platform') &&
            !raw.contains('cf-chl')) {
          content = raw;
        }
      } catch (e) {
        debugPrint('Direct LigaPokemon fetch notice: $e');
      }
    }

    if (content.isEmpty) {
      return null;
    }

    return parseContent(targetUrl, content);
  }

  /// Parses both raw HTML and Markdown (from Jina Reader) to extract title, image, prices, and pre-sale status.
  static LigaScrapedProduct parseContent(String targetUrl, String content) {
    // 1. Extract Product Title
    String title = '';

    // Try query parameters from URL first (often contains exact product name)
    try {
      final uri = Uri.tryParse(targetUrl);
      if (uri != null) {
        final prodParam = uri.queryParameters['prod'] ?? uri.queryParameters['card'];
        if (prodParam != null && prodParam.trim().isNotEmpty) {
          title = prodParam.trim();
        }
      }
    } catch (_) {}

    // Markdown title pattern
    if (title.isEmpty) {
      final mdTitleRegex = RegExp(r'Title:\s*([^|\n]+)', caseSensitive: false);
      final mdMatch = mdTitleRegex.firstMatch(content);
      if (mdMatch != null && mdMatch.group(1) != null) {
        title = mdMatch.group(1)!.trim();
      }
    }

    // HTML og:title pattern
    if (title.isEmpty) {
      final ogTitleRegex = RegExp(r'<meta\s+property=["\x27]og:title["\x27]\s+content=["\x27]([^"\x27]+)["\x27]', caseSensitive: false);
      final ogMatch = ogTitleRegex.firstMatch(content);
      if (ogMatch != null && ogMatch.group(1) != null) {
        title = ogMatch.group(1)!.trim();
      }
    }

    // Fallback HTML <title> pattern
    if (title.isEmpty) {
      final titleTagRegex = RegExp(r'<title>(.*?)</title>', caseSensitive: false);
      final titleMatch = titleTagRegex.firstMatch(content);
      if (titleMatch != null && titleMatch.group(1) != null) {
        title = titleMatch.group(1)!.split('-')[0].split('|')[0].trim();
      }
    }

    // Clean common suffixes
    title = title
        .replaceAll(' - Liga Pokémon', '')
        .replaceAll(' - LigaPokemon', '')
        .replaceAll('| Busca de Produtos e Acessórios | LigaPokemon', '')
        .replaceAll('| Busca de Produtos e Acessrios | LigaPokemon', '')
        .trim();

    if (title.isEmpty) {
      title = 'Produto LigaPokémon';
    }

    // 2. Extract Product Image
    String imageUrl = '';

    // Specialized regex for sealed product and card images on Liga (repositorio.sbrauble.com)
    final sbraubleImgRegex = RegExp(r'(https:\/\/repositorio\.sbrauble\.com\/arquivos\/up\/(?:prod|cards)\/[^\s\)"]+)', caseSensitive: false);
    final sbraubleMatch = sbraubleImgRegex.firstMatch(content);
    if (sbraubleMatch != null && sbraubleMatch.group(1) != null) {
      imageUrl = sbraubleMatch.group(1)!.trim().replaceAll(RegExp(r'[\)"\x27]+$'), '');
    }

    if (imageUrl.isEmpty) {
      final mdImgRegex = RegExp(r'!\[.*?\]\((https:\/\/[^\)]+)\)');
      for (final match in mdImgRegex.allMatches(content)) {
        final url = match.group(1) ?? '';
        if (url.contains('up/prod') || url.contains('up/cards') || url.contains('comparador')) {
          imageUrl = url;
          break;
        }
      }
    }

    if (imageUrl.isEmpty) {
      final ogImageRegex = RegExp(r'<meta\s+property=["\x27]og:image["\x27]\s+content=["\x27]([^"\x27]+)["\x27]', caseSensitive: false);
      final imgMatch = ogImageRegex.firstMatch(content);
      if (imgMatch != null && imgMatch.group(1) != null) {
        imageUrl = imgMatch.group(1)!.trim();
      }
    }

    if (imageUrl.isEmpty || imageUrl.contains('logo') || imageUrl.contains('default') || imageUrl.contains('icon')) {
      final cardImgRegex = RegExp(r'id=["\x27]card-image["\x27][^>]+src=["\x27]([^"\x27]+)["\x27]', caseSensitive: false);
      final cardImgMatch = cardImgRegex.firstMatch(content);
      if (cardImgMatch != null && cardImgMatch.group(1) != null) {
        imageUrl = cardImgMatch.group(1)!.trim();
      }
    }

    if (imageUrl.isNotEmpty && imageUrl.startsWith('//')) {
      imageUrl = 'https:$imageUrl';
    }

    // 3. Detect Pre-Sale (Pré-Venda / Pre-Order)
    final lower = content.toLowerCase();
    bool isPreSale = false;
    if (lower.contains('pré-venda') ||
        lower.contains('pre-venda') ||
        lower.contains('prevenda') ||
        lower.contains('pre order') ||
        lower.contains('pre-order') ||
        lower.contains('preorder') ||
        lower.contains('tag-pre-venda') ||
        lower.contains('badge-pre-venda') ||
        title.toLowerCase().contains('pré-venda') ||
        title.toLowerCase().contains('pre-venda') ||
        title.toLowerCase().contains('pre order')) {
      isPreSale = true;
    }

    // 4. Extract Prices
    double? minPrice;
    double? avgPrice;
    double? maxPrice;

    // A. Pattern for card pages: "Menor: R$ ...", "Médio: R$ ...", "Maior: R$ ..."
    final minRegex = RegExp(r'Menor:\s*(?:R\$\s*)?([\d\.,]+)', caseSensitive: false);
    final avgRegex = RegExp(r'M[eé]dio:\s*(?:R\$\s*)?([\d\.,]+)', caseSensitive: false);
    final maxRegex = RegExp(r'Maior:\s*(?:R\$\s*)?([\d\.,]+)', caseSensitive: false);

    final mMatch = minRegex.firstMatch(content);
    if (mMatch != null) minPrice = parseBrlPrice(mMatch.group(1));

    final aMatch = avgRegex.firstMatch(content);
    if (aMatch != null) avgPrice = parseBrlPrice(aMatch.group(1));

    final xMatch = maxRegex.firstMatch(content);
    if (xMatch != null) maxPrice = parseBrlPrice(xMatch.group(1));

    // B. Pattern for sealed products / items: "Preços aplicados no Marketplace"
    // Followed by the lowest, average, highest prices
    if (minPrice == null) {
      final marketplaceSectionRegex = RegExp(
        r'Pre[cç]os\s+aplicados\s+no\s+Marketplace[\s\S]*?(R\$\s*[\d\.,]+)[\s\S]*?(R\$\s*[\d\.,]+)[\s\S]*?(R\$\s*[\d\.,]+)',
        caseSensitive: false,
      );
      final mpMatch = marketplaceSectionRegex.firstMatch(content);
      if (mpMatch != null) {
        minPrice = parseBrlPrice(mpMatch.group(1));
        avgPrice = parseBrlPrice(mpMatch.group(2));
        maxPrice = parseBrlPrice(mpMatch.group(3));
      }
    }

    // C. Pattern for "Preço Médio de Venda no Marketplace"
    if (minPrice == null) {
      final avgMarketplaceRegex = RegExp(
        r'Pre[cç]o\s+M[eé]dio\s+de\s+Venda\s+no\s+Marketplace[\s\S]*?(R\$\s*[\d\.,]+)',
        caseSensitive: false,
      );
      final avgMatch = avgMarketplaceRegex.firstMatch(content);
      if (avgMatch != null) {
        avgPrice = parseBrlPrice(avgMatch.group(1));
      }
    }

    // D. Extract from Store Listings Table (HTML or Markdown)
    String? bestStoreName;
    bool hasStock = (minPrice != null && minPrice > 0);

    // 1. Search for store name from Avatar or Vitrine labels
    final avatarStoreRegex = RegExp(
      r'Avatar\s+da\s+Loja\s+([^\]"\r\n]+)',
      caseSensitive: false,
    );
    final avatarMatch = avatarStoreRegex.firstMatch(content);
    if (avatarMatch != null && avatarMatch.group(1) != null) {
      final name = avatarMatch.group(1)!.trim();
      if (name.isNotEmpty && !name.toLowerCase().contains('loading') && !name.toLowerCase().contains('default')) {
        bestStoreName = name;
      }
    }

    if (bestStoreName == null) {
      final vitrineRegex = RegExp(
        r'Visualizar\s+vitrine\s+da\s+loja\s+([^"\r\n]+)\s+dentro\s+do\s+Marketplace',
        caseSensitive: false,
      );
      final vitrineMatch = vitrineRegex.firstMatch(content);
      if (vitrineMatch != null && vitrineMatch.group(1) != null) {
        final name = vitrineMatch.group(1)!.trim();
        if (name.isNotEmpty) {
          bestStoreName = name;
        }
      }
    }

    // 2. Search for showcase link with store title in markdown: [Nome](...showcase/home...)
    if (bestStoreName == null) {
      final showcaseLinkRegex = RegExp(
        r'\[([^\]\n\r!]+)\]\([^\)]*(?:mp\/)?showcase\/home[^\)]*\)',
        caseSensitive: false,
      );
      for (final match in showcaseLinkRegex.allMatches(content)) {
        final candidate = match.group(1)?.trim() ?? '';
        if (candidate.isNotEmpty &&
            !candidate.toLowerCase().contains('ver vitrine') &&
            !candidate.toLowerCase().contains('loja verificada') &&
            !candidate.toLowerCase().contains('loja física') &&
            !candidate.toLowerCase().contains('loja fisica') &&
            !candidate.toLowerCase().contains('image') &&
            candidate.length < 50) {
          bestStoreName = candidate;
          break;
        }
      }
    }

    // 3. Search HTML patterns: alt, title, store-name class
    if (bestStoreName == null) {
      final htmlStoreRegex = RegExp(
        r'(?:class=["\x27](?:mp-)?(?:store-name|loja-nome)["\x27][^>]*>|alt=["\x27]Avatar\s+da\s+Loja\s+([^"\x27]+)["\x27]|title=["\x27](?:Visualizar vitrine da loja )?([^"\x27]+)["\x27][^>]*class=["\x27][^"\x27]*showcase[^"\x27]*["\x27])([^<"]+)?',
        caseSensitive: false,
      );
      final htmlMatch = htmlStoreRegex.firstMatch(content);
      if (htmlMatch != null) {
        final candidate = (htmlMatch.group(1) ?? htmlMatch.group(2) ?? htmlMatch.group(3))?.trim();
        if (candidate != null &&
            candidate.isNotEmpty &&
            !candidate.toLowerCase().contains('loja verificada') &&
            !candidate.toLowerCase().contains('loja física')) {
          bestStoreName = candidate;
        }
      }
    }

    // Collect all prices mentioned in the store marketplace section
    final storesSectionRegex = RegExp(
      r'Lojas\s+Vendendo[\s\S]*?(?:$|Hist[oó]rico|Vendas|Filtros)',
      caseSensitive: false,
    );
    final storeSection = storesSectionRegex.firstMatch(content)?.group(0) ?? content;

    final allPrices = RegExp(r'R\$\s*([\d\.,]+)')
        .allMatches(storeSection)
        .map((m) => parseBrlPrice(m.group(1)))
        .whereType<double>()
        .where((p) => p > 0)
        .toList();

    if (allPrices.isNotEmpty) {
      allPrices.sort();
      hasStock = true;
      if (minPrice == null || allPrices.first < minPrice) {
        minPrice = allPrices.first;
      }
      if (maxPrice == null || allPrices.last > maxPrice) {
        maxPrice = allPrices.last;
      }
    }

    // If still null, check if any price was found in the whole page
    if (minPrice == null) {
      final fallbackPrices = RegExp(r'R\$\s*([\d\.,]+)')
          .allMatches(content)
          .map((m) => parseBrlPrice(m.group(1)))
          .whereType<double>()
          .where((p) => p > 0)
          .toList();
      if (fallbackPrices.isNotEmpty) {
        fallbackPrices.sort();
        minPrice = fallbackPrices.first;
        hasStock = true;
      }
    }

    // If product has stock/price, ensure a store name exists
    if (hasStock && (bestStoreName == null || bestStoreName.isEmpty)) {
      bestStoreName = 'Marketplace (LigaPokémon)';
    }

    return LigaScrapedProduct(
      title: title,
      imageUrl: imageUrl,
      lowestPrice: minPrice,
      averagePrice: avgPrice,
      highestPrice: maxPrice,
      isPreSale: isPreSale,
      storeName: bestStoreName,
      productUrl: targetUrl,
      hasStock: hasStock,
    );
  }

  /// Checks an alert against live LigaPokemon data and triggers a notification if condition is met
  static Future<LigaCheckResult> checkAlert({
    required LigaPriceAlert alert,
    required AppDatabase db,
    bool notify = true,
  }) async {
    final product = await fetchProductDetails(alert.targetUrl);
    if (product == null) {
      return const LigaCheckResult(
        success: false,
        message: 'Não foi possível carregar os dados da LigaPokémon.',
      );
    }

    final price = product.lowestPrice;
    final isPreSale = product.isPreSale;
    final hasStock = product.hasStock;

    // Check if pre-sale is allowed when the product is in pre-sale
    final passesPreSaleFilter = !isPreSale || alert.allowPreSale;

    // Check price bounds
    bool isInRange = false;
    if (hasStock && price != null && price > 0 && passesPreSaleFilter) {
      final minOk = alert.minTargetPrice <= 0 || price >= alert.minTargetPrice;
      final maxOk = alert.maxTargetPrice <= 0 || price <= alert.maxTargetPrice;
      isInRange = minOk && maxOk;
    }

    final now = DateTime.now();
    bool shouldNotify = false;

    // Determine notification cooldown (once per 2 hours unless never notified)
    if (isInRange && alert.isActive && notify) {
      if (alert.lastNotifiedAt == null) {
        shouldNotify = true;
      } else {
        final diff = now.difference(alert.lastNotifiedAt!);
        if (diff.inHours >= 2) {
          shouldNotify = true;
        }
      }
    }

    // Trigger local notification
    if (shouldNotify && price != null) {
      final priceStr = 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
      final preSalePrefix = isPreSale ? '🔥 [PRÉ-VENDA] ' : '🎯 ';
      final notifTitle = '$preSalePrefix${alert.title} na faixa desejada!';
      final storeInfo = product.storeName != null ? ' (${product.storeName})' : '';
      final preSaleInfo = isPreSale ? ' em condição de pré-venda.' : '.';
      final notifBody = 'Encontrado por $priceStr na LigaPokémon$storeInfo$preSaleInfo';

      await NotificationService.showPriceAlertNotification(
        id: alert.id.hashCode,
        title: notifTitle,
        body: notifBody,
        payload: alert.targetUrl,
      );
    }

    // Update database record
    await db.updateLigaAlert(
      alert.toCompanion(true).copyWith(
        currentLowestPrice: Value(price),
        currentStoreName: Value(
          (product.storeName != null && product.storeName!.isNotEmpty)
              ? product.storeName!
              : (alert.currentStoreName.isNotEmpty
                  ? alert.currentStoreName
                  : (price != null && price > 0 ? 'Marketplace (LigaPokémon)' : '')),
        ),
        isPreSale: Value(isPreSale),
        isAvailableInRange: Value(isInRange),
        imageUrl: Value(product.imageUrl.isNotEmpty ? product.imageUrl : alert.imageUrl),
        lastCheckedAt: Value(now),
        lastNotifiedAt: shouldNotify ? Value(now) : const Value.absent(),
      ),
    );

    return LigaCheckResult(
      success: true,
      product: product,
      isInRange: isInRange,
    );
  }

  /// Checks all active alerts in sequence with a friendly delay between requests to avoid rate limits
  static Future<int> checkAllActiveAlerts({
    required AppDatabase db,
    bool notify = true,
  }) async {
    final activeAlerts = await db.getAllActiveLigaAlerts();
    int triggeredCount = 0;

    for (final alert in activeAlerts) {
      final result = await checkAlert(alert: alert, db: db, notify: notify);
      if (result.isInRange) {
        triggeredCount++;
      }
      // Polite delay between LigaPokemon requests
      await Future.delayed(const Duration(milliseconds: 700));
    }

    return triggeredCount;
  }
}
