import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/semantic_search_helper.dart';
import '../../../../core/widgets/card_description_badges.dart';
import '../../../../core/widgets/condition_badge.dart';
import '../../../../core/widgets/pokemon_card_image.dart';
import '../../../../core/widgets/language_flag_badge.dart';
import '../../../../core/widgets/folder_badge.dart';
import '../../../catalog/models/pokemon_card_item.dart';

/// List card for a wishlist item, mirroring the LigaRadar monitored-item card
/// but driven by the last known card market price.
class WishlistCardTile extends StatelessWidget {
  final WishlistItem item;
  final bool isUsd;
  final double exchangeRate;
  final AppStrings strings;
  final bool isChecking;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;
  final VoidCallback onOpenLiga;
  final VoidCallback onDelete;

  const WishlistCardTile({
    super.key,
    required this.item,
    required this.isUsd,
    required this.exchangeRate,
    required this.strings,
    this.isChecking = false,
    required this.onEdit,
    required this.onRefresh,
    required this.onOpenLiga,
    required this.onDelete,
  });

  double get _price => item.currentPriceBrl ?? 0;

  bool get _isInRange {
    if (_price <= 0) return false;
    if (item.minTargetPriceBrl > 0 && _price < item.minTargetPriceBrl) {
      return false;
    }
    return _price <= item.targetPriceBrl;
  }

  String _fmt(double value) => isUsd
      ? CurrencyFormatter.toUsd(value / exchangeRate)
      : CurrencyFormatter.toBrl(value);

  (Color, String) _status() {
    if (_price > 0) {
      if (_isInRange) {
        return (Colors.green, strings.statusInRange);
      }
      return (Colors.amber.shade800, strings.statusAboveRange);
    }
    return (
      Colors.grey,
      item.lastCheckedAt == null
          ? strings.statusPending
          : strings.statusOutOfStock,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = SemanticSearchHelper.formatCardIdentifier(
      rawName: item.name,
      number: item.number,
    );
    final (statusColor, statusText) = _status();

    final priceEnabled = _price > 0;
    final priceText = priceEnabled
        ? _fmt(_price)
        : (item.lastCheckedAt == null
            ? strings.statusPending
            : strings.statusOutOfStock);
    final minTargetText = item.minTargetPriceBrl > 0
        ? _fmt(item.minTargetPriceBrl)
        : 'R\$ 0';
    final maxTargetText = item.targetPriceBrl > 0
        ? _fmt(item.targetPriceBrl)
        : strings.noPriceCeiling;
    final folderBadge = item.folderName.isNotEmpty &&
            item.folderName != 'Geral'
        ? item.folderName
        : strings.wishlistFolderDefault;
    final checkedText = item.lastCheckedAt != null
        ? '${strings.lastCheckedPrefix}${item.lastCheckedAt!.hour.toString().padLeft(2, '0')}:${item.lastCheckedAt!.minute.toString().padLeft(2, '0')}'
        : '${strings.lastCheckedPrefix}${strings.neverChecked}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: _isInRange ? Colors.green.withValues(alpha: 0.12) : null,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _isInRange
              ? Colors.green
              : theme.colorScheme.outlineVariant,
          width: _isInRange ? 1.5 : 1,
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
            tcgMarketUsd: _price > 0 ? _price / exchangeRate : 0,
          );
          AppNavigator.toCardDetails(context, catalogCard);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 92,
                    height: 124,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: _isInRange
                              ? Colors.green
                              : theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: PokemonCardImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          checkedText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            RangeStatusBadge(
                              color: statusColor,
                              text: statusText,
                              compact: true,
                            ),
                            if (item.isPreSale)
                              PreSaleStatusBadge(
                                label: strings.statusPreSale.toUpperCase(),
                                compact: true,
                              ),
                            ConditionBadge(
                              condition: item.condition,
                              compact: true,
                            ),
                            if (item.folderName.isNotEmpty)
                              FolderBadge(
                                folderName: folderBadge,
                                compact: true,
                              ),
                            LanguageFlagBadge(
                              language: item.language,
                              compact: true,
                              showCode: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _isInRange
                                ? Colors.green.withValues(alpha: 0.12)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isInRange
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : theme.colorScheme.outlineVariant.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                          ),
                          child: Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.price_check,
                                                size: 14,
                                                color: _isInRange
                                                    ? Colors.green.shade700
                                                    : theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  strings
                                                      .currentLowestPriceHeader,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    letterSpacing: 0.4,
                                                    color: _isInRange
                                                        ? Colors.green.shade700
                                                        : theme.colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              priceText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: _isInRange
                                                    ? Colors.green.shade700
                                                    : (priceEnabled
                                                        ? theme
                                                            .colorScheme
                                                            .primary
                                                        : theme.colorScheme
                                                            .onSurfaceVariant),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.6),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.style_outlined,
                                                size: 14,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  strings.collectionLabel,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    letterSpacing: 0.4,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface
                                                  .withValues(alpha: 0.9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: theme.colorScheme
                                                    .outlineVariant
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                            child: Text(
                                              item.setName.isNotEmpty
                                                  ? item.setName
                                                  : strings
                                                      .marketplaceFallback,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.tune,
                                    size: 12,
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    strings.targetRangeLabelText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$minTargetText - $maxTargetText',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 20),
                    tooltip: strings.refreshTooltip,
                    onPressed: isChecking ? null : onRefresh,
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: strings.openInLiga,
                    onPressed: onOpenLiga,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: strings.editWishlistItem,
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                    tooltip: strings.remove,
                    onPressed: onDelete,
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