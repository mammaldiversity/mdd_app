import 'package:flutter/material.dart';
import 'package:mdd/screens/explore/explore.dart';
import 'package:mdd/screens/more/more.dart';
// import 'package:mdd/screens/favorites/favorites.dart';
import 'package:mdd/screens/shared/navigation.dart';
import 'package:mdd/services/system.dart';

const List<Widget> _pages = <Widget>[
  HomeScreen(),
  ExploreSpecies(),
  // FavoriteSpecies(),
  MoreMenu(),
];

const List<String> _pageTitles = <String>[
  'Home',
  'Explore Species',
  // 'Favorites',
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
      child: Center(
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(32),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "Welcome",
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'The Mammal Diversity Database of '
                      'the American Society of Mammalogists (ASM) '
                      'is your home base for tracking the latest '
                      'taxonomic changes to living and recently extinct '
                      '(i.e., since ~1500 CE) species and higher taxa of mammals.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Total number of species: 6,718',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Database version\nv1.12.1, released 30 Jan 2024.',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
