import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
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
    label: 'Gallery',
    icon: Icon(Icons.photo_library_outlined),
    selectedIcon: Icon(Icons.photo_library_rounded),
  ),
  NavigationProperties(
    label: 'Stats',
    icon: Icon(Icons.analytics_outlined),
    selectedIcon: Icon(Icons.analytics_rounded),
  ),
  NavigationProperties(
    label: 'More',
    icon: Icon(Icons.grid_view_outlined),
    selectedIcon: Icon(Icons.grid_view_rounded),
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
          .map(
            (NavigationProperties nav) => NavigationDestination(
              icon: nav.icon,
              selectedIcon: nav.selectedIcon,
              label: nav.label,
              tooltip: isSmallScreen ? nav.label : null,
            ),
          )
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

const double _railMinWidth = 80;
const double _railExtendedWidth = 200;

/// Menu toggle that stays in line with the destination icons, pinned to the
/// start edge as the rail expands instead of floating in the middle.
class _RailToggle extends StatelessWidget {
  const _RailToggle({required this.isExpanded, required this.onPressed});

  final bool isExpanded;
  final VoidCallback onPressed;

  // Centers the 48px button within the collapsed rail's icon column.
  static const double _startInset = (_railMinWidth - 48) / 2;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = NavigationRail.extendedAnimation(
      context,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) => SizedBox(
        width: lerpDouble(_railMinWidth, _railExtendedWidth, animation.value),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: _startInset,
          top: 4,
          bottom: 12,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            tooltip: isExpanded ? 'Collapse navigation' : 'Expand navigation',
            icon: Icon(isExpanded ? Icons.menu_open : Icons.menu),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class _NavRailState extends State<NavRail> {
  bool? _userExpandedToggle;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isWideScreen = screenWidth >= 840;
    final bool isExpanded = _userExpandedToggle ?? isWideScreen;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    // A tinted surface plus a right border sets the rail apart from
    // the main content, which sits on the plain scaffold surface.
    return Row(
      children: [
        _buildRail(theme, colorScheme, isExpanded),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: colorScheme.outlineVariant,
        ),
      ],
    );
  }

  Widget _buildRail(ThemeData theme, ColorScheme colorScheme, bool isExpanded) {
    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: NavigationRail(
        selectedIndex: widget.selectedIndex,
        onDestinationSelected: widget.onNavigationSelected,
        extended: isExpanded,
        minExtendedWidth: _railExtendedWidth,
        backgroundColor: Colors.transparent,
        groupAlignment: -1,
        labelType: isExpanded
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        minWidth: _railMinWidth,
        leading: _RailToggle(
          isExpanded: isExpanded,
          onPressed: () {
            setState(() {
              _userExpandedToggle = !isExpanded;
            });
          },
        ),
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        destinations: [
          for (final nav in navigationProperties)
            NavigationRailDestination(
              icon: nav.icon,
              selectedIcon: nav.selectedIcon,
              label: Text(nav.label),
              padding: const EdgeInsets.symmetric(vertical: 2),
            ),
        ],
      ),
    );
  }
}
