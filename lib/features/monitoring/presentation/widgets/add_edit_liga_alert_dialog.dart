import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../services/liga_scraper_service.dart';
import '../../services/radar_folder_service.dart';

class AddEditLigaAlertDialog extends StatefulWidget {
  final AppDatabase db;
  final AppStrings strings;
  final LigaPriceAlert? existingAlert;

  const AddEditLigaAlertDialog({
    super.key,
    required this.db,
    required this.strings,
    this.existingAlert,
  });

  @override
  State<AddEditLigaAlertDialog> createState() => _AddEditLigaAlertDialogState();
}

class _AddEditLigaAlertDialogState extends State<AddEditLigaAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _currentPriceController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  late String _collection;
  late String _language;
  late String _folderName;
  late bool _allowPreSale;
  bool _isLoadingPreview = false;
  String? _previewImageUrl;
  double? _previewLowestPrice;
  bool _previewIsPreSale = false;
  String? _previewStoreName;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final alert = widget.existingAlert;
    _urlController = TextEditingController(text: alert?.targetUrl ?? '');
    _titleController = TextEditingController(text: alert?.title ?? '');
    _currentPriceController = TextEditingController(
      text: alert != null && alert.currentLowestPrice != null && alert.currentLowestPrice! > 0
          ? alert.currentLowestPrice!.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _minPriceController = TextEditingController(
      text: alert != null && alert.minTargetPrice > 0
          ? alert.minTargetPrice.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _maxPriceController = TextEditingController(
      text: alert != null && alert.maxTargetPrice > 0
          ? alert.maxTargetPrice.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _collection = alert?.collectionTag ?? '';
    _language = alert?.languageTag.isNotEmpty == true
        ? alert!.languageTag
        : 'PT';
    _folderName = alert != null && alert.folderName.isNotEmpty
        ? alert.folderName
        : 'Geral';
    _allowPreSale = alert?.allowPreSale ?? true;
    _previewImageUrl = alert?.imageUrl;
    _previewLowestPrice = alert?.currentLowestPrice;
    _previewIsPreSale = alert?.isPreSale ?? false;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _currentPriceController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final pasted = data.text!.trim();
      setState(() {
        _urlController.text = pasted;
      });
      _extractNameFromUrl(pasted);
      _fetchPreview();
    }
  }

  void _extractNameFromUrl(String input) {
    try {
      final uri = Uri.tryParse(input);
      if (uri != null) {
        final nameParam = uri.queryParameters['prod'] ?? uri.queryParameters['card'];
        if (nameParam != null && nameParam.trim().isNotEmpty && _titleController.text.trim().isEmpty) {
          _titleController.text = nameParam.trim();
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchPreview() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) return;

    _extractNameFromUrl(input);

    setState(() {
      _isLoadingPreview = true;
      _errorMessage = null;
    });

    try {
      final product = await LigaScraperService.fetchProductDetails(input);
      if (product != null && mounted) {
        setState(() {
          if (_titleController.text.trim().isEmpty || widget.existingAlert == null) {
            _titleController.text = product.title;
          }
          if (product.imageUrl.isNotEmpty) {
            _previewImageUrl = product.imageUrl;
          }
          _previewLowestPrice = product.lowestPrice;
          _previewIsPreSale = product.isPreSale;
          _previewStoreName = (product.storeName != null && product.storeName!.isNotEmpty)
              ? product.storeName
              : (product.lowestPrice != null && product.lowestPrice! > 0
                  ? 'Marketplace (LigaPokémon)'
                  : null);
          _isLoadingPreview = false;

          if (product.isPreSale) {
            _allowPreSale = true;
          }

          // Auto-detect collection & language from the product title when not manually set
          final tags = LigaScraperService.detectTags(product.title);
          if (_collection.isEmpty) {
            _collection = tags.collection;
          }
          if (_language.isEmpty) {
            _language = tags.language.isNotEmpty ? tags.language : 'PT';
          }

          if (product.lowestPrice != null && product.lowestPrice! > 0) {
            _currentPriceController.text =
                product.lowestPrice!.toStringAsFixed(2).replaceAll('.', ',');

            if (_maxPriceController.text.isEmpty) {
              _maxPriceController.text =
                  (product.lowestPrice! * 1.05).toStringAsFixed(2).replaceAll('.', ',');
            }
          }
        });
      } else if (mounted) {
        setState(() {
          _isLoadingPreview = false;
          _errorMessage = widget.strings.errorLoadingNews;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPreview = false;
          _errorMessage = 'Erro ao consultar: $e';
        });
      }
    }
  }

  double _parseInputPrice(String text) => CurrencyFormatter.parseCurrencyOrDefault(text);

  String _languageFlag(String code) {
    switch (code.toUpperCase()) {
      case 'PT':
        return '🇧🇷';
      case 'EN':
        return '🇺🇸';
      case 'JP':
        return '🇯🇵';
      default:
        return '🌐';
    }
  }

  List<DropdownMenuItem<String>> _collectionOptions() {
    final names = <String>{};
    names.addAll(AppPreferencesService.getRadarFolders());
    final existing = widget.existingAlert?.collectionTag;
    if (existing != null && existing.isNotEmpty) names.add(existing);
    if (_collection.isNotEmpty) names.add(_collection);
    final list = names.toList()..sort();
    return [
      DropdownMenuItem(value: '', child: Text(widget.strings.noFolderLabel)),
      ...list.map((c) => DropdownMenuItem(value: c, child: Text(c))),
    ];
  }

  List<DropdownMenuItem<String>> _languageOptions() {
    final codes = <String>{'PT', 'EN', 'JP'};
    if (_language.isNotEmpty) codes.add(_language);
    return codes.map((code) {
      return DropdownMenuItem(
        value: code,
        child: Text('${_languageFlag(code)} ${code.toUpperCase()}'),
      );
    }).toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final targetUrl = _urlController.text.trim();
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Produto LigaPokémon';
    final minPrice = _parseInputPrice(_minPriceController.text);
    final maxPrice = _parseInputPrice(_maxPriceController.text);

    final inputCurrentPrice = _parseInputPrice(_currentPriceController.text);
    final effectivePrice = inputCurrentPrice > 0
        ? inputCurrentPrice
        : (_previewLowestPrice ?? widget.existingAlert?.currentLowestPrice);

    final isAvailableInRange = (effectivePrice != null && effectivePrice > 0) &&
        (!_previewIsPreSale || _allowPreSale) &&
        (minPrice <= 0 || effectivePrice >= minPrice) &&
        (maxPrice <= 0 || effectivePrice <= maxPrice);

    final isEditing = widget.existingAlert != null;
    final alertId = widget.existingAlert?.id ?? const Uuid().v4();

    final companion = LigaPriceAlertsCompanion(
      id: drift.Value(alertId),
      title: drift.Value(title),
      targetUrl: drift.Value(targetUrl),
      imageUrl: drift.Value(_previewImageUrl ?? widget.existingAlert?.imageUrl ?? ''),
      minTargetPrice: drift.Value(minPrice),
      maxTargetPrice: drift.Value(maxPrice),
      allowPreSale: drift.Value(_allowPreSale),
      currentLowestPrice: drift.Value(effectivePrice),
      currentStoreName: drift.Value(
        (_previewStoreName != null && _previewStoreName!.isNotEmpty)
            ? _previewStoreName!
            : (widget.existingAlert?.currentStoreName.isNotEmpty == true
                ? widget.existingAlert!.currentStoreName
                : (effectivePrice != null && effectivePrice > 0 ? 'Marketplace (LigaPokémon)' : '')),
      ),
      isPreSale: drift.Value(_previewIsPreSale),
      isAvailableInRange: drift.Value(isAvailableInRange),
      isActive: drift.Value(widget.existingAlert?.isActive ?? true),
      lastCheckedAt: drift.Value(DateTime.now()),
      createdAt: drift.Value(widget.existingAlert?.createdAt ?? DateTime.now()),
      collectionTag: drift.Value(_collection.trim()),
      languageTag: drift.Value(_language.trim()),
      folderName: drift.Value(_folderName.trim().isEmpty ? 'Geral' : _folderName.trim()),
    );

    if (isEditing) {
      await widget.db.updateLigaAlert(companion);
    } else {
      await widget.db.insertLigaAlert(companion);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingAlert != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.goldRarity.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.radar, color: AppColors.goldRarity, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? (widget.strings.isEn ? 'Edit Monitored Item' : 'Editar Monitoramento')
                                  : widget.strings.btnAddAlert,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              widget.strings.isEn
                                  ? 'LigaPokémon • Prices & Pre-Orders'
                                  : 'LigaPokémon • Preços e Pré-Venda',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // URL or Search Query
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: widget.strings.urlOrQueryLabel,
                      hintText: widget.strings.urlOrQueryHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.link),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.paste, size: 20),
                            tooltip: 'Colar link',
                            onPressed: _pasteFromClipboard,
                          ),
                          IconButton(
                            icon: _isLoadingPreview
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search, size: 20),
                            tooltip: widget.strings.previewProductButton,
                            onPressed: _isLoadingPreview ? null : _fetchPreview,
                          ),
                        ],
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return widget.strings.alertUrlOrNameRequired;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _fetchPreview(),
                  ),
                  const SizedBox(height: 12),

                  // Product Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: widget.strings.isEn ? 'Display Name / Title' : 'Nome de Exibição / Título',
                      hintText: widget.strings.isEn ? 'e.g. Charizard ex, 151 Box...' : 'Ex: Charizard ex, Box 151...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return widget.strings.alertTitleRequired;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Collection & Language Tags (auto-detected, selectable from existing folders)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _collection,
                          decoration: InputDecoration(
                            labelText: widget.strings.collectionLabel,
                            prefixIcon:
                                const Icon(Icons.style_outlined, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          items: _collectionOptions(),
                          onChanged: (val) =>
                              setState(() => _collection = val ?? ''),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _language,
                          decoration: InputDecoration(
                            labelText: widget.strings.languageLabel,
                            prefixIcon: const Icon(Icons.language, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          items: _languageOptions(),
                          onChanged: (val) =>
                              setState(() => _language = val ?? 'PT'),
                        ),
                      ),
                    ],
                  ),

                  // Scraped Preview Card
                  if (_previewImageUrl != null || _previewLowestPrice != null || _previewIsPreSale) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _previewIsPreSale ? Colors.deepPurple.shade300 : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_previewImageUrl != null && _previewImageUrl!.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AppNetworkImage(
                                imageUrl: _previewImageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                                fallbackIcon: Icons.image_not_supported_outlined,
                                fallbackIconSize: 36,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (_previewIsPreSale)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          widget.strings.statusPreSale.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      '${widget.strings.isEn ? 'Price on Liga: ' : 'Preço na Liga: '}${_previewLowestPrice != null ? CurrencyFormatter.toBrl(_previewLowestPrice) : (widget.strings.isEn ? 'Unavailable' : 'Indisponível')}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _previewLowestPrice != null ? Colors.green.shade700 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                 if (_previewStoreName != null && _previewStoreName!.isNotEmpty) ...[
                                   const SizedBox(height: 4),
                                   Row(
                                     children: [
                                       Icon(Icons.storefront, size: 13, color: theme.colorScheme.primary),
                                       const SizedBox(width: 4),
                                       Flexible(
                                         child: Text(
                                           '${widget.strings.isEn ? 'Store: ' : 'Loja: '}$_previewStoreName',
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                           style: TextStyle(
                                             fontSize: 11,
                                             fontWeight: FontWeight.w600,
                                             color: theme.colorScheme.onSurface,
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Current Price Field
                  TextFormField(
                    controller: _currentPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: widget.strings.isEn
                          ? 'Current Price on Liga (BRL) (Pre-filled or Custom)'
                          : 'Preço Atual na Liga (R\$) (Preenchido ou Ajustável)',
                      hintText: 'Ex: 119,00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixText: 'R\$ ',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    widget.strings.targetRangeLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  // Price Range row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: widget.strings.minPriceLabel,
                            hintText: '0,00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixText: 'R\$ ',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.strings.isEn ? 'to' : 'até',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _maxPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: widget.strings.maxPriceLabel,
                            hintText: 'Ex: 150,00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixText: 'R\$ ',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return widget.strings.isEn ? 'Set max price' : 'Defina o teto';
                            }
                            final num = _parseInputPrice(val);
                            if (num <= 0) {
                              return widget.strings.isEn ? 'Value > 0' : 'Valor > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Pre-Sale Toggle Option
                  Container(
                    decoration: BoxDecoration(
                      color: _allowPreSale
                          ? Colors.deepPurple.withValues(alpha: 0.08)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _allowPreSale ? Colors.deepPurple.shade300 : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: SwitchListTile(
                      value: _allowPreSale,
                      activeTrackColor: Colors.deepPurple.shade200,
                      activeThumbColor: Colors.deepPurple,
                      title: Row(
                        children: [
                          const Icon(Icons.bolt, size: 20, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.strings.allowPreSaleLabel,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        widget.strings.allowPreSaleDesc,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onChanged: (val) => setState(() => _allowPreSale = val),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Folder Selection Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _folderName,
                    decoration: InputDecoration(
                      labelText: widget.strings.folderFilterHint,
                      prefixIcon: const Icon(Icons.folder_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: () {
                      final folders = RadarFolderService.getAllFolders();
                      if (!folders.contains(_folderName)) {
                        folders.add(_folderName);
                      }
                      return folders.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Row(
                            children: [
                              Icon(
                                f == 'Geral' ? Icons.folder : Icons.folder_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(f == 'Geral' ? widget.strings.wishlistFolderDefault : f),
                            ],
                          ),
                        );
                      }).toList();
                    }(),
                    onChanged: (val) {
                      if (val != null) setState(() => _folderName = val);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(widget.strings.cancel),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: Text(widget.strings.save),
                        onPressed: _save,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
