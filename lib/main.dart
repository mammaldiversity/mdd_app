import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_mdd/screens/home/home.dart';
import 'package:test_mdd/src/rust/frb_generated.dart';
import 'package:test_mdd/styles/themes.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Mammal Diversity Database',
        theme: MddTheme.lightTheme(lightColorScheme),
        darkTheme: MddTheme.darkTheme(darkColorScheme),
        home: const HomeScreen(),
      );
    });
  }
}
