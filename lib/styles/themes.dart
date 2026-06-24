import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class MddTheme {
  // Define custom colors based on the MDD website's tailwind config
  static const FlexSchemeColor _customLightColors = FlexSchemeColor(
    primary: Color(0xFF65453B),
    secondary: Color(0xFF2C4243),
    tertiary: Color(0xFFB9D6D2),
    appBarColor: Color(0xFF273A39),
  );

  static const FlexSchemeColor _customDarkColors = FlexSchemeColor(
    primary: Color(0xFF65453B),
    secondary: Color(0xFF679A98),
    tertiary: Color(0xFF2C4243),
    appBarColor: Color(0xFF273A39),
  );

  static final _defaultLightColorScheme = FlexThemeData.light(
    colors: _customLightColors,
  ).colorScheme;

  static final _defaultDarkColorScheme = FlexThemeData.dark(
    colors: _customDarkColors,
  ).colorScheme;

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
