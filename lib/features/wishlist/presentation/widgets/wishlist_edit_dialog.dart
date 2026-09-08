import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';

class WishlistEditDialog extends StatefulWidget {
  final AppDatabase db;
  final WishlistItem item;
  final AppStrings strings;
  final bool isUsd;
  final double exchangeRate;

  const WishlistEditDialog({
    super.key,
    required this.db,
    required this.item,
    required this.strings,
    required this.isUsd,
    required this.exchangeRate,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase db,
    required WishlistItem item,
    required AppStrings strings,
    required bool isUsd,
    required double exchangeRate,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => WishlistEditDialog(
        db: db,
        item: item,
        strings: strings,
        isUsd: isUsd,
        exchangeRate: exchangeRate,
      ),
    );
  }

  @override
  State<WishlistEditDialog> createState() => _WishlistEditDialogState();
}

class _WishlistEditDialogState extends State<WishlistEditDialog> {
  late final TextEditingController _priceController;
  late final TextEditingController _folderController;
  late String _priority;

  @override
  void initState() {
    super.initState();
    final initialPrice = widget.isUsd
        ? (widget.item.targetPriceBrl / widget.exchangeRate)
        : widget.item.targetPriceBrl;
    _priceController = TextEditingController(
      text: initialPrice > 0 ? initialPrice.toStringAsFixed(2) : '',
    );
    _folderController = TextEditingController(
      text: widget.item.folderName.isNotEmpty ? widget.item.folderName : 'Geral',
    );
    _priority = widget.item.priority;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final item = widget.item;

    return AlertDialog(
      title: Text('${strings.editWishlistItem} - ${item.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.targetPricePrompt,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: widget.isUsd ? '\$ ' : 'R\$ ',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _folderController,
            decoration: InputDecoration(
              labelText: strings.wishlistFolderNameLabel,
              prefixIcon: const Icon(Icons.folder_outlined, size: 20),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: strings.labelPriority,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            initialValue: _priority,
            items: [
              DropdownMenuItem(value: strings.priorityLow, child: Text(strings.priorityLow)),
              DropdownMenuItem(value: strings.priorityMedium, child: Text(strings.priorityMedium)),
              DropdownMenuItem(value: strings.priorityHigh, child: Text(strings.priorityHigh)),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _priority = val);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final inputVal = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
            final targetBrl = widget.isUsd ? (inputVal * widget.exchangeRate) : inputVal;
            final updatedFolder = _folderController.text.trim().isEmpty ? 'Geral' : _folderController.text.trim();

            await (widget.db.update(widget.db.wishlistItems)..where((t) => t.id.equals(item.id))).write(
              WishlistItemsCompanion(
                targetPriceBrl: drift.Value(targetBrl),
                priority: drift.Value(_priority),
                folderName: drift.Value(updatedFolder),
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
