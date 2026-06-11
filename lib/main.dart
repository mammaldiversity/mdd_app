import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
          data: (_) => const MddPages(),
          loading: () => const SetupPage(),
          error: (Object error, StackTrace stackTrace) {
            return Builder(
              builder: (context) {
                return Scaffold(
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'An error occurred',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  'Error: $error\n\nStack trace:\n$stackTrace',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.copy_rounded),
                                label: const Text('Copy'),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                        text:
                                            'Error: $error\n\nStack trace:\n$stackTrace'),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Error copied to clipboard')),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save_alt_rounded),
                                label: const Text('Export'),
                                onPressed: () async {
                                  try {
                                    final String content =
                                        'Error: $error\n\nStack trace:\n$stackTrace';
                                    final Directory tempDir =
                                        await getTemporaryDirectory();
                                    final File file = File(
                                        '${tempDir.path}/mdd_error_log.txt');
                                    await file.writeAsString(content);
                                    await SharePlus.instance.share(
                                      ShareParams(
                                        files: [XFile(file.path)],
                                        text: 'MDD Error Log',
                                      ),
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Failed to export: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
