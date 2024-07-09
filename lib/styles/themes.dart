import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class MddTheme {
  static final _defaultLightColorScheme =
      FlexThemeData.light(scheme: FlexScheme.amber).colorScheme;

  static final _defaultDarkColorScheme =
      FlexThemeData.dark(scheme: FlexScheme.amber).colorScheme;

  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: _defaultLightColorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: _defaultDarkColorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
