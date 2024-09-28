import 'package:flutter/material.dart';
import 'package:mdd/services/system.dart';

class NavigationProperties {
  const NavigationProperties({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final Icon icon;
  final Icon selectedIcon;
}

const List<NavigationProperties> navigationProperties = <NavigationProperties>[
  NavigationProperties(
    label: 'Home',
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
  ),
  NavigationProperties(
    label: 'Search',
    icon: Icon(Icons.travel_explore_outlined),
    selectedIcon: Icon(Icons.travel_explore_rounded),
  ),
  NavigationProperties(
    label: 'Stats',
    icon: Icon(Icons.analytics_outlined),
    selectedIcon: Icon(Icons.analytics_rounded),
  ),
  NavigationProperties(
    label: 'More',
    icon: Icon(Icons.menu_outlined),
    selectedIcon: Icon(Icons.menu_rounded),
  ),
];

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.screenType,
    required this.selectedIndex,
    required this.onNavigationSelected,
  });

  final int selectedIndex;
  final void Function(int) onNavigationSelected;
  final ScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = screenType == ScreenType.small;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onNavigationSelected,
      labelBehavior: isSmallScreen
          ? NavigationDestinationLabelBehavior.alwaysHide
          : NavigationDestinationLabelBehavior.alwaysShow,
      indicatorColor: Theme.of(context).colorScheme.secondary.withAlpha(120),
      destinations: navigationProperties
          .map((NavigationProperties nav) => NavigationDestination(
                icon: nav.icon,
                selectedIcon: nav.selectedIcon,
                label: nav.label,
                tooltip: isSmallScreen ? nav.label : null,
              ))
          .toList(),
    );
  }
}
