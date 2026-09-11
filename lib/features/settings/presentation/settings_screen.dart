import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/file_storage_helper.dart';
import '../../../../core/widgets/card_scale_dialog.dart';
import '../../../../core/providers/autoclicker_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final currentRate = ref.watch(exchangeRateProvider);
    final strings = getStrings(currentLanguage);
    final db = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Language / Idioma
          Text(
            strings.sectionLanguage,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: RadioGroup<AppLanguage>(
              groupValue: currentLanguage,
              onChanged: (lang) {
                if (lang != null) ref.read(languageProvider.notifier).setLanguage(lang);
              },
              child: Column(
                children: [
                  RadioListTile<AppLanguage>(
                    title: Text(strings.langEnglishTitle),
                    subtitle: Text(strings.langEnglishSub),
                    secondary: const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Text('EN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    value: AppLanguage.enUs,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppLanguage>(
                    title: Text(strings.langPortugueseTitle),
                    subtitle: Text(strings.langPortugueseSub),
                    secondary: const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Text('PT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    value: AppLanguage.ptBr,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Theming Engine
          Text(
            strings.sectionThemes,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: RadioGroup<AppThemeMode>(
              groupValue: currentThemeMode,
              onChanged: (themeMode) {
                if (themeMode != null) {
                  if (themeMode == AppThemeMode.wurmpleShiny && !AppPreferencesService.isWurmpleShinyUnlocked()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.themeWurmpleShinyLockedToast)),
                    );
                    return;
                  }
                  if (themeMode == AppThemeMode.lugiaShiny && !AppPreferencesService.isLugiaShinyUnlocked()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.themeLugiaShinyLockedToast)),
                    );
                    return;
                  }
                  if (themeMode == AppThemeMode.darkLugia && !AppPreferencesService.isDarkLugiaUnlocked()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.themeDarkLugiaLockedToast)),
                    );
                    return;
                  }
                  ref.read(themeProvider.notifier).setTheme(themeMode);
                }
              },
              child: Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeDarkTitle),
                    subtitle: Text(strings.themeDarkSub),
                    secondary: const CircleAvatar(
                      backgroundColor: AppColors.darkSurface,
                      child: Icon(Icons.dark_mode, color: Colors.amber),
                    ),
                    value: AppThemeMode.dark,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeLightTitle),
                    subtitle: Text(strings.themeLightSub),
                    secondary: const CircleAvatar(
                      backgroundColor: AppColors.lightBackground,
                      child: Icon(Icons.auto_stories, color: AppColors.lightAccent),
                    ),
                    value: AppThemeMode.light,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeGramadoTitle),
                    subtitle: Text(strings.themeGramadoSub),
                    secondary: const CircleAvatar(
                      backgroundColor: AppColors.gramadoSurface,
                      child: Icon(Icons.grass, color: AppColors.gramadoPrimary),
                    ),
                    value: AppThemeMode.gramado,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeWurmpleTitle),
                    subtitle: Text(strings.themeWurmpleSub),
                    secondary: CircleAvatar(
                      backgroundColor: AppColors.wurmpleSurface,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/characters/wurmple.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.pest_control_outlined,
                            size: 18,
                            color: AppColors.wurmplePrimary,
                          ),
                        ),
                      ),
                    ),
                    value: AppThemeMode.wurmple,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeLugiaTitle),
                    subtitle: Text(strings.themeLugiaSub),
                    secondary: CircleAvatar(
                      backgroundColor: AppColors.lugiaSurface,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/characters/249.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.air_outlined,
                            size: 18,
                            color: AppColors.lugiaPrimary,
                          ),
                        ),
                      ),
                    ),
                    value: AppThemeMode.lugia,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeWurmpleShinyTitle),
                    subtitle: Text(
                      AppPreferencesService.isWurmpleShinyUnlocked()
                          ? strings.themeWurmpleShinySub
                          : strings.themeWurmpleShinyLockedSub,
                    ),
                    secondary: _buildThemeAvatar(
                      backgroundColor: AppColors.wurmpleShinySurface,
                      isLocked: !AppPreferencesService.isWurmpleShinyUnlocked(),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/menu/wurmple_shiny_menu.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.star_outline,
                            size: 18,
                            color: AppColors.wurmpleShinyPrimary,
                          ),
                        ),
                      ),
                    ),
                    value: AppThemeMode.wurmpleShiny,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeLugiaShinyTitle),
                    subtitle: Text(
                      AppPreferencesService.isLugiaShinyUnlocked()
                          ? strings.themeLugiaShinySub
                          : strings.themeLugiaShinyLockedSub,
                    ),
                    secondary: _buildThemeAvatar(
                      backgroundColor: AppColors.lugiaShinySurface,
                      isLocked: !AppPreferencesService.isLugiaShinyUnlocked(),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/characters/249_shiny.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.star_outline,
                            size: 18,
                            color: AppColors.lugiaShinyPrimary,
                          ),
                        ),
                      ),
                    ),
                    value: AppThemeMode.lugiaShiny,
                  ),
                  const Divider(height: 1),
                  RadioListTile<AppThemeMode>(
                    title: Text(strings.themeDarkLugiaTitle),
                    subtitle: Text(
                      AppPreferencesService.isDarkLugiaUnlocked()
                          ? strings.themeDarkLugiaSub
                          : strings.themeDarkLugiaLockedSub,
                    ),
                    secondary: _buildThemeAvatar(
                      backgroundColor: AppColors.darkLugiaSurface,
                      isLocked: !AppPreferencesService.isDarkLugiaUnlocked(),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/characters/dark_lugia.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.nights_stay_outlined,
                            size: 18,
                            color: AppColors.darkLugiaPrimary,
                          ),
                        ),
                      ),
                    ),
                    value: AppThemeMode.darkLugia,
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _promptPasswordForExtraThemes(context, strings),
                      icon: const Icon(Icons.key_rounded, size: 18),
                      label: Text(strings.btnUnlockExtraThemes),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Minigame & Autoclickers
          Text(
            strings.sectionEasterEgg,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.touch_app_outlined, color: AppColors.wurmplePrimary),
              title: Text(strings.pauseAutoclickersTitle),
              subtitle: Text(strings.pauseAutoclickersSub),
              value: ref.watch(autoclickerPausedProvider),
              onChanged: (val) => ref.read(autoclickerPausedProvider.notifier).setPaused(val),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Card Visual Scale
          Text(
            strings.sectionCardScale,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CardScaleSheetContent(),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Backup & Restore
          Text(
            strings.sectionBackup,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.profitGreen),
                  title: Text(strings.btnExportDatabase),
                  subtitle: Text(strings.subExportDatabase),
                  trailing: _isExporting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                  onTap: _isExporting
                      ? null
                      : () async {
                          setState(() => _isExporting = true);
                          final success = await FileStorageHelper.exportBackup(db);
                          setState(() => _isExporting = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? strings.backupExportSuccess
                                    : strings.backupExportFailed),
                              ),
                            );
                          }
                        },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: AppColors.darkCyan),
                  title: Text(strings.btnImportBackup),
                  subtitle: Text(strings.subImportBackup),
                  onTap: () => _showRestoreDialog(context, db, strings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Market & Currencies
          Text(
            strings.sectionSystemInfo,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppColors.warningYellow),
                  title: Text(strings.labelCommercialRate),
                  subtitle: Text(strings.subRateSource),
                  trailing: Text(
                    CurrencyFormatter.toBrl(currentRate),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () async {
                    await ref.read(exchangeRateProvider.notifier).refreshRate();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${strings.usdRatePrefix}\$1 = ${CurrencyFormatter.toBrl(currentRate)}')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('${strings.appName} Desktop & Mobile'),
                  subtitle: Text('${strings.subLocalDb} • ${strings.subStatus}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined, color: AppColors.profitGreen),
                  title: Text(strings.labelLegalDisclaimer),
                  subtitle: Text(strings.subLegalDisclaimer),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalNoticeDialog(context, strings),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.hub_outlined, color: AppColors.darkCyan),
                  title: Text(strings.labelDataSources),
                  subtitle: Text(strings.subDataSources),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDataSourcesDialog(context, strings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalNoticeDialog(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.gavel_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(strings.legalNoticeTitle, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            strings.legalNoticeBody,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  void _showDataSourcesDialog(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.hub_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(strings.dataSourcesTitle, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            strings.dataSourcesBody,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, dynamic db, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.backupRestoreTitle),
        content: Text(strings.backupRestoreExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final count = await FileStorageHelper.restoreBackup(db, RestoreMode.merge);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count >= 0
                        ? strings.backupMergedCount(count)
                        : strings.backupInvalidFile),
                  ),
                );
              }
            },
            child: Text(strings.backupMerge),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lossRed, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final count = await FileStorageHelper.restoreBackup(db, RestoreMode.replace);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count >= 0
                        ? strings.backupRestoredCount(count)
                        : strings.backupInvalidFile),
                  ),
                );
              }
            },
            child: Text(strings.backupReplaceAll),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeAvatar({
    required Widget child,
    required Color backgroundColor,
    bool isLocked = false,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: backgroundColor,
          child: child,
        ),
        if (isLocked)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.lock_rounded,
              size: 20,
              color: Colors.amber,
            ),
          ),
      ],
    );
  }

  void _promptPasswordForExtraThemes(BuildContext context, AppStrings strings) async {
    final controller = TextEditingController();
    bool obscure = true;

    final authenticated = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.passwordPromptTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.passwordPromptSubtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    obscureText: obscure,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: strings.passwordHint,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscure = !obscure),
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.trim() == '011') {
                        Navigator.of(dialogCtx).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(strings.incorrectPasswordMsg),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (controller.text.trim() == '011') {
                      Navigator.of(dialogCtx).pop(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.incorrectPasswordMsg),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: Text(strings.confirm),
                ),
              ],
            );
          },
        );
      },
    );

    if (authenticated == true && context.mounted) {
      _showManageExtraThemesDialog(context, strings);
    }
  }

  void _showManageExtraThemesDialog(BuildContext context, AppStrings strings) {
    String selectedThemeKey = 'wurmple_shiny';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final isWurmpleShinyUnlocked = AppPreferencesService.isWurmpleShinyUnlocked();
            final isLugiaShinyUnlocked = AppPreferencesService.isLugiaShinyUnlocked();
            final isDarkLugiaUnlocked = AppPreferencesService.isDarkLugiaUnlocked();

            bool isCurrentSelectedUnlocked;
            String currentSelectedName;
            Widget currentIcon;

            switch (selectedThemeKey) {
              case 'wurmple_shiny':
                isCurrentSelectedUnlocked = isWurmpleShinyUnlocked;
                currentSelectedName = strings.themeWurmpleShinyTitle;
                currentIcon = Image.asset('assets/images/menu/wurmple_shiny_menu.png', width: 32, height: 32, fit: BoxFit.contain);
                break;
              case 'lugia_shiny':
                isCurrentSelectedUnlocked = isLugiaShinyUnlocked;
                currentSelectedName = strings.themeLugiaShinyTitle;
                currentIcon = Image.asset('assets/images/characters/249_shiny.png', width: 32, height: 32, fit: BoxFit.contain);
                break;
              case 'dark_lugia':
                isCurrentSelectedUnlocked = isDarkLugiaUnlocked;
                currentSelectedName = strings.themeDarkLugiaTitle;
                currentIcon = Image.asset('assets/images/characters/dark_lugia.png', width: 32, height: 32, fit: BoxFit.contain);
                break;
              case 'all':
              default:
                isCurrentSelectedUnlocked = isWurmpleShinyUnlocked && isLugiaShinyUnlocked && isDarkLugiaUnlocked;
                currentSelectedName = strings.allThemesOption;
                currentIcon = const Icon(Icons.auto_awesome, color: Colors.amber, size: 28);
                break;
            }

            void toggleTheme(String key, bool unlock) {
              if (key == 'wurmple_shiny') {
                AppPreferencesService.setWurmpleShinyUnlocked(unlock);
                if (!unlock && ref.read(themeProvider) == AppThemeMode.wurmpleShiny) {
                  ref.read(themeProvider.notifier).setTheme(AppThemeMode.wurmple);
                }
              } else if (key == 'lugia_shiny') {
                AppPreferencesService.setLugiaShinyUnlocked(unlock);
                if (!unlock && ref.read(themeProvider) == AppThemeMode.lugiaShiny) {
                  ref.read(themeProvider.notifier).setTheme(AppThemeMode.lugia);
                }
              } else if (key == 'dark_lugia') {
                AppPreferencesService.setDarkLugiaUnlocked(unlock);
                if (!unlock && ref.read(themeProvider) == AppThemeMode.darkLugia) {
                  ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
                }
              } else if (key == 'all') {
                AppPreferencesService.setWurmpleShinyUnlocked(unlock);
                AppPreferencesService.setLugiaShinyUnlocked(unlock);
                AppPreferencesService.setDarkLugiaUnlocked(unlock);
                if (!unlock) {
                  final cur = ref.read(themeProvider);
                  if (cur == AppThemeMode.wurmpleShiny || cur == AppThemeMode.lugiaShiny || cur == AppThemeMode.darkLugia) {
                    ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
                  }
                }
              }
              setDialogState(() {});
              setState(() {});
            }

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.palette_outlined, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.manageExtraThemesTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.selectThemeDropdownLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: selectedThemeKey,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'wurmple_shiny',
                          child: Text(strings.themeWurmpleShinyTitle, overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'lugia_shiny',
                          child: Text(strings.themeLugiaShinyTitle, overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'dark_lugia',
                          child: Text(strings.themeDarkLugiaTitle, overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(strings.allThemesOption, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedThemeKey = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black26,
                                child: currentIcon,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentSelectedName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                      avatar: Icon(
                                        isCurrentSelectedUnlocked ? Icons.lock_open : Icons.lock,
                                        size: 14,
                                        color: isCurrentSelectedUnlocked ? Colors.greenAccent : Colors.grey,
                                      ),
                                      label: Text(
                                        isCurrentSelectedUnlocked ? strings.themeUnlockedLabel : strings.themeLockedLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrentSelectedUnlocked ? Colors.greenAccent : Colors.grey,
                                        ),
                                      ),
                                      backgroundColor: isCurrentSelectedUnlocked ? Colors.green.withValues(alpha: 0.15) : Colors.white10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (selectedThemeKey != 'all') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: isCurrentSelectedUnlocked
                                      ? OutlinedButton.icon(
                                          onPressed: () => toggleTheme(selectedThemeKey, false),
                                          icon: const Icon(Icons.lock, size: 16, color: Colors.orangeAccent),
                                          label: Text(strings.btnLock, style: const TextStyle(color: Colors.orangeAccent)),
                                        )
                                      : FilledButton.icon(
                                          onPressed: () => toggleTheme(selectedThemeKey, true),
                                          icon: const Icon(Icons.lock_open, size: 16),
                                          label: Text(strings.btnUnlock),
                                        ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => toggleTheme('all', true),
                                    icon: const Icon(Icons.lock_open, size: 16),
                                    label: Text(strings.btnUnlockAll, style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => toggleTheme('all', false),
                                    icon: const Icon(Icons.lock, size: 16, color: Colors.orangeAccent),
                                    label: Text(strings.btnLockAll, style: const TextStyle(fontSize: 12, color: Colors.orangeAccent)),
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
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(strings.done),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
