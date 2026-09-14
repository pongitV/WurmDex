import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/news_filter_state.dart';
import '../../models/tcg_news_item.dart';
import '../../services/tcg_news_service.dart';

class TcgNewsWidget extends ConsumerStatefulWidget {
  final NewsFilterState? filterState;
  final ValueChanged<String>? onSourceChanged;

  const TcgNewsWidget({
    super.key,
    this.filterState,
    this.onSourceChanged,
  });

  @override
  ConsumerState<TcgNewsWidget> createState() => TcgNewsWidgetState();
}

class TcgNewsWidgetState extends ConsumerState<TcgNewsWidget> {
  late Future<List<TcgNewsItem>> _newsFuture;
  final String _selectedSource = 'ALL';

  @override
  void initState() {
    super.initState();
    _newsFuture = TcgNewsService.fetchLiveNews();
  }

  void refreshNews() {
    final isEn = ref.read(languageProvider) == AppLanguage.enUs;
    setState(() {
      _newsFuture = TcgNewsService.fetchLiveNews(forceRefresh: true, isEn: isEn);
    });
  }

  Future<void> _openNewsLink(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    try {
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!mounted) return;
      if (!launched) {
        final strings = getStrings(ref.read(languageProvider));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.errOpenNews)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      final strings = getStrings(ref.read(languageProvider));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.errOpenNewsLink)),
      );
    }
  }

  String get effectiveSource => widget.filterState?.selectedSource ?? _selectedSource;
  String get effectiveCategory => widget.filterState?.selectedCategory ?? 'ALL';
  NewsSortOption get effectiveSort => widget.filterState?.sortOption ?? NewsSortOption.newest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            strings.sectionNews,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FutureBuilder<List<TcgNewsItem>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2),
                      const SizedBox(height: 8),
                      Text(strings.fetchingNews, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            final allNews = snapshot.data ?? [];
            if (allNews.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.wifi_off, size: 28, color: Colors.grey),
                      const SizedBox(height: 6),
                      Text(strings.noNewsFound, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text(strings.tapRefreshNews),
                        onPressed: refreshNews,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Filter news based on selected source & category
            List<TcgNewsItem> filtered = allNews.where((item) {
              if (effectiveSource != 'ALL') {
                if (effectiveSource == "Bill's Archive") {
                  if (!(item.id.startsWith('bills_') || item.source.contains("Bill's Archive"))) {
                    return false;
                  }
                } else if (effectiveSource == 'Pokemon.com') {
                  if (!(item.id.startsWith('pokemon_') || item.source.contains('Pokemon.com'))) {
                    return false;
                  }
                } else if (effectiveSource == 'Scene') {
                  if (!(item.id.startsWith('scene_') ||
                      item.source.contains('Scene') ||
                      item.source.contains('Cenário') ||
                      item.category == 'COMPETITIVE' ||
                      item.category == 'MERCADO')) {
                    return false;
                  }
                } else if (effectiveSource == 'TCGTalk') {
                  if (!(item.id.startsWith('tcgtalk_') || item.source.contains('TCGTalk'))) {
                    return false;
                  }
                }
              }

              if (effectiveCategory != 'ALL') {
                final cat = item.category.toUpperCase();
                if (effectiveCategory == 'SETS_PRODUCTS') {
                  if (!cat.contains('EXPAN') && !cat.contains('SET') && !cat.contains('PROD')) {
                    return false;
                  }
                } else if (effectiveCategory == 'COMPETITIVE') {
                  if (!cat.contains('COMPET') && !cat.contains('SCENE') && !cat.contains('MERCADO')) {
                    return false;
                  }
                } else if (effectiveCategory == 'COMMUNITY') {
                  if (!cat.contains('TALK') && !cat.contains('COMUNIDADE') && !cat.contains('COMMUNITY')) {
                    return false;
                  }
                }
              }
              return true;
            }).toList();

            // Apply Sort
            switch (effectiveSort) {
              case NewsSortOption.newest:
                break;
              case NewsSortOption.oldest:
                filtered = filtered.reversed.toList();
                break;
              case NewsSortOption.titleAsc:
                filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
                break;
              case NewsSortOption.source:
                filtered.sort((a, b) => a.source.toLowerCase().compareTo(b.source.toLowerCase()));
                break;
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: filtered.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _buildNewsCard(context, item, theme);
              },
            );
          },
        ),
      ],
    );
  }

  static (Color, IconData) getSourceStyle(String source, String id) {
    final lowerSource = source.toLowerCase();
    final lowerId = id.toLowerCase();

    if (lowerId.startsWith('bills_') || lowerSource.contains("bill's archive")) {
      return (const Color(0xFF8B5CF6), Icons.inventory_2_outlined);
    } else if (lowerId.startsWith('scene_') || lowerSource.contains('scene') || lowerSource.contains('cenário')) {
      return (const Color(0xFFF59E0B), Icons.emoji_events_outlined);
    } else if (lowerId.startsWith('tcgtalk_') || lowerSource.contains('tcgtalk')) {
      return (const Color(0xFF06B6D4), Icons.forum_outlined);
    } else if (lowerId.startsWith('pokemon_') || lowerSource.contains('pokemon.com') || lowerSource.contains('oficial')) {
      return (const Color(0xFFEF4444), Icons.verified_outlined);
    }
    return (const Color(0xFF3B82F6), Icons.newspaper);
  }

  Widget _buildNewsCard(BuildContext context, TcgNewsItem item, ThemeData theme) {
    final (sourceColor, sourceIcon) = getSourceStyle(item.source, item.id);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openNewsLink(item.url),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // News Image Thumbnail
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                AppNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: 88,
                  height: 76,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                  fallbackIcon: Icons.broken_image,
                  fallbackIconSize: 28,
                ),
                const SizedBox(width: 12),
              ],
              // News Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Source Badge with distinct icon & color
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: sourceColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: sourceColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(sourceIcon, size: 11, color: sourceColor),
                              const SizedBox(width: 4),
                              Text(
                                item.source,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: sourceColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (item.category.isNotEmpty) ...[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(Icons.open_in_new, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.summary.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.summary,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
