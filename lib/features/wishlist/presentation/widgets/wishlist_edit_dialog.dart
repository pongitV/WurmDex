import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_pricing_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../services/wishlist_folder_service.dart';

class WishlistEditDialog extends StatefulWidget {
  final AppDatabase db;
  final WishlistItem item;
  final AppStrings strings;
  final bool isUsd;
  final double exchangeRate;
  final VoidCallback? onMoveToCollection;

  const WishlistEditDialog({
    super.key,
    required this.db,
    required this.item,
    required this.strings,
    required this.isUsd,
    required this.exchangeRate,
    this.onMoveToCollection,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase db,
    required WishlistItem item,
    required AppStrings strings,
    required bool isUsd,
    required double exchangeRate,
    VoidCallback? onMoveToCollection,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => WishlistEditDialog(
        db: db,
        item: item,
        strings: strings,
        isUsd: isUsd,
        exchangeRate: exchangeRate,
        onMoveToCollection: onMoveToCollection,
      ),
    );
  }

  @override
  State<WishlistEditDialog> createState() => _WishlistEditDialogState();
}

class _WishlistEditDialogState extends State<WishlistEditDialog> {
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

  late final TextEditingController _minPriceController;
  late final TextEditingController _priceController;
  late String _folder;
  late String _condition;

  @override
  void initState() {
    super.initState();
    final minBrl = widget.item.minTargetPriceBrl;
    _minPriceController = TextEditingController(
      text: minBrl > 0
          ? (widget.isUsd
                  ? (minBrl / widget.exchangeRate)
                  : minBrl)
              .toStringAsFixed(2)
          : '',
    );
    final initialPrice = widget.isUsd
        ? (widget.item.targetPriceBrl / widget.exchangeRate)
        : widget.item.targetPriceBrl;
    _priceController = TextEditingController(
      text: initialPrice > 0 ? initialPrice.toStringAsFixed(2) : '',
    );
    _folder = widget.item.folderName.isNotEmpty
        ? widget.item.folderName
        : 'Geral';
    _condition = widget.item.condition;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<String> _folderOptions() {
    return WishlistFolderService.getAllFolders(items: [widget.item]);
  }

  String _conditionDisplay(String condition) {
    switch (condition) {
      case 'Damaged':
        return widget.strings.isEn ? 'Damaged (DMG)' : 'Danificada (DMG)';
      default:
        return condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final item = widget.item;

    return AlertDialog(
      title: Text('${strings.editWishlistItem} - ${item.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.targetPricePrompt,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: strings.minTargetPriceLabel,
                      prefixText: widget.isUsd ? '\$ ' : 'R\$ ',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
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
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: strings.maxTargetPriceLabel,
                      prefixText: widget.isUsd ? '\$ ' : 'R\$ ',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: InputDecoration(
                labelText: strings.labelCondition,
                prefixIcon: const Icon(Icons.verified_outlined, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: _conditions.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(_conditionDisplay(c)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _condition = val;
                    final realPrice = CardPricingHelper.getPriceForCondition(
                      cardApiId: widget.item.cardApiId,
                      cardName: widget.item.name,
                      cardNumber: widget.item.number,
                      setName: widget.item.setName,
                      basePriceBrl: widget.item.targetPriceBrl,
                      condition: val,
                    );
                    if (realPrice > 0 && widget.item.targetPriceBrl > 0) {
                      final displayPrice = widget.isUsd ? (realPrice / widget.exchangeRate) : realPrice;
                      _priceController.text = displayPrice.toStringAsFixed(2);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _folder,
              decoration: InputDecoration(
                labelText: strings.wishlistFolderNameLabel,
                prefixIcon: const Icon(Icons.folder_outlined, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              items: _folderOptions().map((folder) {
                final displayName = folder == 'Geral'
                    ? strings.wishlistFolderDefault
                    : folder;
                return DropdownMenuItem(
                  value: folder,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _folder = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.onMoveToCollection != null)
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.profitGreen,
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onMoveToCollection!();
            },
            child: Text(strings.wishlistMoveToCollection),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final inputMin = CurrencyFormatter.parseCurrencyOrDefault(
              _minPriceController.text,
            );
            final inputVal = CurrencyFormatter.parseCurrencyOrDefault(
              _priceController.text,
            );
            final minBrl = widget.isUsd ? (inputMin * widget.exchangeRate) : inputMin;
            final targetBrl = widget.isUsd
                ? (inputVal * widget.exchangeRate)
                : inputVal;
            await (widget.db.update(widget.db.wishlistItems)
                  ..where((t) => t.id.equals(item.id)))
                .write(
              WishlistItemsCompanion(
                minTargetPriceBrl: drift.Value(minBrl),
                targetPriceBrl: drift.Value(targetBrl),
                folderName: drift.Value(_folder),
                condition: drift.Value(_condition),
              ),
            );

            if (context.mounted) Navigator.pop(context);
          },
          child: Text(strings.save),
        ),
      ],
    );
  }
}