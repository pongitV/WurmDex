import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'app_image_headers.dart';

/// Cached response entry with expiration.
class _CacheEntry {
  final Response response;
  final DateTime expiresAt;

  _CacheEntry({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Centralized HTTP client configured with retry resilience and in-memory TTL caching.
class DioClient {
  static final Map<String, _CacheEntry> _cache = {};

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 25),
        headers: {
          'User-Agent': AppImageHeaders.browserUserAgent,
          'Accept': 'application/json, text/plain, */*',
          'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ),
    );

    // In-memory cache interceptor for GET requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.method.toUpperCase() == 'GET') {
            final cacheKey = options.uri.toString();
            final cached = _cache[cacheKey];
            if (cached != null && !cached.isExpired) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  data: cached.response.data,
                  statusCode: cached.response.statusCode,
                  statusMessage: cached.response.statusMessage,
                  headers: cached.response.headers,
                ),
              );
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.requestOptions.method.toUpperCase() == 'GET' &&
              response.statusCode == 200 &&
              response.data != null) {
            final cacheKey = response.requestOptions.uri.toString();
            // Cache static sets and catalog data for 10 minutes
            _cache[cacheKey] = _CacheEntry(
              response: response,
              expiresAt: DateTime.now().add(const Duration(minutes: 10)),
            );
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Automatic retry once on transient connection timeout or 429/503
          final shouldRetry = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.response?.statusCode == 429 ||
              error.response?.statusCode == 503;

          final retries = error.requestOptions.extra['retries'] as int? ?? 0;

          if (shouldRetry && retries < 2) {
            error.requestOptions.extra['retries'] = retries + 1;
            await Future.delayed(Duration(milliseconds: 600 * (retries + 1)));
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              debugPrint('Dio retry failed: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Dio get instance => _dio;

  /// Clears in-memory cache (e.g. on manual pull-to-refresh)
  static void clearCache() {
    _cache.clear();
  }
}
