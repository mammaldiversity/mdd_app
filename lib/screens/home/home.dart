import 'package:flutter/material.dart';
import 'package:mdd/screens/explore/explore.dart';
import 'package:mdd/screens/more/more.dart';
import 'package:mdd/screens/favorites/favorites.dart';
import 'package:mdd/screens/shared/navigation.dart';
import 'package:mdd/services/system.dart';

const List<Widget> _pages = <Widget>[
  HomeScreen(),
  ExploreSpecies(),
  FavoriteSpecies(),
  MoreMenu(),
];

const List<String> _pageTitles = <String>[
  'Home',
  'Explore Species',
  'Favorites',
  'More Menu',
];

class MddPages extends StatefulWidget {
  const MddPages({super.key});

  @override
  State<MddPages> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MddPages> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles.elementAt(_selectedPage)),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _pages.elementAt(_selectedPage),
      )),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedPage,
        screenType: screenType,
        onNavigationSelected: (int index) {
          setState(() {
            _selectedPage = index;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/icons/favicon512.png',
              width: 120,
              height: 120,
            ),
          ),
          Text(
            "ASM's Mammal Diversity Database",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
