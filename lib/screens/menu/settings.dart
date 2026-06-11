import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/providers/settings.dart';
// import 'package:mdd/screens/menu/data_update.dart';

const Map<String, ThemeMode> _themeMode = {
  'System': ThemeMode.system,
  'Light': ThemeMode.light,
  'Dark': ThemeMode.dark,
};

const Map<String, IconData> themeIcon = {
  'System': Icons.auto_awesome_outlined,
  'Light': Icons.wb_sunny_outlined,
  'Dark': Icons.nightlight_outlined,
};

const Map<String, IconData> themeSelectedIcon = {
  'System': Icons.auto_awesome_rounded,
  'Light': Icons.wb_sunny_rounded,
  'Dark': Icons.nightlight_rounded,
};

class DisplaySetting extends StatelessWidget {
  const DisplaySetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(16),
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: const DisplayList(),
            )),
      ],
    );
  }
}

class DisplayList extends ConsumerWidget {
  const DisplayList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showWelcomeAsync = ref.watch(showWelcomeTextProvider);
    final showInfoAsync = ref.watch(showInfoTextProvider);

    return Column(
      children: [
        showWelcomeAsync.when(
          data: (show) => SwitchListTile(
            visualDensity: VisualDensity.compact,
            secondary: const Icon(Icons.waving_hand_outlined),
            title: const Text('Show Welcome Text'),
            value: show,
            onChanged: (val) {
              ref.read(showWelcomeTextProvider.notifier).toggle(val);
            },
          ),
          loading: () => const ListTile(title: Text('Loading...')),
          error: (e, s) => ListTile(title: Text('Error: $e')),
        ),
        const Divider(indent: 48, thickness: 1.2),
        showInfoAsync.when(
          data: (show) => SwitchListTile(
            visualDensity: VisualDensity.compact,
            secondary: const Icon(Icons.info_outline),
            title: const Text('Show Info Text'),
            value: show,
            onChanged: (val) {
              ref.read(showInfoTextProvider.notifier).toggle(val);
            },
          ),
          loading: () => const ListTile(title: Text('Loading...')),
          error: (e, s) => ListTile(title: Text('Error: $e')),
        ),
      ],
    );
  }
}

class AppearanceSetting extends StatelessWidget {
  const AppearanceSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(16),
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: const AppearanceList(),
            )),
      ],
    );
  }
}

class AppearanceList extends ConsumerWidget {
  const AppearanceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(themeSettingProvider).when(
          data: (ThemeMode themeMode) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _themeMode.length,
              itemBuilder: (BuildContext context, int index) {
                final String themeName = _themeMode.keys.elementAt(index);
                return AppearanceTile(
                  icon: themeMode == _matchThemeMode(themeName)
                      ? themeSelectedIcon[themeName]!
                      : themeIcon[themeName]!,
                  text: themeName,
                  isSelected: themeMode == _matchThemeMode(themeName),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(indent: 48, thickness: 1.2);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => Center(
            child: Text('Error: $error'),
          ),
        );
  }

  ThemeMode _matchThemeMode(String themeName) {
    return _themeMode[themeName] ?? ThemeMode.system;
  }
}

class AppearanceTile extends ConsumerWidget {
  const AppearanceTile({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
  });

  final IconData icon;
  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(icon),
      title: Text(text),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        ref.read(themeSettingProvider.notifier).setTheme(text);
      },
    );
  }
}

class DatabaseLocationSetting extends StatelessWidget {
  const DatabaseLocationSetting({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Database Location',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Material(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(16),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: FutureBuilder<File>(
              future: dBPath,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(Icons.folder_open_rounded),
                    title: SelectableText(
                      snapshot.data!.path,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: snapshot.data!.path),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Database location copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const ListTile(
                  visualDensity: VisualDensity.compact,
                  leading: Icon(Icons.folder_open_rounded),
                  title: Text('Loading...'),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Data Updates',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 4),
        //   child: Material(
        //     color: Theme.of(context).colorScheme.onSurface.withAlpha(16),
        //     borderRadius: BorderRadius.circular(16),
        //     clipBehavior: Clip.antiAlias,
        //     child: ListTile(
        //       visualDensity: VisualDensity.compact,
        //       leading: const Icon(Icons.system_update_alt_rounded),
        //       title: const Text('Update MDD and MIL data'),
        //       trailing: const Icon(Icons.chevron_right_rounded),
        //       onTap: () {
        //         Navigator.of(context).push(
        //           MaterialPageRoute(
        //               builder: (context) => const DataUpdatePage()),
        //         );
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
