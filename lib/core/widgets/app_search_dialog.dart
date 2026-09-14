import 'package:flutter/material.dart';
import '../localization/app_strings.dart';

/// Standardized Search Window Dialog for WurmDex (DRY).
///
/// Fills the screen comfortably (around 85-90% width/height) without covering it
/// completely, offering a focused, clean search experience with autofocus.
class AppSearchDialog extends StatefulWidget {
  final String initialQuery;
  final String? hintText;
  final AppStrings strings;
  final List<String>? recentOrPopularSearches;

  const AppSearchDialog({
    super.key,
    this.initialQuery = '',
    this.hintText,
    required this.strings,
    this.recentOrPopularSearches,
  });

  static Future<String?> show(
    BuildContext context, {
    String initialQuery = '',
    String? hintText,
    required AppStrings strings,
    List<String>? suggestions,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AppSearchDialog(
        initialQuery: initialQuery,
        hintText: hintText,
        strings: strings,
        recentOrPopularSearches: suggestions,
      ),
    );
  }

  @override
  State<AppSearchDialog> createState() => _AppSearchDialogState();
}

class _AppSearchDialogState extends State<AppSearchDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) {
    Navigator.pop(context, query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 480,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submit,
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? widget.strings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _controller,
                          builder: (context, value, _) {
                            if (value.text.isEmpty) return const SizedBox.shrink();
                            return IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              tooltip: 'Limpar',
                              onPressed: () => _controller.clear(),
                            );
                          },
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: widget.strings.cancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Actions Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(widget.strings.cancel),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => _submit(_controller.text),
                    child: Text(widget.strings.searchActionTitle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
