import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/core/utils/currency_formatter.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';
import 'package:wurmdex/features/wishlist/presentation/widgets/wishlist_folder_dialog.dart';

class CardQuickWishlistDialog {
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
    final folders = <String>{'Geral'};
    for (final item in wishlistItems) {
      folders.add(item.folderName.isNotEmpty ? item.folderName : 'Geral');
    }
    final sortedFolders = folders.toList()
      ..sort((a, b) {
        if (a == 'Geral') return -1;
        if (b == 'Geral') return 1;
        return a.compareTo(b);
      });

    double targetInput = 0.0;
    String priority = 'Média';
    String folderName = 'Geral';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${strings.wishlistTitle}: ${card.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: isUsd
                          ? strings.labelTargetPriceUsd
                          : strings.labelTargetPriceBrl,
                      prefixText: isUsd ? '\$ ' : 'R\$ ',
                      helperText: strings.isEn
                          ? 'Alerts if market price drops below target'
                          : 'Avisa se o preço de mercado ficar abaixo deste valor',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (val) {
                      targetInput = CurrencyFormatter.parseCurrencyOrDefault(
                        val,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: folderName,
                          decoration: InputDecoration(
                            labelText: strings.wishlistFolderNameLabel,
                            prefixIcon: const Icon(
                              Icons.folder_outlined,
                              size: 20,
                            ),
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
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: strings.wishlistNewFolder,
                        icon: const Icon(Icons.create_new_folder_outlined),
                        onPressed: () async {
                          final newFolder = await WishlistFolderDialog.show(
                            context,
                            strings,
                          );
                          if (!context.mounted ||
                              newFolder == null ||
                              newFolder == 'Geral' ||
                              newFolder == 'Todas') {
                            return;
                          }
                          if (!sortedFolders.contains(newFolder)) {
                            sortedFolders.add(newFolder);
                            sortedFolders.sort((a, b) {
                              if (a == 'Geral') return -1;
                              if (b == 'Geral') return 1;
                              return a.compareTo(b);
                            });
                          }
                          setState(() => folderName = newFolder);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: strings.labelPriority,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    initialValue: priority,
                    items: [
                      DropdownMenuItem(
                        value: 'Baixa',
                        child: Text(strings.priorityLow),
                      ),
                      DropdownMenuItem(
                        value: 'Média',
                        child: Text(strings.priorityMedium),
                      ),
                      DropdownMenuItem(
                        value: 'Alta',
                        child: Text(strings.priorityHigh),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => priority = val);
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
                      targetPriceBrl: drift.Value(targetBrl),
                      priority: drift.Value(priority),
                      folderName: drift.Value(folderName),
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
}
