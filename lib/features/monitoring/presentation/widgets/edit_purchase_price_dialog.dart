import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';

class EditPurchasePriceDialog extends ConsumerStatefulWidget {
  final UserCard card;
  final AppStrings strings;
  final double exchangeRate;
  final AppCurrency currency;

  const EditPurchasePriceDialog({
    super.key,
    required this.card,
    required this.strings,
    required this.exchangeRate,
    required this.currency,
  });

  static Future<void> show(
    BuildContext context, {
    required UserCard card,
    required AppStrings strings,
    required double exchangeRate,
    required AppCurrency currency,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditPurchasePriceDialog(
        card: card,
        strings: strings,
        exchangeRate: exchangeRate,
        currency: currency,
      ),
    );
  }

  @override
  ConsumerState<EditPurchasePriceDialog> createState() => _EditPurchasePriceDialogState();
}

class _EditPurchasePriceDialogState extends ConsumerState<EditPurchasePriceDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final isUsd = widget.currency == AppCurrency.usd;
    final initialVal = isUsd
        ? (widget.card.purchasePriceBrl / widget.exchangeRate)
        : widget.card.purchasePriceBrl;
    _controller = TextEditingController(
      text: initialVal > 0 ? initialVal.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final rawText = _controller.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(rawText);

    if (parsed == null || parsed < 0) {
      setState(() => _errorText = 'Informe um valor numérico válido.');
      return;
    }

    final isUsd = widget.currency == AppCurrency.usd;
    final finalBrl = isUsd ? (parsed * widget.exchangeRate) : parsed;

    final db = ref.read(databaseProvider);
    await db.updateCard(
      widget.card.toCompanion(true).copyWith(
        purchasePriceBrl: drift.Value(finalBrl),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.strings.purchasePriceUpdatedSuccess),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUsd = widget.currency == AppCurrency.usd;
    final currencySymbol = isUsd ? 'US\$' : 'R\$';

    return AlertDialog(
      title: Text(widget.strings.editPurchasePriceTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.card.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            '${widget.card.setName} (${widget.card.number})',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.strings.editPurchasePricePrompt,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '$currencySymbol ',
              hintText: '0.00',
              errorText: _errorText,
            ),
            onSubmitted: (_) => _handleSave(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.strings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.profitGreen),
          onPressed: _handleSave,
          child: Text(widget.strings.save),
        ),
      ],
    );
  }
}
