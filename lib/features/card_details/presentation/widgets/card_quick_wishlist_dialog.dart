import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/core/widgets/pokemon_card_image.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/wishlist/services/wishlist_folder_service.dart';

/// Add-card dialog for the wishlist, mirroring the LigaRadar product dialog:
/// price range (min - max), language, pre-order flag and folder selection.
/// Cards additionally carry a quality (condition) value.
class CardQuickWishlistDialog {
  static const List<String> _conditions = [
    'Mint',
    'Near Mint',
    'Slightly Played',
    'Moderately Played',
    'Heavily Played',
    'Damaged',
    'Graduada (PSA 10)',
    'Graduada (PSA 9)',
    'Graduada (BGS 9.5)',
    'Graduada (CGC 10)',
    'Graduada',
  ];

  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required PokemonCardItem card,
    required AppStrings strings,
  }) async {
    final currency = ref.read(currencyProvider);
    final isUsd = currency == AppCurrency.usd;
    final rate = ref.read(exchangeRateProvider);
    final db = ref.read(databaseProvider);
    final wishlistItems = await db.getAllWishlist();
    if (!context.mounted) {
      return;
    }
    final folders = WishlistFolderService.getAllFolders(items: wishlistItems);

    double minInput = 0.0;
    double targetInput = 0.0;
    String folderName = 'Geral';
    String language = 'PT';
    bool isPreSale = false;
    String condition = 'Near Mint';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final sortedFolders = folders.toList()
            ..sort((a, b) {
              if (a == 'Geral') return -1;
              if (b == 'Geral') return 1;
              return a.compareTo(b);
            });

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('${strings.wishlistTitle}: ${card.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PokemonCardImage(
                    imageUrl: card.imageUrlLarge.isNotEmpty
                        ? card.imageUrlLarge
                        : card.imageUrlSmall,
                    width: 110,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  // Price range (min - max)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: strings.minTargetPriceLabel,
                            prefixText: isUsd ? '\$ ' : 'R\$ ',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) {
                            minInput =
                                CurrencyFormatter.parseCurrencyOrDefault(val);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        child: Text(
                          strings.isEn ? 'to' : 'até',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: strings.maxTargetPriceLabel,
                            prefixText: isUsd ? '\$ ' : 'R\$ ',
                            helperText: strings.isEn
                                ? 'Alert when price drops here'
                                : 'Avisa quando o preço cair abaixo',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (val) {
                            targetInput =
                                CurrencyFormatter.parseCurrencyOrDefault(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: language,
                    decoration: InputDecoration(
                      labelText:
                          strings.isEn ? 'Card language' : 'Idioma da carta',
                      prefixIcon: const Icon(Icons.language),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PT', child: Text('🇧🇷 PT')),
                      DropdownMenuItem(value: 'EN', child: Text('🇺🇸 EN')),
                      DropdownMenuItem(value: 'JP', child: Text('🇯🇵 JP')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => language = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Quality (condition) - extra option for cards
                  DropdownButtonFormField<String>(
                    initialValue: condition,
                    decoration: InputDecoration(
                      labelText: strings.labelCondition,
                      prefixIcon: const Icon(Icons.verified_outlined),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _conditions.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          _conditionDisplay(strings, c),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => condition = value);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isPreSale,
                    title: Text(strings.isEn ? 'Pre-order' : 'Pré-venda'),
                    secondary: const Icon(Icons.event_available_outlined),
                    onChanged: (value) {
                      if (value != null) setState(() => isPreSale = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(folderName),
                    initialValue: folderName,
                    decoration: InputDecoration(
                      labelText: strings.wishlistFolderNameLabel,
                      prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: sortedFolders.map((folder) {
                      final displayName = folder == 'Geral'
                          ? strings.wishlistFolderDefault
                          : folder;
                      return DropdownMenuItem(
                        value: folder,
                        child: Text(displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => folderName = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final successMsg = strings.cardAddedToWishlist(card.name);
                  final minBrl = isUsd ? (minInput * rate) : minInput;
                  final targetBrl = isUsd ? (targetInput * rate) : targetInput;
                  await db.insertWishlistItem(
                    WishlistItemsCompanion(
                      id: drift.Value(const Uuid().v4()),
                      cardApiId: drift.Value(card.id),
                      name: drift.Value(card.name),
                      number: drift.Value(card.number),
                      setName: drift.Value(card.setName),
                      imageUrl: drift.Value(
                        card.imageUrlLarge.isNotEmpty
                            ? card.imageUrlLarge
                            : card.imageUrlSmall,
                      ),
                      minTargetPriceBrl: drift.Value(minBrl),
                      targetPriceBrl: drift.Value(targetBrl),
                      priority: const drift.Value('Média'),
                      folderName: drift.Value(folderName),
                      language: drift.Value(language),
                      isPreSale: drift.Value(isPreSale),
                      condition: drift.Value(condition),
                      createdAt: drift.Value(DateTime.now()),
                    ),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  messenger.showSnackBar(SnackBar(content: Text(successMsg)));
                },
                child: Text(strings.save),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _conditionDisplay(AppStrings strings, String condition) {
    switch (condition) {
      case 'Mint':
        return strings.isEn ? 'Mint (M)' : 'Mint (M)';
      case 'Near Mint':
        return strings.isEn ? 'Near Mint (NM)' : 'Near Mint (NM)';
      case 'Slightly Played':
        return strings.isEn ? 'Slightly Played (SP)' : 'Levemente Jogada (SP)';
      case 'Moderately Played':
        return strings.isEn
            ? 'Moderately Played (MP)'
            : 'Moderadamente Jogada (MP)';
      case 'Heavily Played':
        return strings.isEn ? 'Heavily Played (HP)' : 'Muito Jogada (HP)';
      case 'Damaged':
        return strings.isEn ? 'Damaged (DMG)' : 'Danificada (DMG)';
      default:
        return strings.isEn ? condition : condition;
    }
  }
}