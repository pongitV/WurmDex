import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/constants/app_constants.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/navigation/app_navigator.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/core/theme/app_colors.dart';
import 'package:wurmdex/core/utils/card_pricing_helper.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/core/utils/marketplace_url_helper.dart';
import 'package:wurmdex/core/utils/semantic_search_helper.dart';
import 'package:wurmdex/core/widgets/app_network_image.dart';
import 'package:wurmdex/core/widgets/bottom_sheet_drag_handle.dart';
import 'package:wurmdex/core/widgets/condition_badge.dart';
import 'package:wurmdex/core/widgets/language_flag_badge.dart';
import 'package:wurmdex/core/widgets/pokemon_card_image.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';

class BinderPocketCard extends ConsumerWidget {
  final UserCard card;
  final AppStrings strings;

  const BinderPocketCard({
    super.key,
    required this.card,
    required this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);
    final effectiveBrl = CardPricingHelper.getRealisticMarketPriceBrl(
      cardApiId: card.cardApiId,
      cardName: card.name,
      cardNumber: card.number,
      setName: card.setName,
      purchasePriceBrl: card.purchasePriceBrl,
      rarity: card.rarity,
      condition: card.condition,
      exchangeRate: exchangeRate,
    );
    final String priceDisplay = currency == AppCurrency.usd
        ? CurrencyFormatter.toUsd(effectiveBrl / exchangeRate)
        : CurrencyFormatter.toBrl(effectiveBrl);

    final title = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
    );

    return Tooltip(
      message: '$title\n${card.setName} - ${card.condition}',
      child: InkWell(
        onTap: () {
          final item = PokemonCardItem(
            id: card.cardApiId,
            name: card.name,
            number: card.number,
            setId: card.setName.toLowerCase().replaceAll(' ', '-'),
            setName: card.setName,
            rarity: card.rarity.isNotEmpty ? card.rarity : strings.defaultRarity,
            imageUrlSmall: card.imageUrl,
            imageUrlLarge: card.imageUrl,
            types: const [],
            supertype: 'Pokémon',
            artist: '',
            tcgMarketUsd: effectiveBrl / exchangeRate,
          );
          AppNavigator.toCardDetails(context, item, userCardId: card.id);
        },
        onLongPress: () => _showPocketContextMenu(context, ref),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          child: Center(
            child: AspectRatio(
              aspectRatio: AppConstants.pokemonCardAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  PokemonCardImage(
                    imageUrl: card.imageUrl,
                    fit: BoxFit.contain,
                  ),
                  // Plastic Sleeve Reflection (Top diagonal sheen)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: const Alignment(0.4, 0.4),
                            colors: [
                              Colors.white.withValues(alpha: 0.16),
                              Colors.white.withValues(alpha: 0.03),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Finish badge (top-left)
                  if (card.finish != 'Regular')
                    Positioned(
                      top: 2,
                      left: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.wurmpleSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          card.finish,
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  // Quantity badge (top-right)
                  if (card.quantity > 1)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Text(
                          'x${card.quantity}',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                  // Condition / Quality & Price bottom overlay pill
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConditionBadge(
                            condition: card.condition,
                            compact: true,
                          ),
                          const SizedBox(width: 3),
                          LanguageFlagBadge(
                            language: card.language,
                            compact: true,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            priceDisplay,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.profitGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPocketContextMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final title = SemanticSearchHelper.formatCardIdentifier(
      rawName: card.name,
      number: card.number,
    );

    showAppModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragHandle(bottomPadding: 8),
              ListTile(
                leading: AppNetworkImage(
                  imageUrl: card.imageUrl,
                  width: 36,
                  height: 50,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(4),
                  fallbackIcon: Icons.style,
                  fallbackIconSize: 24,
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${card.setName} • ${card.condition} • x${card.quantity}'),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                title: Text(strings.viewQuoteAndHistory),
                onTap: () {
                  Navigator.pop(ctx);
                  final liveRate = ref.read(exchangeRateProvider);
                  final item = PokemonCardItem(
                    id: card.cardApiId,
                    name: card.name,
                    number: card.number,
                    setId: card.setName.toLowerCase().replaceAll(' ', '-'),
                    setName: card.setName,
                    rarity: card.rarity.isNotEmpty ? card.rarity : strings.defaultRarity,
                    imageUrlSmall: card.imageUrl,
                    imageUrlLarge: card.imageUrl,
                    types: const [],
                    supertype: 'Pokémon',
                    artist: '',
                    tcgMarketUsd: card.purchasePriceBrl > 0 ? (card.purchasePriceBrl / liveRate) : 0.0,
                  );
                  AppNavigator.toCardDetails(context, item, userCardId: card.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.blue),
                title: Text(strings.openInLiga),
                onTap: () {
                  Navigator.pop(ctx);
                  MarketplaceUrlHelper.openLigaPokemon(context, cardName: card.name);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.orange),
                title: Text(strings.openInTcgPlayer),
                onTap: () {
                  Navigator.pop(ctx);
                  MarketplaceUrlHelper.openTcgPlayer(context, cardName: card.name, cardNumber: card.number);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.lossRed),
                title: Text(strings.deleteFromCollection, style: const TextStyle(color: AppColors.lossRed, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteCard(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCard(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteCardTitle),
        content: Text(strings.confirmRemoveFromFolderMsg(card.name, card.number)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.lossRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.remove),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(databaseProvider).deleteCard(card.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.cardRemovedFromCollection(card.name))),
      );
    }
  }
}

class BinderEmptyPocket extends StatelessWidget {
  final VoidCallback onAdd;
  final String label;

  const BinderEmptyPocket({
    super.key,
    required this.onAdd,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 28,
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.dividerColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
