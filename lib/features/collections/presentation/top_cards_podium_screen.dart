import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/widgets/condition_badge.dart';
import '../../../core/widgets/pokemon_card_image.dart';
import '../../monitoring/models/monitored_card_item.dart';
import 'widgets/top_cards_widget.dart';

class TopCardsPodiumScreen extends ConsumerWidget {
  final List<MonitoredCardItem> topMonitored;

  const TopCardsPodiumScreen({super.key, required this.topMonitored});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);
    final isUsd = ref.watch(currencyProvider) == AppCurrency.usd;
    final effectiveRate = ref.watch(exchangeRateProvider);

    final ranked = List.of(topMonitored)
      ..sort((a, b) => b.estimatedCurrentPriceBrl.compareTo(a.estimatedCurrentPriceBrl));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.top10ValuableCards,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ranked.isEmpty
          ? const Center(child: Text('No cards'))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _PodiumSection(
                  podium: ranked.take(3).toList(),
                  strings: strings,
                  theme: theme,
                  isUsd: isUsd,
                  effectiveRate: effectiveRate,
                ),
                if (ranked.length > 3) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      strings.ranked4To10Title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...ranked.skip(3).map((item) => _RankCardTile(
                        item: item,
                        rank: ranked.indexOf(item) + 1,
                        isUsd: isUsd,
                        effectiveRate: effectiveRate,
                      )),
                ],
              ],
            ),
    );
  }
}

class _PodiumSection extends StatelessWidget {
  final List<MonitoredCardItem> podium;
  final AppStrings strings;
  final ThemeData theme;
  final bool isUsd;
  final double effectiveRate;

  const _PodiumSection({
    required this.podium,
    required this.strings,
    required this.theme,
    required this.isUsd,
    required this.effectiveRate,
  });

  @override
  Widget build(BuildContext context) {
    final rank1 = podium.isNotEmpty ? podium[0] : null;
    final rank2 = podium.length > 1 ? podium[1] : null;
    final rank3 = podium.length > 2 ? podium[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            strings.podiumTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: rank2 != null
                    ? _PodiumRank(
                        item: rank2,
                        rank: 2,
                        imageHeight: 76,
                        blockHeight: 46,
                        rankColor: Colors.blueGrey,
                        isUsd: isUsd,
                        effectiveRate: effectiveRate,
                      )
                    : const SizedBox(height: 122),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: rank1 != null
                    ? _PodiumRank(
                        item: rank1,
                        rank: 1,
                        imageHeight: 96,
                        blockHeight: 68,
                        rankColor: Colors.amber.shade700,
                        isUsd: isUsd,
                        effectiveRate: effectiveRate,
                      )
                    : const SizedBox(height: 164),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: rank3 != null
                    ? _PodiumRank(
                        item: rank3,
                        rank: 3,
                        imageHeight: 62,
                        blockHeight: 34,
                        rankColor: Colors.brown.shade400,
                        isUsd: isUsd,
                        effectiveRate: effectiveRate,
                      )
                    : const SizedBox(height: 96),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumRank extends StatelessWidget {
  final MonitoredCardItem item;
  final int rank;
  final double imageHeight;
  final double blockHeight;
  final Color rankColor;
  final bool isUsd;
  final double effectiveRate;

  const _PodiumRank({
    required this.item,
    required this.rank,
    required this.imageHeight,
    required this.blockHeight,
    required this.rankColor,
    required this.isUsd,
    required this.effectiveRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        AppNavigator.toCardDetails(
          context,
          userCardToCatalogCard(item.card, item, effectiveRate: effectiveRate),
          userCardId: item.card.id,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              PokemonCardImage(
                imageUrl: item.card.imageUrl,
                width: imageHeight * 0.71,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 104,
            child: Text(
              item.card.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 104,
            child: Text(
              item.card.setName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            formatCardDisplayPrice(item, isUsd: isUsd, effectiveRate: effectiveRate),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.profitGreen,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Container(
            width: 112,
            height: blockHeight,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rank == 1)
                  Icon(Icons.emoji_events, size: 16, color: Colors.white)
                else
                  Icon(Icons.military_tech, size: 14, color: Colors.white),
                const SizedBox(height: 2),
                Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankCardTile extends StatelessWidget {
  final MonitoredCardItem item;
  final int rank;
  final bool isUsd;
  final double effectiveRate;

  const _RankCardTile({
    required this.item,
    required this.rank,
    required this.isUsd,
    required this.effectiveRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        AppNavigator.toCardDetails(
          context,
          userCardToCatalogCard(item.card, item, effectiveRate: effectiveRate),
          userCardId: item.card.id,
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          PokemonCardImage(
            imageUrl: item.card.imageUrl,
            width: 42,
            height: 58,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: -3,
            left: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        item.card.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              '${item.card.setName} (#${item.card.number})',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          ConditionBadge(condition: item.card.condition, compact: true),
          const SizedBox(width: 6),
          Text(
            '${item.card.quantity}x',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        formatCardDisplayPrice(item, isUsd: isUsd, effectiveRate: effectiveRate),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.profitGreen,
        ),
        maxLines: 1,
      ),
    );
  }
}