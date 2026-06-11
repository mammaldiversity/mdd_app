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
    label: 'Explore',
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
    icon: Icon(Icons.apps_outlined),
    selectedIcon: Icon(Icons.apps_rounded),
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
      indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
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

class NavRail extends StatefulWidget {
  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onNavigationSelected,
  });

  final int selectedIndex;
  final void Function(int) onNavigationSelected;

  @override
  State<NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<NavRail> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onNavigationSelected,
      extended: _isExpanded,
      labelType: _isExpanded
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: IconButton(
        icon: Icon(_isExpanded ? Icons.menu_open : Icons.menu),
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
      ),
      indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
      destinations: navigationProperties
          .map((NavigationProperties nav) => NavigationRailDestination(
                icon: nav.icon,
                selectedIcon: nav.selectedIcon,
                label: Text(nav.label),
              ))
          .toList(),
    );
  }
}
