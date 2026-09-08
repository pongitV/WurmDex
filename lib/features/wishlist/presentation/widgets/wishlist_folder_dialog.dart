import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';

class WishlistFolderDialog extends StatefulWidget {
  final AppStrings strings;

  const WishlistFolderDialog({super.key, required this.strings});

  static Future<String?> show(BuildContext context, AppStrings strings) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => WishlistFolderDialog(strings: strings),
    );
  }

  @override
  State<WishlistFolderDialog> createState() => _WishlistFolderDialogState();
}

class _WishlistFolderDialogState extends State<WishlistFolderDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    return AlertDialog(
      title: Text(strings.wishlistNewFolder),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.wishlistFolderNamePrompt, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: strings.wishlistFolderNameLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.pop(context, text.isNotEmpty ? text : null);
          },
          child: Text(strings.save),
        ),
      ],
    );
  }
}
