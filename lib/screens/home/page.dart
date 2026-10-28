import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/screens/explore/explore_page.dart';
import 'package:mdd/screens/gallery/mil_gallery_page.dart';
import 'package:mdd/screens/home/release_changes.dart';
import 'package:mdd/screens/home/search.dart';
import 'package:mdd/screens/home/stats.dart' show MddStatistics;
import 'package:mdd/screens/menu/menu.dart';
import 'package:mdd/screens/search/page.dart';
import 'package:mdd/screens/shared/navigation.dart';
import 'package:mdd/screens/search/fields.dart';
import 'package:mdd/screens/statistics/page.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/navigation.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/system.dart';

const List<Widget> _pages = <Widget>[
  HomeScreen(),
  ExploreSpecies(),
  MilGalleryPage(),
  MddStats(),
  MoreMenu(),
];

const List<String> _pageTitles = <String>[
  'Home',
  'Explore Taxonomy',
  'MIL Image Gallery',
  'Statistics',
  'Menu',
];

class MddPages extends ConsumerStatefulWidget {
  const MddPages({super.key});

  @override
  MddPagesState createState() => MddPagesState();
}

class MddPagesState extends ConsumerState<MddPages> {
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
    final int selectedPage = ref.watch(selectedPageProvider);
    ref.listen(selectedPageProvider, (int? previous, int next) {
      if (previous != next) ref.invalidate(speciesListProvider);
    });
    void select(int index) =>
        ref.read(selectedPageProvider.notifier).select(index);
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles.elementAt(selectedPage)),
        actions: selectedPage == 1
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
                ),
              ]
            : [],
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (screenType != ScreenType.small)
              NavRail(
                selectedIndex: selectedPage,
                onNavigationSelected: select,
              ),
            Expanded(child: _pages.elementAt(selectedPage)),
          ],
        ),
      ),
      bottomNavigationBar: screenType == ScreenType.small
          ? NavBar(
              selectedIndex: selectedPage,
              screenType: screenType,
              onNavigationSelected: select,
            )
          : null,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Wider than this, the home screen centres its content.
  static const double maxContentWidth = 1200;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxContentWidth),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHero(),
                  SizedBox(height: 16),
                  MddStatistics(),
                  SizedBox(height: 24),
                  TaxonomyChanges(),
                  SizedBox(height: 24),
                  DatabaseInfo(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchInfo extends ConsumerWidget {
  const SearchInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(speciesListProvider)
        .when(
          data: (List<MddGroupListResult> speciesList) {
            return SearchResultInfo(
              foundRecords: speciesList.map((e) => e.id).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (Object error, StackTrace? stackTrace) {
            return Text('Error: $error');
          },
        );
  }
}
