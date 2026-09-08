import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_strings.dart';
import 'core/theme/theme_provider.dart';
import 'features/navigation/presentation/main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: WurmDexApp(),
    ),
  );
}

class WurmDexApp extends ConsumerWidget {
  const WurmDexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current theme mode and language
    ref.watch(themeProvider);
    final currentThemeData = ref.read(themeProvider.notifier).currentThemeData;
    final language = ref.watch(languageProvider);
    final strings = getStrings(language);

    return MaterialApp(
      title: strings.appName,
      debugShowCheckedModeBanner: false,
      theme: currentThemeData,
      home: const MainScaffold(),
    );
  }
}
