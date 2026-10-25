import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mdd/screens/home/stats.dart' as home_stats show MddStatistics;
import 'package:mdd/screens/taxon/higher_taxon.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/settings.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/taxon_tree.dart';

void main() {
  final mockStats = MddStatistics(
    speciesPerOrder: [StatSpeciesPerOrderResult(name: 'Rodentia', count: 2820)],
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
        overrides: _overrides(mockStats),
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
    expect(find.text('Synonyms'), findsOneWidget);
    expect(find.text('54,120'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('12,500'), findsOneWidget);

    // Links
    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Browse by order'), findsOneWidget);
    expect(find.text('2,820'), findsOneWidget);
    expect(find.text('Taxonomy tree'), findsOneWidget);

    // Species card
    expect(find.text('Species'), findsOneWidget);
    expect(find.text('6,540'), findsOneWidget);
  });
  for (final (link, title, hasTreeLink) in const [
    ('Orders', 'Species Diversity by Order', true),
    ('Families', 'Species Diversity by Family', true),
    ('Genera', 'Species Diversity by Genus', false),
    ('Synonyms', 'Species with the Most Names and Synonyms', false),
    ('Images', 'Species with Most Images', false),
  ]) {
    testWidgets('$link opens its table', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(mockStats),
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
      expect(
        find.text('Taxonomy tree'),
        hasTreeLink ? findsOneWidget : findsNothing,
      );
    });
  }

  const rodentia = (rank: TaxonRank.order, name: 'Rodentia');
  final taxonOverrides = [
    higherTaxonProvider(
      rodentia,
    ).overrideWith((ref) async => HigherTaxonData(taxon: rodentia, rows: [])),
    higherTaxonImagesProvider(rodentia).overrideWith((ref) async => []),
  ];

  testWidgets('an order in Browse by order opens its taxon page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [..._overrides(mockStats), ...taxonOverrides],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: home_stats.MddStatistics()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Order Rodentia, 2,820 species'));
    await tester.pumpAndSettle();

    final page = tester.widget<HigherTaxonPage>(find.byType(HigherTaxonPage));
    expect((page.rank, page.name), (TaxonRank.order, 'Rodentia'));
  });

  testWidgets('a row in the Orders table opens its taxon page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [..._overrides(mockStats), ...taxonOverrides],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: home_stats.MddStatistics()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rodentia'));
    await tester.pumpAndSettle();

    final page = tester.widget<HigherTaxonPage>(find.byType(HigherTaxonPage));
    expect((page.rank, page.name), (TaxonRank.order, 'Rodentia'));
  });

  testWidgets('Taxonomy tree opens the Explore tree view', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(mockStats),
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

List<Override> _overrides(MddStatistics stats) => [
  statisticsProvider.overrideWith((ref) => stats),
  countryDiversityStatsProvider.overrideWith((ref) async => []),
];
