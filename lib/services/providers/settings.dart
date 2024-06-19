import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences setting(SettingRef ref) {
  return throw UnimplementedError();
}

@Riverpod(keepAlive: true)
Future<bool> isFirstRun(IsFirstRunRef ref) async {
  final prefs = ref.watch(settingProvider);
  final isFirstRun = prefs.getBool('isFirstRun') ?? true;
  if (isFirstRun) {
    await prefs.setBool('isFirstRun', false);
  }
  return isFirstRun;
}

@Riverpod(keepAlive: true)
class ThemeSetting extends _$ThemeSetting {
  Future<ThemeMode> _fetchSetting() async {
    final prefs = ref.watch(settingProvider);
    final savedTheme = prefs.getString('themeMode');

    // Set to default system theme if no setting is found
    final ThemeMode currentTheme = _matchThemeMode(savedTheme);
    if (savedTheme == null) {
      await prefs.setString('themeMode', _matchThemeModeToString(currentTheme));
    }

    return currentTheme;
  }

  @override
  FutureOr<ThemeMode> build() async {
    return await _fetchSetting();
  }

  Future<void> setTheme(String mode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final themeMode = mode.toLowerCase();
      await prefs.setString('themeMode', themeMode);
      return _matchThemeMode(themeMode);
    });
  }

  ThemeMode _matchThemeMode(String? savedTheme) {
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
        case 'system':
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }

  String _matchThemeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
