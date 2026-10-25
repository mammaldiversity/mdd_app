import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/taxon/distribution_map.dart';
import 'package:mdd/screens/taxon/higher_taxon.dart';
import 'package:mdd/screens/taxon/synonyms.dart';
import 'package:mdd/screens/taxon/taxonomy.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/higher_taxon.dart';
import 'package:mdd/services/providers/map_renderer.dart';
import 'package:mdd/services/providers/species.dart'
    show higherTaxonImagesProvider, higherTaxonProvider;
import 'package:mdd/services/taxon_tree.dart';

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
