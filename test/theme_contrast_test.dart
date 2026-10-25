import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mdd/styles/themes.dart';

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Contrast floors for theme color pairs the app relies on, so a theme change
/// cannot silently reintroduce a WCAG 2.1 AA failure.
void main() {
  for (final theme in [MddTheme.lightTheme(), MddTheme.darkTheme()]) {
    final s = theme.colorScheme;
    final mode = theme.brightness.name;

    group('$mode theme', () {
      // WCAG 1.4.3: text needs 4.5:1.
      final textPairs = <String, (Color, Color)>{
        'primary text on surface': (s.primary, s.surface),
        'primary text on cards': (s.primary, s.surfaceContainerLow),
        'onPrimary on primary': (s.onPrimary, s.primary),
        'onSecondaryContainer on secondaryContainer': (
          s.onSecondaryContainer,
          s.secondaryContainer,
        ),
        'secondary text on surface': (s.secondary, s.surface),
        'onSurface on tertiary pills': (s.onSurface, s.tertiary),
        'primary count on tertiary pills': (s.primary, s.tertiary),
        'onSurfaceVariant on cards': (
          s.onSurfaceVariant,
          s.surfaceContainerLow,
        ),
        'error on surface': (s.error, s.surface),
      };
      for (final entry in textPairs.entries) {
        test('${entry.key} clears 4.5:1', () {
          final (fg, bg) = entry.value;
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }

      // WCAG 1.4.11: icons, borders, and chart marks need 3:1.
      final graphicPairs = <String, (Color, Color)>{
        'outline on cards': (s.outline, s.surfaceContainerLow),
        'secondary icons on cards': (s.secondary, s.surfaceContainerLow),
      };
      for (final entry in graphicPairs.entries) {
        test('${entry.key} clears 3:1', () {
          final (fg, bg) = entry.value;
          expect(_contrast(fg, bg), greaterThanOrEqualTo(3));
        });
      }
    });
  }
}
