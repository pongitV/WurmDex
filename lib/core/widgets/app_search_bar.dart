import 'package:flutter/material.dart';

/// Universal Search Bar widget for WurmDex (DRY).
///
/// Standardizes:
/// - Search icon prefix
/// - Reactive clear button suffix when text is present
/// - WurmDex design language (rounded borders, subtle tinted surface background)
/// - Flexible controller, callbacks, and padding
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffix;
  final Color? fillColor;
  final bool isDense;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 16.0,
    this.prefixIcon,
    this.suffix,
    this.fillColor,
    this.isDense = true,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _effectiveController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    } else {
      _effectiveController = widget.controller!;
    }
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      if (widget.controller == null) {
        _effectiveController = TextEditingController();
        _isInternalController = true;
      } else {
        if (_isInternalController) {
          _effectiveController.dispose();
          _isInternalController = false;
        }
        _effectiveController = widget.controller!;
      }
      _effectiveController.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onTextChanged);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasText = _effectiveController.text.isNotEmpty;

    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _effectiveController,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon ?? const Icon(Icons.search, size: 20),
          suffixIcon: widget.suffix ??
              (hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Clear',
                      onPressed: () {
                        _effectiveController.clear();
                        widget.onClear?.call();
                        widget.onChanged?.call('');
                      },
                    )
                  : null),
          filled: true,
          fillColor: widget.fillColor ??
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          isDense: widget.isDense,
        ),
      ),
    );
  }
}
