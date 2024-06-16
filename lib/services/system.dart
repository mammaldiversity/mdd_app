import 'package:flutter/material.dart';

/// Returns the screen type based on the device width.
/// Following the Material Design guidelines, the screen types are:
/// UrL: https://m3.material.io/foundations/layout/understanding-layout/overview
/// - compact (small): less than 600dp
/// - medium: 600dp to 839dp
/// - expanded: 840dp to 1119dp
/// - large: 1200dp to 1599dp
/// - extra-large: 1600dp and above
enum ScreenType { small, medium, expanded, large, extraLarge }

ScreenType getScreenType(BuildContext context) {
  final double deviceWidth = MediaQuery.of(context).size.width;
  if (deviceWidth < 600) {
    return ScreenType.small;
  } else if (deviceWidth >= 600 && deviceWidth < 840) {
    return ScreenType.medium;
  } else if (deviceWidth >= 840 && deviceWidth < 1200) {
    return ScreenType.expanded;
  } else if (deviceWidth >= 1200 && deviceWidth < 1600) {
    return ScreenType.large;
  } else {
    return ScreenType.extraLarge;
  }
}
