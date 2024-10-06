import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/home/page.dart';
import 'package:mdd/screens/home/setup.dart';
import 'package:mdd/services/providers/settings.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/src/rust/frb_generated.dart';
import 'package:mdd/styles/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await RustLib.init();
  runApp(ProviderScope(
    overrides: [settingProvider.overrideWithValue(prefs)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Mammal Diversity Database',
      debugShowCheckedModeBanner: false,
      theme: MddTheme.lightTheme(),
      darkTheme: MddTheme.darkTheme(),
      themeMode: ref.watch(themeSettingProvider).when(
          data: (ThemeMode themeMode) => themeMode,
          loading: () => ThemeMode.system,
          error: (Object error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load theme setting.'
                  ' Defaulting to system theme. Error: $error',
                ),
              ),
            );
            return ThemeMode.system;
          }),
      home: ref.watch(speciesListProvider).when(
          data: (_) => const HomeScreen(),
          loading: () => const SetupPage(),
          error: (Object error, StackTrace stackTrace) {
            return Scaffold(
              body: Center(
                child: Text('Error: $error. Stack trace: $stackTrace'),
              ),
            );
          }),
    );
  }
}
