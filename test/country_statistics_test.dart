import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/country_species_page.dart';
import 'package:mdd/screens/statistics/country_table_page.dart';
import 'package:mdd/services/providers/species.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/statistics.dart';

void main() {
  group('Country Diversity Data Model Test', () {
    test('CountryDiversityData correctly calculates totalSpecies', () {
      final data = CountryDiversityData(
        countryName: 'Indonesia',
        totalOrders: 10,
        totalFamilies: 35,
        totalGenera: 150,
        totalLivingSpecies: 700,
        totalExtinctSpecies: 5,
        speciesIds: [1, 2, 3],
      );

      expect(data.countryName, 'Indonesia');
      expect(data.totalOrders, 10);
      expect(data.totalFamilies, 35);
      expect(data.totalGenera, 150);
      expect(data.totalLivingSpecies, 700);
      expect(data.totalExtinctSpecies, 5);
      expect(data.totalSpecies, 705);
      expect(data.speciesIds, [1, 2, 3]);
    });
  });

  group('CountryTablePage Widget Tests', () {
    testWidgets(
        'renders CountryTablePage with mock country diversity provider data',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockData = [
        CountryDiversityData(
          countryName: 'Indonesia',
          totalOrders: 10,
          totalFamilies: 35,
          totalGenera: 150,
          totalLivingSpecies: 700,
          totalExtinctSpecies: 5,
          speciesIds: [1, 2],
        ),
        CountryDiversityData(
          countryName: 'Brazil',
          totalOrders: 12,
          totalFamilies: 40,
          totalGenera: 180,
          totalLivingSpecies: 750,
          totalExtinctSpecies: 2,
          speciesIds: [3, 4],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            countryDiversityStatsProvider.overrideWith((ref) => mockData),
          ],
          child: const MaterialApp(
            home: CountryTablePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mammal Diversity by Country'), findsOneWidget);
      expect(find.text('Indonesia'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Living Species'), findsOneWidget);
      expect(find.text('Extinct Species'), findsOneWidget);
    });

    testWidgets('filtering country search bar updates visible rows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockData = [
        CountryDiversityData(
          countryName: 'Indonesia',
          totalOrders: 10,
          totalFamilies: 35,
          totalGenera: 150,
          totalLivingSpecies: 700,
          totalExtinctSpecies: 5,
          speciesIds: [1, 2],
        ),
        CountryDiversityData(
          countryName: 'Brazil',
          totalOrders: 12,
          totalFamilies: 40,
          totalGenera: 180,
          totalLivingSpecies: 750,
          totalExtinctSpecies: 2,
          speciesIds: [3, 4],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            countryDiversityStatsProvider.overrideWith((ref) => mockData),
          ],
          child: const MaterialApp(
            home: CountryTablePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Braz');
      await tester.pumpAndSettle();

      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Indonesia'), findsNothing);
    });

    testWidgets('tapping country navigates to CountrySpeciesPage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockData = [
        CountryDiversityData(
          countryName: 'Indonesia',
          totalOrders: 10,
          totalFamilies: 35,
          totalGenera: 150,
          totalLivingSpecies: 700,
          totalExtinctSpecies: 5,
          speciesIds: [1],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            countryDiversityStatsProvider.overrideWith((ref) => mockData),
            mainTaxonomyDataProvider([1]).overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            home: CountryTablePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Indonesia'));
      await tester.pumpAndSettle();

      expect(find.byType(CountrySpeciesPage), findsOneWidget);
      expect(find.text('Indonesia'), findsWidgets);
    });

    testWidgets('sorting on all columns works properly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockData = [
        CountryDiversityData(
          countryName: 'Zambia',
          totalOrders: 5,
          totalFamilies: 10,
          totalGenera: 20,
          totalLivingSpecies: 50,
          totalExtinctSpecies: 1,
          speciesIds: [],
        ),
        CountryDiversityData(
          countryName: 'Australia',
          totalOrders: 15,
          totalFamilies: 50,
          totalGenera: 200,
          totalLivingSpecies: 800,
          totalExtinctSpecies: 20,
          speciesIds: [],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            countryDiversityStatsProvider.overrideWith((ref) => mockData),
          ],
          child: const MaterialApp(
            home: CountryTablePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap 'Orders' column header to sort by Orders
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      // Tap 'Families' column header
      await tester.tap(find.text('Families'));
      await tester.pumpAndSettle();

      // Tap 'Genera' column header
      await tester.tap(find.text('Genera'));
      await tester.pumpAndSettle();

      // Tap 'Living Species' column header
      await tester.tap(find.text('Living Species'));
      await tester.pumpAndSettle();

      // Tap 'Extinct Species' column header
      await tester.tap(find.text('Extinct Species'));
      await tester.pumpAndSettle();

      // Tap 'Country' column header
      await tester.tap(find.text('Country'));
      await tester.pumpAndSettle();
    });
  });
}
