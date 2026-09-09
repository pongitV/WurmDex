/// Centralized HTTP headers for network requests and image loading.
/// Ensures standard modern browser User-Agent headers to prevent anti-scraping
/// blocks, rate limits, and broken CDN responses.
class AppImageHeaders {
  static const String browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36';

  static const String scraperUserAgent =
      'WurmDex/1.0 (Pokemon TCG Tracker; Android/Windows)';

  static const String imageAcceptHeader =
      'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';

  /// Standard headers to attach to network image requests
  static const Map<String, String> common = {
    'User-Agent': browserUserAgent,
    'Accept': imageAcceptHeader,
  };

  /// Headers to attach to scraper requests
  static const Map<String, String> scraper = {
    'User-Agent': scraperUserAgent,
    'Accept': 'text/plain, text/markdown, application/json, */*',
  };
}
