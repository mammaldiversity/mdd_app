import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/home/stats.dart' as home_stats show MddStatistics;
import 'package:mdd/services/database/mdd_query.dart';
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

  testWidgets('renders home statistics cards including Synonyms and Images',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider.overrideWith((ref) => mockStats),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: home_stats.MddStatistics(),
            ),
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

    // Species card
    expect(find.text('Species'), findsOneWidget);
    expect(find.text('6,540'), findsOneWidget);
  });
}
