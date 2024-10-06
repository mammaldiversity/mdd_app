import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore_page.dart';
import 'package:mdd/screens/home/search.dart';
import 'package:mdd/screens/home/welcome.dart';
import 'package:mdd/screens/menu/menu.dart';
import 'package:mdd/screens/search/page.dart';
import 'package:mdd/screens/shared/navigation.dart';
import 'package:mdd/screens/shared/search.dart';
import 'package:mdd/screens/statistics/page.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/system.dart';

const List<Widget> _pages = <Widget>[
  HomeScreen(),
  ExploreSpecies(),
  MddStats(),
  MoreMenu(),
];

const List<String> _pageTitles = <String>[
  'Home',
  'Explore Taxonomy',
  'Statistics',
  'Menu',
];

class MddPages extends ConsumerStatefulWidget {
  const MddPages({super.key});

  @override
  MddPagesState createState() => MddPagesState();
}

class MddPagesState extends ConsumerState<MddPages> {
  int _selectedPage = 0;
  final _searchController = TextEditingController();

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
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
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return SearchDatabasePage(
                            controller: _searchController,
                          );
                        },
                      ),
                    );
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
            const Welcome(),
            const SizedBox(height: 16),
            const DatabaseSearch(),
          ],
        ),
      ),
    );
  }
}

class SearchInfo extends ConsumerWidget {
  const SearchInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(speciesListProvider).when(
          data: (List<MddGroupListResult> speciesList) {
            return SearchResultInfo(
                foundRecords: speciesList.map((e) => e.id).toList());
          },
          loading: () => const CircularProgressIndicator(),
          error: (Object error, StackTrace? stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}
