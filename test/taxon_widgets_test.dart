import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/search/fields.dart';
import 'package:mdd/screens/taxon/distribution_map.dart';
import 'package:mdd/screens/taxon/higher_taxon.dart';
import 'package:mdd/screens/taxon/synonyms.dart';
import 'package:mdd/screens/taxon/taxonomy.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/providers/map_renderer.dart';
import 'package:mdd/services/providers/species.dart'
    show
        higherTaxonHeatmapProvider,
        higherTaxonImagesProvider,
        higherTaxonProvider;
import 'package:mdd/services/taxon_tree.dart';

import 'support/crossref_fakes.dart';

class _TestMapRendererNotifier extends MapRendererNotifier {
  @override
  MapRenderer build() => MapRenderer.naturalEarth;
}

Widget _mapTestApp(Widget child) => ProviderScope(
  overrides: [mapRendererProvider.overrideWith(_TestMapRendererNotifier.new)],
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  group('ClassificationContainer links', () {
    const rat = TaxonomyData(
      id: 1,
      taxonOrder: 'Rodentia',
      family: 'Muridae',
      subfamily: 'Murinae',
      tribe: 'NA',
      genus: 'Rattus',
      specificEpithet: 'rattus',
      extinct: 0,
    );
    const muridae = (rank: TaxonRank.family, name: 'Muridae');

    testWidgets('hides NA ranks and opens the tapped taxon page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            higherTaxonProvider(muridae).overrideWith(
              (ref) async => HigherTaxonData(taxon: muridae, rows: [rat]),
            ),
            higherTaxonImagesProvider(muridae).overrideWith((ref) async => []),
            higherTaxonHeatmapProvider(muridae).overrideWith(
              (ref) async => CountryHeatmap(
                counts: CountrySpeciesCounts.fromRows(const []),
                topology: const {},
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SelectionArea(
                  child: ClassificationContainer(taxonData: rat),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Tribe', findRichText: true), findsNothing);
      await tester.tapOnText(find.textRange.ofSubstring('Muridae'));
      await tester.pumpAndSettle();

      final page = tester.widget<HigherTaxonPage>(find.byType(HigherTaxonPage));
      expect((page.rank, page.name), (TaxonRank.family, 'Muridae'));
      await tester.scrollUntilVisible(find.text('Murinae'), 200);
      expect(find.text('Full classification'), findsOneWidget);
      expect(find.text('Rattus rattus'), findsNothing);
    });
  });

  group('HigherTaxonPage on wide screens', () {
    const rat = TaxonomyData(
      id: 1,
      taxonOrder: 'Rodentia',
      family: 'Muridae',
      subfamily: 'Murinae',
      genus: 'Rattus',
      specificEpithet: 'rattus',
      extinct: 0,
    );
    const muridae = (rank: TaxonRank.family, name: 'Muridae');

    testWidgets('puts the summary in a band and switches tabs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            higherTaxonProvider(muridae).overrideWith(
              (ref) async => HigherTaxonData(taxon: muridae, rows: [rat]),
            ),
            higherTaxonImagesProvider(muridae).overrideWith((ref) async => []),
            higherTaxonHeatmapProvider(muridae).overrideWith(
              (ref) async => CountryHeatmap(
                counts: CountrySpeciesCounts.fromRows(const []),
                topology: const {},
              ),
            ),
            ...crossrefOverrides(
              progress: seededProgress(const [
                CrossrefWork(
                  title: 'Skulls of Muridae',
                  authors: 'Smith',
                  year: 2024,
                  journal: 'Mammalia',
                  doi: '10.1/a',
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: HigherTaxonPage(rank: TaxonRank.family, name: 'Muridae'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rodentia'), findsOneWidget);
      expect(find.text('Full classification'), findsOneWidget);
      expect(find.text('Skulls of Muridae'), findsNothing);

      await tester.tap(find.text('Publications'));
      await tester.pumpAndSettle();
      expect(find.text('Skulls of Muridae'), findsOneWidget);
      expect(find.text('Full classification'), findsNothing);

      await tester.tap(find.text('Distribution'));
      await tester.pumpAndSettle();
      expect(find.text('Species by country'), findsOneWidget);
      expect(
        find.text('No country records for living species.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Classification'));
      await tester.pumpAndSettle();
      expect(find.text('Full classification'), findsOneWidget);

      await tester.tap(find.text('Export dataset'));
      await tester.pumpAndSettle();
      expect(find.byType(ExportDialog), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Muridae'), findsOneWidget);
      await tester.tap(find.text('Include synonyms'));
      await tester.pump();
      expect(find.text('Saved as Muridae_synonyms.csv'), findsOneWidget);
    });

    testWidgets('phones switch sections with icon tabs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            higherTaxonProvider(muridae).overrideWith(
              (ref) async => HigherTaxonData(taxon: muridae, rows: [rat]),
            ),
            higherTaxonImagesProvider(muridae).overrideWith((ref) async => []),
            higherTaxonHeatmapProvider(muridae).overrideWith(
              (ref) async => CountryHeatmap(
                counts: CountrySpeciesCounts.fromRows(const []),
                topology: const {},
              ),
            ),
            ...crossrefOverrides(
              progress: seededProgress(const [
                CrossrefWork(
                  title: 'Skulls of Muridae',
                  authors: 'Smith',
                  year: 2024,
                  journal: 'Mammalia',
                  doi: '10.1/a',
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: HigherTaxonPage(rank: TaxonRank.family, name: 'Muridae'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Icons with tooltips, no tab text; the map and publications wait in
      // their tabs.
      expect(find.byTooltip('Distribution'), findsOneWidget);
      expect(find.text('Publications'), findsNothing);
      expect(find.text('Species by country'), findsNothing);
      expect(find.text('Skulls of Muridae'), findsNothing);
      expect(find.text('Full classification'), findsOneWidget);

      await tester.tap(find.byTooltip('Publications'));
      await tester.pumpAndSettle();
      expect(find.text('Skulls of Muridae'), findsOneWidget);
      expect(find.text('Full classification'), findsNothing);

      await tester.tap(find.byTooltip('Distribution'));
      await tester.pumpAndSettle();
      expect(find.text('Species by country'), findsOneWidget);
    });
  });

  testWidgets('shows publications for a genus, in italics', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const rattus = (rank: TaxonRank.genus, name: 'Rattus');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          higherTaxonProvider(rattus).overrideWith(
            (ref) async => HigherTaxonData(
              taxon: rattus,
              rows: const [
                TaxonomyData(
                  id: 1,
                  taxonOrder: 'Rodentia',
                  family: 'Muridae',
                  genus: 'Rattus',
                  specificEpithet: 'rattus',
                  extinct: 0,
                ),
              ],
            ),
          ),
          higherTaxonImagesProvider(rattus).overrideWith((ref) async => []),
          higherTaxonHeatmapProvider(rattus).overrideWith(
            (ref) async => CountryHeatmap(
              counts: CountrySpeciesCounts.fromRows(const []),
              topology: const {},
            ),
          ),
          ...crossrefOverrides(
            progress: seededProgress(const [
              CrossrefWork(
                title: 'Rattus in cities',
                authors: 'Smith',
                year: 2024,
                journal: 'Mammalia',
                doi: '10.1/a',
              ),
            ]),
          ),
        ],
        child: const MaterialApp(
          home: HigherTaxonPage(rank: TaxonRank.genus, name: 'Rattus'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publications'));
    await tester.pumpAndSettle();

    final title = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Rattus in cities',
      ),
    );
    final spans = (title.text as TextSpan).children!.first as TextSpan;
    expect(spans.children!.first.toPlainText(), 'Rattus');
    expect(
      (spans.children!.first as TextSpan).style?.fontStyle,
      FontStyle.italic,
    );
  });

  group('DistributionMap widget tests', () {
    testWidgets('Renders empty when countryDistribution is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _mapTestApp(const DistributionMap(countryDistribution: null)),
      );
      expect(find.text('Distribution Map'), findsNothing);
    });

    testWidgets('Renders empty when countryDistribution is NA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _mapTestApp(const DistributionMap(countryDistribution: 'NA')),
      );
      expect(find.text('Distribution Map'), findsNothing);
    });

    testWidgets('Renders map when countryDistribution has value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _mapTestApp(const DistributionMap(countryDistribution: 'USA')),
      );
      expect(find.text('Distribution Map'), findsOneWidget);
    });
  });

  group('SynonymContainer widget tests', () {
    testWidgets('Shows all synonyms when 10 or fewer', (
      WidgetTester tester,
    ) async {
      final data = List.generate(
        5,
        (index) => SynonymData(
          synId: index,
          hespId: 1,
          speciesId: 1,
          species: 'test',
          rootName: 'test',
          author: 'test',
          year: '2020',
          authorityParentheses: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SynonymContainer(data: data)),
        ),
      );

      // "Show all" should not be visible
      expect(find.textContaining('Show all'), findsNothing);
      expect(find.byType(SynonymCard), findsNWidgets(5));
    });

    testWidgets('Shows 10 synonyms and button when more than 10', (
      WidgetTester tester,
    ) async {
      final data = List.generate(
        15,
        (index) => SynonymData(
          synId: index,
          hespId: 1,
          speciesId: 1,
          species: 'test',
          rootName: 'test',
          author: 'test',
          year: '2020',
          authorityParentheses: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SynonymContainer(data: data)),
        ),
      );

      // Only 10 should be visible initially
      expect(find.byType(SynonymCard), findsNWidgets(10));
      expect(find.textContaining('Show all (15) synonyms'), findsOneWidget);

      // Tap the show all button
      await tester.tap(find.textContaining('Show all (15) synonyms'));
      await tester.pumpAndSettle();

      // Now all 15 should be visible
      expect(find.byType(SynonymCard), findsNWidgets(15));
      expect(find.textContaining('Show all (15) synonyms'), findsNothing);
    });
  });
}
