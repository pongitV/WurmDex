import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/marketplace_url_helper.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/language_flag_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../catalog/models/pokemon_card_item.dart';
import '../../models/monitored_card_item.dart';
import 'edit_purchase_price_dialog.dart';

class MonitoredCardTile extends StatelessWidget {
  final MonitoredCardItem item;
  final double exchangeRate;
  final AppCurrency currency;
  final AppStrings strings;
  final bool showFolderTag;

  const MonitoredCardTile({
    super.key,
    required this.item,
    required this.exchangeRate,
    required this.currency,
    required this.strings,
    this.showFolderTag = false,
  });

  void _openDetails(BuildContext context) {
    final catalogCard = PokemonCardItem(
      id: item.card.cardApiId,
      name: item.card.name,
      number: item.card.number,
      setId: item.card.setName.toLowerCase().replaceAll(' ', '-'),
      setName: item.card.setName,
      rarity: item.card.rarity,
      imageUrlSmall: item.card.imageUrl,
      imageUrlLarge: item.card.imageUrl,
      types: const ['Colorless'],
      supertype: 'Pokémon',
      artist: '',
      tcgMarketUsd: item.estimatedCurrentPriceBrl / (exchangeRate > 0 ? exchangeRate : 5.60),
    );

    AppNavigator.toCardDetails(
      context,
      catalogCard,
      userCardId: item.card.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = item.card;
    final rate = exchangeRate > 0 ? exchangeRate : 5.60;
    final isUsd = currency == AppCurrency.usd;

    final formattedTitle = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
    );

    final currentFormatted = isUsd
        ? CurrencyFormatter.toUsd(item.estimatedCurrentPriceBrl / rate)
        : CurrencyFormatter.toBrl(item.estimatedCurrentPriceBrl);

    final paidFormatted = item.purchasePriceBrl > 0
        ? (isUsd
            ? CurrencyFormatter.toUsd(item.purchasePriceBrl / rate)
            : CurrencyFormatter.toBrl(item.purchasePriceBrl))
        : null;

    final diffFormatted = isUsd
        ? CurrencyFormatter.toUsd(item.nominalDifferenceBrl.abs() / rate)
        : CurrencyFormatter.toBrl(item.nominalDifferenceBrl.abs());

    final pctFormatted = '${item.percentageChange >= 0 ? '+' : ''}${item.percentageChange.toStringAsFixed(1)}%';

    final Color badgeColor;
    final IconData trendIcon;
    if (item.isSurging) {
      badgeColor = AppColors.profitGreen;
      trendIcon = Icons.arrow_drop_up;
    } else if (item.isDropping) {
      badgeColor = AppColors.lossRed;
      trendIcon = Icons.arrow_drop_down;
    } else {
      badgeColor = Colors.blueGrey;
      trendIcon = Icons.horizontal_rule;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Card Artwork Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: PokemonCardImage(
                  imageUrl: card.imageUrl,
                  width: 48,
                  height: 68,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),

              // Card Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.setName,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ConditionBadge(
                          condition: card.condition,
                          compact: true,
                        ),
                        const SizedBox(width: 4),
                        LanguageFlagBadge(
                          language: card.language,
                          compact: true,
                        ),
                        if (card.quantity > 1) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${card.quantity}x',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        if (showFolderTag && item.folderName != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: (item.folderColor ?? theme.colorScheme.primary).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.folderName!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: item.folderColor ?? theme.colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Price & ROI Tracking Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    paidFormatted != null
                        ? '${strings.paidPricePrefix}$paidFormatted'
                        : strings.noPricePaid,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, size: 14, color: badgeColor),
                        Text(
                          '${item.nominalDifferenceBrl >= 0 ? '+' : '-'}$diffFormatted ($pctFormatted)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Context Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                tooltip: strings.quickActionsTooltip,
                onSelected: (val) {
                  if (val == 'details') {
                    _openDetails(context);
                  } else if (val == 'edit_price') {
                    EditPurchasePriceDialog.show(
                      context,
                      card: card,
                      strings: strings,
                      exchangeRate: rate,
                      currency: currency,
                    );
                  } else if (val == 'liga') {
                    MarketplaceUrlHelper.openLigaPokemon(context, cardName: card.name);
                  } else if (val == 'tcg') {
                    MarketplaceUrlHelper.openTcgPlayer(context, cardName: card.name, cardNumber: card.number);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        const Icon(Icons.query_stats, size: 18),
                        const SizedBox(width: 8),
                        Text(strings.actionViewDetails),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit_price',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(strings.btnEditPurchasePrice),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'liga',
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_browser, size: 18),
                        const SizedBox(width: 8),
                        Text(strings.openInLiga),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'tcg',
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_browser, size: 18),
                        const SizedBox(width: 8),
                        Text(strings.openInTcgPlayer),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
