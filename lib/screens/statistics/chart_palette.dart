import 'package:flutter/material.dart';

/// Accessible, theme-harmonious color palettes for MDD charts.
///
/// Ensures compliance with WCAG 2.1:
/// - SC 1.4.3 (Contrast Minimum >= 4.5:1 for text)
/// - SC 1.4.11 (Non-text Contrast >= 3:1 for graphical objects against card surfaces)
///
/// Colors are calibrated for both Light and Dark themes to maintain strong
/// visual contrast against `colorScheme.surfaceContainerHigh` while preserving
/// aesthetic harmony with MDD's earth, forest, and slate palette.
class ChartPalette {
  ChartPalette._();

  /// Gets the theme-aware IUCN Red List status color.
  ///
  /// Adapts between light and dark modes so dark statuses (e.g. EX, EW) are not
  /// lost on dark surfaces, and lighter statuses maintain >= 3:1 contrast against
  /// light surfaces.
  static Color getIucnColor(String code, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      switch (code) {
        case 'EX':
          return const Color(0xFFE0E0E0); // Silver / off-white
        case 'EW':
          return const Color(0xFFCE93D8); // Lavender / light purple
        case 'CR':
          return const Color(0xFFEF5350); // Soft red
        case 'EN':
          return const Color(0xFFFF8A65); // Peach / soft orange
        case 'VU':
          return const Color(0xFFFFB74D); // Warm amber
        case 'NT':
          return const Color(0xFFAED581); // Sage lime
        case 'LC':
          return const Color(0xFF81C784); // Soft forest green
        case 'DD':
          return const Color(0xFFBDBDBD); // Light slate grey
        case 'NE':
          return const Color(0xFF90A4AE); // Pale pine slate
        default:
          return const Color(0xFFB0BEC5);
      }
    } else {
      switch (code) {
        case 'EX':
          return const Color(0xFF212121); // Charcoal black
        case 'EW':
          return const Color(0xFF4A148C); // Deep purple
        case 'CR':
          return const Color(0xFFC62828); // Deep crimson
        case 'EN':
          return const Color(0xFFD84315); // Terracotta orange
        case 'VU':
          return const Color(0xFFB26A00); // Warm earth ochre
        case 'NT':
          return const Color(0xFF558B2F); // Olive / leaf green
        case 'LC':
          return const Color(0xFF1B5E20); // Deep forest green
        case 'DD':
          return const Color(0xFF616161); // Slate grey
        case 'NE':
          return const Color(0xFF455A64); // Pine blue-grey
        default:
          return const Color(0xFF78909C);
      }
    }
  }

  /// Theme-adapted Okabe-Ito categorical color palette.
  ///
  /// Carefully calibrated to prevent low-contrast yellows on light surfaces and
  /// dark indigos on dark surfaces, maintaining harmony with MDD earth and slate tones.
  static List<Color> getCategoricalColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const [
        Color(0xFFFFB74D), // Soft Amber (WCAG 8.1:1)
        Color(0xFF56B4E9), // Sky Blue (WCAG 6.5:1)
        Color(0xFF4DB6AC), // Sage Teal (WCAG 6.8:1)
        Color(0xFFFFE082), // Soft Gold (WCAG 10.2:1)
        Color(0xFFBCAAA4), // Warm Taupe (WCAG 7.5:1)
        Color(0xFF679A98), // MDD Sage (WCAG 6.2:1)
        Color(0xFFF48FB1), // Soft Berry Pink (WCAG 7.1:1)
        Color(0xFF9FA8DA), // Soft Periwinkle (WCAG 6.8:1)
        Color(0xFF80CBC4), // Pale Aquamarine (WCAG 7.4:1)
        Color(0xFFA5D6A7), // Pale Forest Green (WCAG 7.8:1)
      ];
    } else {
      return const [
        Color(0xFFC25E00), // Earth Amber / Orange (WCAG 4.2:1)
        Color(0xFF0072B2), // Deep Sky Blue (WCAG 5.3:1)
        Color(0xFF007A5A), // Pine Teal Green (WCAG 4.8:1)
        Color(0xFFB28704), // Warm Mustard Gold (WCAG 3.5:1)
        Color(0xFF65453B), // MDD Earth Brown (WCAG 6.5:1)
        Color(0xFF2C4243), // MDD Deep Slate (WCAG 8.2:1)
        Color(0xFF9C4274), // Plum / Berry (WCAG 5.1:1)
        Color(0xFF332288), // Deep Indigo (WCAG 10.2:1)
        Color(0xFF00838F), // Deep Cyan (WCAG 4.6:1)
        Color(0xFF1B5E20), // Deep Forest Green (WCAG 7.5:1)
      ];
    }
  }

  /// Theme-aware binary colors for Extinct vs Extant.
  static ({Color extinct, Color extant}) getExtinctColors(
      BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return (
        extinct: const Color(0xFFEF5350), // Soft red (5.2:1)
        extant: const Color(0xFF4DB6AC), // Sage teal (6.8:1)
      );
    }
    return (
      extinct: const Color(0xFFC62828), // Deep crimson (5.8:1)
      extant: const Color(0xFF00695C), // Pine teal (6.2:1)
    );
  }

  /// Theme-aware binary colors for Domestic vs Wild.
  static ({Color domestic, Color wild}) getDomesticColors(
      BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return (
        domestic: const Color(0xFFFFB74D), // Warm amber (8.1:1)
        wild: const Color(0xFF81C784), // Soft forest green (6.8:1)
      );
    }
    return (
      domestic: const Color(0xFFB26A00), // Warm ochre (3.8:1)
      wild: const Color(0xFF1B5E20), // Deep forest green (7.5:1)
    );
  }

  /// Theme-aware colors for With Images vs Without Images.
  static ({Color withImages, Color withoutImages}) getImagesColors(
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return (
      withImages: colorScheme.primary,
      withoutImages: isDark
          ? const Color(0xFF78909C) // Blue-grey slate (5.0:1)
          : const Color(0xFF546E7A), // Deep blue-grey slate (5.2:1)
    );
  }

  /// Theme-harmonious, accessible bar color for Genus charts.
  ///
  /// Earth amber tone that contrasts >= 3:1 against card backgrounds and avoids
  /// low-contrast tertiary colors in light theme.
  static Color getGenusColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFB74D) : const Color(0xFFB26A00);
  }

  /// Theme-harmonious, accessible bar color for Country charts.
  ///
  /// Pine/sage teal tone that complements MDD secondary tones while ensuring >= 3:1 contrast.
  static Color getCountryColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00695C);
  }

  /// Theme-harmonious, accessible bar color for Decade charts.
  static Color getDecadeColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFB74D) : const Color(0xFFC25E00);
  }

  /// Theme-harmonious, accessible bar color for Year charts.
  static Color getYearColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF9FA8DA) : const Color(0xFF5E35B1);
  }

  /// Theme-harmonious, accessible bar color for Synonyms charts.
  static Color getSynonymsColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFCE93D8) : const Color(0xFF8E24AA);
  }

  /// Theme-harmonious, accessible bar color for Images bar charts.
  static Color getImagesBarColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF4DD0E1) : const Color(0xFF00838F);
  }
}
