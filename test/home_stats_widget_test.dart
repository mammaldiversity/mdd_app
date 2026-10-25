import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mdd/screens/home/stats.dart' as home_stats show MddStatistics;
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/settings.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/statistics.dart';

void main() {
  final mockStats = MddStatistics(
    speciesPerOrder: [],
    speciesPerFamily: [],
    speciesPerGenus: [],
    iucnStatus: [],
    discoveryDecade: [],
    discoveryYear: [],
    extinctSpecies: [StatExtinctSpeciesResult(isExtinct: 1, count: 100)],
    domesticSpecies: [StatDomesticSpeciesResult(isDomestic: 1, count: 40)],
    biogeographicRealm: [],
    topCountries: [],
    speciesWithMostImages: [],
    speciesWithImagesCount: 800,
    totalOrdersCount: 27,
    totalFamiliesCount: 167,
    totalGeneraCount: 1350,
    livingWildSpeciesCount: 6400,
    totalSpeciesCount: 6540,
    speciesWithMostSynonyms: [],
    typeKindProportion: [],
    totalSynonymsCount: 54120,
    totalImagesCount: 12500,
  );

  testWidgets('renders home statistics cards including Synonyms and Images', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [statisticsProvider.overrideWith((ref) => mockStats)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: home_stats.MddStatistics()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mammal Diversity Statistics'), findsOneWidget);

    // Orders, Families, Genera
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
    expect(find.text('Families'), findsOneWidget);
    expect(find.text('167'), findsOneWidget);
    expect(find.text('Genera'), findsOneWidget);
    expect(find.text('1,350'), findsOneWidget);

    // Synonyms and Images
    expect(find.text('Names & Synonyms'), findsOneWidget);
    expect(find.text('54,120'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('12,500'), findsOneWidget);

    // Links
    expect(find.text('Orders table'), findsOneWidget);
    expect(find.text('Families table'), findsOneWidget);
    expect(find.text('Taxonomy tree'), findsOneWidget);

    // Species card
    expect(find.text('Species'), findsOneWidget);
    expect(find.text('6,540'), findsOneWidget);
  });
  for (final (link, title) in const [
    ('Orders', 'Species Diversity by Order'),
    ('Families', 'Species Diversity by Family'),
    ('Orders table', 'Species Diversity by Order'),
    ('Families table', 'Species Diversity by Family'),
  ]) {
    testWidgets('$link opens its table with a link to the tree', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [statisticsProvider.overrideWith((ref) => mockStats)],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: home_stats.MddStatistics()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(link));
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.text('Taxonomy tree'), findsOneWidget);
    });
  }

  testWidgets('Taxonomy tree opens the Explore tree view', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider.overrideWith((ref) => mockStats),
          settingProvider.overrideWithValue(prefs),
          speciesListProvider.overrideWith(_EmptySpeciesList.new),
          taxonTreeProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: home_stats.MddStatistics()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Taxonomy tree'));
    await tester.pumpAndSettle();

    expect(find.text('Explore Taxonomy'), findsOneWidget);
    expect(prefs.getString('exploreViewMode'), 'tree');
  });
}

class _EmptySpeciesList extends SpeciesList {
  @override
  Future<List<MddGroupListResult>> build() async => [];
}
