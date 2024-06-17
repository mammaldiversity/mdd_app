import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore.dart';
import 'package:mdd/screens/menu/menu.dart';
// import 'package:mdd/screens/favorites/favorites.dart';
import 'package:mdd/screens/shared/navigation.dart';
import 'package:mdd/screens/home/search.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/system.dart';

const List<Widget> _pages = <Widget>[
  HomeScreen(),
  ExploreSpecies(),
  // FavoriteSpecies(),
  MoreMenu(),
];

const List<String> _pageTitles = <String>[
  'Home',
  'Explore Taxonomy',
  // 'Favorites',
  'Menu',
];

class MddPages extends ConsumerStatefulWidget {
  const MddPages({super.key});

  @override
  MddPagesState createState() => MddPagesState();
}

class MddPagesState extends ConsumerState<MddPages> {
  int _selectedPage = 0;
  bool _isSearching = false;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenType screenType = getScreenType(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles.elementAt(_selectedPage)),
        actions: _selectedPage == 1
            ? [
                if (_isSearching)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SearchField(
                        focusNode: _focusNode,
                      ),
                    ),
                  ),
                _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.invalidate(speciesListProvider);
                          setState(() {
                            _isSearching = false;
                          });
                          _focusNode.unfocus();
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                          _focusNode.requestFocus();
                        },
                      )
              ]
            : [],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _pages.elementAt(_selectedPage),
      )),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedPage,
        screenType: screenType,
        onNavigationSelected: (int index) {
          ref.invalidate(speciesListProvider);
          setState(() {
            _selectedPage = index;
            _isSearching = false;
          });
        },
      ),
      bottomSheet: _isSearching ? const SearchInfo() : null,
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
            const SizedBox(height: 32),
            Text('Database version\nv1.12.1, released 30 Jan 2024.',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
