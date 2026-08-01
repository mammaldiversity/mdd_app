import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/home/top_countries.dart';
import 'package:mdd/screens/statistics/country_species_page.dart';
import 'package:mdd/screens/statistics/country_table_page.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/statistics.dart';

void main() {
  final mockCountries = [
    CountryDiversityData(
      countryName: 'Indonesia',
      totalOrders: 10,
      totalFamilies: 35,
      totalGenera: 150,
      totalLivingSpecies: 700,
      totalExtinctSpecies: 5,
      speciesIds: [10],
    ),
    CountryDiversityData(
      countryName: 'Brazil',
      totalOrders: 12,
      totalFamilies: 40,
      totalGenera: 180,
      totalLivingSpecies: 750,
      totalExtinctSpecies: 2,
      speciesIds: [20],
    ),
    CountryDiversityData(
      countryName: 'Mexico',
      totalOrders: 9,
      totalFamilies: 30,
      totalGenera: 140,
      totalLivingSpecies: 550,
      totalExtinctSpecies: 1,
      speciesIds: [30],
    ),
    CountryDiversityData(
      countryName: 'China',
      totalOrders: 11,
      totalFamilies: 38,
      totalGenera: 160,
      totalLivingSpecies: 680,
      totalExtinctSpecies: 3,
      speciesIds: [40],
    ),
    CountryDiversityData(
      countryName: 'Colombia',
      totalOrders: 10,
      totalFamilies: 36,
      totalGenera: 155,
      totalLivingSpecies: 520,
      totalExtinctSpecies: 0,
      speciesIds: [50],
    ),
    CountryDiversityData(
      countryName: 'Australia',
      totalOrders: 8,
      totalFamilies: 28,
      totalGenera: 120,
      totalLivingSpecies: 350,
      totalExtinctSpecies: 15,
      speciesIds: [60],
    ),
  ];

  testWidgets('renders top 5 countries by living species diversity correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countryDiversityStatsProvider.overrideWith((ref) => mockCountries),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TopCountriesWidget(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Top 5 Countries by Mammal Diversity'), findsOneWidget);
    // Rank 1: Brazil (750)
    expect(find.text('Brazil'), findsOneWidget);
    expect(find.text('750 living species'), findsOneWidget);
    // Rank 2: Indonesia (700)
    expect(find.text('Indonesia'), findsOneWidget);
    expect(find.text('700 living species'), findsOneWidget);
    // Rank 3: China (680)
    expect(find.text('China'), findsOneWidget);
    expect(find.text('680 living species'), findsOneWidget);
    // Rank 4: Mexico (550)
    expect(find.text('Mexico'), findsOneWidget);
    expect(find.text('550 living species'), findsOneWidget);
    // Rank 5: Colombia (520)
    expect(find.text('Colombia'), findsOneWidget);
    expect(find.text('520 living species'), findsOneWidget);

    // 6th country (Australia - 350) should NOT be displayed in top 5 list
    expect(find.text('Australia'), findsNothing);

    // CTA button exists
    expect(find.text('View Full Country Table'), findsOneWidget);
  });

  testWidgets('tapping CTA button opens CountryTablePage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countryDiversityStatsProvider.overrideWith((ref) => mockCountries),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TopCountriesWidget(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('View Full Country Table'));
    await tester.pumpAndSettle();

    expect(find.byType(CountryTablePage), findsOneWidget);
    expect(find.text('Mammal Diversity by Country'), findsOneWidget);
  });

  testWidgets('tapping a top country row navigates to CountrySpeciesPage',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countryDiversityStatsProvider.overrideWith((ref) => mockCountries),
          mainTaxonomyDataProvider([20]).overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TopCountriesWidget(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Brazil'));
    await tester.pumpAndSettle();

    expect(find.byType(CountrySpeciesPage), findsOneWidget);
  });
}
