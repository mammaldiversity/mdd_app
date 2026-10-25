import 'package:material_ui/material_ui.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class MddTheme {
  // Define custom colors based on the MDD website's tailwind config
  static const FlexSchemeColor _customLightColors = FlexSchemeColor(
    primary: Color(0xFF65453B),
    secondary: Color(0xFF2C4243),
    tertiary: Color(0xFFB9D6D2),
    appBarColor: Color(0xFF273A39),
  );

  // The MDD brown is under 2.4:1 on dark surfaces, so dark mode uses a lighter
  // tint of it for text, icons, and bars (9:1, WCAG 1.4.3 and 1.4.11). The
  // container keeps the original brown.
  static const FlexSchemeColor _customDarkColors = FlexSchemeColor(
    primary: Color(0xFFC9A89C),
    primaryContainer: Color(0xFF65453B),
    secondary: Color(0xFF679A98),
    tertiary: Color(0xFF2C4243),
    appBarColor: Color(0xFF273A39),
  );

  static final _defaultLightColorScheme =
      FlexThemeData.light(colors: _customLightColors).colorScheme.copyWith(
        // Default #919191 is 2.97:1 on cards; borders and tree lines need 3:1.
        outline: const Color(0xFF8A8A8A),
      );

  static final _defaultDarkColorScheme =
      FlexThemeData.dark(colors: _customDarkColors).colorScheme.copyWith(
        onPrimary: Colors.black,
        onPrimaryContainer: Colors.white,
        // White on the light teal is 3.2:1; black is 6.7:1.
        onSecondaryContainer: Colors.black,
      );

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
