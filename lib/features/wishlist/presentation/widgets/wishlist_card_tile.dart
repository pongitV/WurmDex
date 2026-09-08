import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../catalog/models/pokemon_card_item.dart';

class WishlistCardTile extends StatelessWidget {
  final WishlistItem item;
  final bool isUsd;
  final double exchangeRate;
  final AppStrings strings;
  final VoidCallback onEdit;
  final VoidCallback onMoveToCollection;
  final VoidCallback onDelete;

  const WishlistCardTile({
    super.key,
    required this.item,
    required this.isUsd,
    required this.exchangeRate,
    required this.strings,
    required this.onEdit,
    required this.onMoveToCollection,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = SemanticSearchHelper.formatCardIdentifier(
      rawName: item.name,
      number: item.number,
    );

    final estMarketBrl = item.targetPriceBrl > 0 ? (item.targetPriceBrl * 0.95) : 25.0;
    final isOpportunity = item.targetPriceBrl > 0 && estMarketBrl <= item.targetPriceBrl;

    final targetPriceDisplay = isUsd
        ? CurrencyFormatter.toUsd(item.targetPriceBrl / exchangeRate)
        : CurrencyFormatter.toBrl(item.targetPriceBrl);

    final currentMarketDisplay = isUsd
        ? CurrencyFormatter.toUsd(estMarketBrl / exchangeRate)
        : CurrencyFormatter.toBrl(estMarketBrl);

    Color priorityColor;
    switch (item.priority) {
      case 'Alta':
      case 'High':
        priorityColor = AppColors.lossRed;
        break;
      case 'Média':
      case 'Medium':
        priorityColor = AppColors.warningYellow;
        break;
      default:
        priorityColor = AppColors.profitGreen;
    }

    String displayPriority = item.priority;
    if (item.priority == 'Alta' || item.priority == 'High') {
      displayPriority = strings.priorityHigh;
    } else if (item.priority == 'Média' || item.priority == 'Medium') {
      displayPriority = strings.priorityMedium;
    } else if (item.priority == 'Baixa' || item.priority == 'Low') {
      displayPriority = strings.priorityLow;
    }

    final folderBadge = item.folderName.isNotEmpty ? item.folderName : 'Geral';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOpportunity
              ? AppColors.profitGreen.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: () {
          final catalogCard = PokemonCardItem(
            id: item.cardApiId,
            name: item.name,
            number: item.number,
            setId: item.setName.toLowerCase().replaceAll(' ', '-'),
            setName: item.setName,
            rarity: 'Rare',
            imageUrlSmall: item.imageUrl,
            imageUrlLarge: item.imageUrl,
            types: const ['Colorless'],
            supertype: 'Pokémon',
            artist: '',
            tcgMarketUsd: estMarketBrl / exchangeRate,
          );
          AppNavigator.toCardDetails(context, catalogCard);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              PokemonCardImage(
                imageUrl: item.imageUrl,
                width: 48,
                height: 66,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),

              // Card info & prices
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Folder Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_outlined, size: 10, color: theme.colorScheme.primary),
                              const SizedBox(width: 3),
                              Text(
                                folderBadge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.setName,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            displayPriority,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: priorityColor,
                            ),
                          ),
                        ),

                        // Target Price
                        Text(
                          '${strings.targetPricePrefix}$targetPriceDisplay',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Current Market
                        Text(
                          '(${strings.currentMarketPrice}: $currentMarketDisplay)',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),

                        // Bargain / Opportunity Indicator
                        if (isOpportunity)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.profitGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 10, color: AppColors.profitGreen),
                                const SizedBox(width: 2),
                                Text(
                                  strings.goodOpportunity,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.profitGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (val) {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'move_to_collection') {
                    onMoveToCollection();
                  } else if (val == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(strings.editWishlistItem),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'move_to_collection',
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.profitGreen),
                        const SizedBox(width: 8),
                        Text(strings.wishlistMoveToCollection),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: AppColors.lossRed),
                        const SizedBox(width: 8),
                        Text(strings.tooltipRemoveFromWishlist),
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
