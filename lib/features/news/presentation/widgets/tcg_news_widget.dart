import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/tcg_news_item.dart';
import '../../services/tcg_news_service.dart';

class TcgNewsWidget extends ConsumerStatefulWidget {
  const TcgNewsWidget({super.key});

  @override
  ConsumerState<TcgNewsWidget> createState() => _TcgNewsWidgetState();
}

class _TcgNewsWidgetState extends ConsumerState<TcgNewsWidget> {
  late Future<List<TcgNewsItem>> _newsFuture;
  String _selectedSource = 'ALL';

  @override
  void initState() {
    super.initState();
    _newsFuture = TcgNewsService.fetchLiveNews();
  }

  void _refreshNews() {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.feed_outlined, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
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
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: strings.btnRefreshNews,
                onPressed: _refreshNews,
              ),
            ],
          ),
        ),
        // Source Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(strings.chipAll, filterKey: 'ALL'),
                const SizedBox(width: 8),
                _buildFilterChip(strings.chipPokemonOfficial, filterKey: 'Pokemon.com'),
                const SizedBox(width: 8),
                _buildFilterChip(strings.chipBillsArchive, filterKey: "Bill's Archive"),
                const SizedBox(width: 8),
                _buildFilterChip(strings.chipTcgScene, filterKey: 'Scene'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
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
                        onPressed: _refreshNews,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Filter news based on selected source
            final filtered = allNews.where((item) {
              if (_selectedSource == 'ALL') return true;
              if (_selectedSource == "Bill's Archive") {
                return item.id.startsWith('bills_') || item.source.contains("Bill's Archive");
              }
              if (_selectedSource == 'Pokemon.com') {
                return item.id.startsWith('pokemon_') || item.source.contains('Pokemon.com');
              }
              if (_selectedSource == 'Scene') {
                return item.id.startsWith('scene_') ||
                    item.source.contains('Scene') ||
                    item.source.contains('Cenário') ||
                    item.category == 'COMPETITIVE' ||
                    item.category == 'MERCADO';
              }
              return true;
            }).toList();

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

  Widget _buildFilterChip(String label, {String? filterKey}) {
    final key = filterKey ?? label;
    final isSelected = _selectedSource == key;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedSource = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.22)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.25),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, TcgNewsItem item, ThemeData theme) {
    final isBills = item.id.startsWith('bills_') || item.source.contains("Bill's Archive");
    final isScene = item.id.startsWith('scene_') || item.source.contains('Scene') || item.source.contains('Cenário');
    final isPt = item.source.contains('Oficial') || item.source.contains('PT-BR');

    final Color sourceColor;
    if (isBills) {
      sourceColor = const Color(0xFF9B6DFF);
    } else if (isScene) {
      sourceColor = const Color(0xFFF59E0B);
    } else if (isPt) {
      sourceColor = AppColors.profitGreen;
    } else {
      sourceColor = const Color(0xFF38BDF8);
    }

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
                        // Source Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sourceColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: sourceColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            item.source,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: sourceColor,
                            ),
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
