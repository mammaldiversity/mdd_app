// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingHash() => r'8d3ecafee3305b91918d38dce44046849a6590d1';

/// See also [setting].
@ProviderFor(setting)
final settingProvider = Provider<SharedPreferences>.internal(
  setting,
  name: r'settingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingRef = ProviderRef<SharedPreferences>;
String _$isFirstRunHash() => r'5dc524e96735228923750bbe1ba04534807b1035';

/// See also [isFirstRun].
@ProviderFor(isFirstRun)
final isFirstRunProvider = FutureProvider<bool>.internal(
  isFirstRun,
  name: r'isFirstRunProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isFirstRunHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsFirstRunRef = FutureProviderRef<bool>;
String _$themeSettingHash() => r'd21410f0138c0003575f042d6c5b8852089bdbef';

/// See also [ThemeSetting].
@ProviderFor(ThemeSetting)
final themeSettingProvider =
    AsyncNotifierProvider<ThemeSetting, ThemeMode>.internal(
  ThemeSetting.new,
  name: r'themeSettingProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$themeSettingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeSetting = AsyncNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
