import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/taxon/distribution_map.dart';
import 'package:mdd/screens/taxon/synonyms.dart';
import 'package:mdd/services/database/database.dart';

void main() {
  group('DistributionMap widget tests', () {
    testWidgets('Renders empty when countryDistribution is null', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DistributionMap(countryDistribution: null))));
      expect(find.text('Distribution Map'), findsNothing);
    });

    testWidgets('Renders empty when countryDistribution is NA', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DistributionMap(countryDistribution: 'NA'))));
      expect(find.text('Distribution Map'), findsNothing);
    });

    testWidgets('Renders map when countryDistribution has value', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DistributionMap(countryDistribution: 'USA'))));
      expect(find.text('Distribution Map'), findsOneWidget);
    });
  });

  group('SynonymContainer widget tests', () {
    testWidgets('Shows all synonyms when 10 or fewer', (WidgetTester tester) async {
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

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SynonymContainer(data: data))));

      // "Show all" should not be visible
      expect(find.textContaining('Show all'), findsNothing);
      expect(find.byType(SynonymCard), findsNWidgets(5));
    });

    testWidgets('Shows 10 synonyms and button when more than 10', (WidgetTester tester) async {
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

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SynonymContainer(data: data))));

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
