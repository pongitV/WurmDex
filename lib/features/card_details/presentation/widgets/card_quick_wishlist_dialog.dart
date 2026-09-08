import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wurmdex/core/database/app_database.dart';
import 'package:wurmdex/core/database/database_provider.dart';
import 'package:wurmdex/core/localization/app_strings.dart';
import 'package:wurmdex/core/providers/currency_provider.dart';
import 'package:wurmdex/features/catalog/models/pokemon_card_item.dart';

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

    double targetInput = 0.0;
    String priority = 'Média';
    String folderName = 'Geral';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${strings.wishlistTitle}: ${card.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: isUsd ? strings.labelTargetPriceUsd : strings.labelTargetPriceBrl,
                    prefixText: isUsd ? '\$ ' : 'R\$ ',
                    helperText: strings.isEn
                        ? 'Alerts if market price drops below target'
                        : 'Avisa se o preço de mercado ficar abaixo deste valor',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    targetInput = double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: folderName,
                  decoration: InputDecoration(
                    labelText: strings.wishlistFolderNameLabel,
                    prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                    isDense: true,
                  ),
                  onChanged: (val) => folderName = val.trim().isEmpty ? 'Geral' : val.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: strings.labelPriority),
                  initialValue: priority,
                  items: [
                    DropdownMenuItem(value: 'Baixa', child: Text(strings.priorityLow)),
                    DropdownMenuItem(value: 'Média', child: Text(strings.priorityMedium)),
                    DropdownMenuItem(value: 'Alta', child: Text(strings.priorityHigh)),
                  ],
                  onChanged: (val) => setState(() => priority = val!),
                ),
              ],
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
                      imageUrl: drift.Value(card.imageUrlLarge.isNotEmpty ? card.imageUrlLarge : card.imageUrlSmall),
                      targetPriceBrl: drift.Value(targetBrl),
                      priority: drift.Value(priority),
                      folderName: drift.Value(folderName),
                      createdAt: drift.Value(DateTime.now()),
                    ),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  messenger.showSnackBar(
                    SnackBar(content: Text(successMsg)),
                  );
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
