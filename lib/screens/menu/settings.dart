import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/settings.dart';

const Map<String, ThemeMode> _themeMode = {
  'System': ThemeMode.system,
  'Light': ThemeMode.light,
  'Dark': ThemeMode.dark,
};

const Map<String, IconData> theme = {
  'System': Icons.auto_awesome_outlined,
  'Light': Icons.wb_sunny_outlined,
  'Dark': Icons.nightlight_outlined,
};

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
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.primary.withAlpha(32),
              ),
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _themeMode.keys
                  .map(
                    (String key) => AppearanceTile(
                      icon: theme[key]!,
                      text: key,
                      isSelected: themeMode == _matchThemeMode(key),
                    ),
                  )
                  .toList(),
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
