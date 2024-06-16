import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/home/home.dart';
import 'package:mdd/services/providers/settings.dart';
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
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Mammal Diversity Database',
        debugShowCheckedModeBanner: false,
        theme: MddTheme.lightTheme(lightColorScheme),
        darkTheme: MddTheme.darkTheme(darkColorScheme),
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
        home: const MddPages(),
      );
    });
  }
}
