import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore.dart';
import 'package:mdd/screens/menu/menu.dart';
import 'package:mdd/screens/search/page.dart';
import 'package:mdd/screens/shared/loadings.dart';
import 'package:mdd/screens/shared/navigation.dart';
import 'package:mdd/screens/shared/search.dart';
import 'package:mdd/screens/statistics/page.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/settings.dart';
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
  bool _isSearching = false;
  final _searchController = TextEditingController();
  SearchFilter _selectedSearchOption = SearchFilter.all;

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
                if (_isSearching)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CommonSearchField(
                        focusNode: _focusNode,
                        controller: _searchController,
                        onChanged: (String value) => _searchDatabase(value),
                        onClear: () {
                          _searchController.clear();
                          ref.invalidate(speciesListProvider);
                          setState(() {});
                        },
                        onFiltering: () {
                          _showFilteringOptions();
                        },
                      ),
                    ),
                  ),
                _isSearching
                    ? TextButton(
                        child: const Text('Done'),
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

  void _searchDatabase(String query) {
    if (query.isNotEmpty) {
      ref
          .read(speciesListProvider.notifier)
          .search(query, filterBy: _selectedSearchOption);
    } else {
      ref.invalidate(speciesListProvider);
    }
    setState(() {});
  }

  void _showFilteringOptions() {
    SearchFilterView(
      selectedOption: _selectedSearchOption,
      onSelected: (SearchFilter? value) {
        if (value != null) {
          _selectedSearchOption = value;
        }
        _searchDatabase(_searchController.text);
        Navigator.pop(context);
      },
    ).showFilteringOptions(context);
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
            const WelcomeText(),
            const SizedBox(height: 16),
            const DatabaseSearch(),
            const SizedBox(height: 32),
            Text('Database version\nv1.12.1, released 30 Jan 2024.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class WelcomeText extends ConsumerWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(isFirstRunProvider).when(
        data: (isFirstRun) {
          if (isFirstRun) {
            return Padding(
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
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
        loading: () => const SimpleLoadingOnly(),
        error: (Object error, StackTrace stackTrace) {
          return Text('Error: $error');
        });
  }
}

class DatabaseSearch extends ConsumerWidget {
  const DatabaseSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(speciesListProvider).when(
        data: (speciesList) {
          return Column(
            children: [
              const HomeSearchBar(),
              const SizedBox(height: 8),
              SpeciesCount(count: speciesList.length),
            ],
          );
        },
        loading: () => const DataLoadingMessages(isSimple: true),
        error: (Object error, StackTrace stackTrace) {
          return Text('Error: $error');
        });
  }
}

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search database',
        hintStyle: WidgetStatePropertyAll(
          Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primaryContainer.withAlpha(24),
        ),
        side: WidgetStateProperty.all(
          BorderSide(
            color:
                Theme.of(context).colorScheme.primaryContainer.withAlpha(180),
            width: 2,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return SearchDatabasePage(
                    controller: _searchController,
                  );
                },
              ),
            );
          }
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return SearchDatabasePage(
                  controller: _searchController,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SpeciesCount extends StatelessWidget {
  const SpeciesCount({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Total species: $count',
        style: Theme.of(context).textTheme.labelLarge,
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
