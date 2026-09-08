import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/file_storage_helper.dart';
import '../../../../core/widgets/card_scale_dialog.dart';

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
                if (themeMode != null) ref.read(themeProvider.notifier).setTheme(themeMode);
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
                      child: Image.asset(
                        'assets/images/wurmple.png',
                        width: 26,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                    value: AppThemeMode.wurmple,
                  ),
                ],
              ),
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
            child: Text(strings.isEn ? 'Close' : 'Fechar'),
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
}
