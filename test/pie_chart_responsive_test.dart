import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/domestic_pie_chart.dart';
import 'package:mdd/screens/statistics/extinct_pie_chart.dart';
import 'package:mdd/screens/statistics/images_pie_chart.dart';
import 'package:mdd/screens/statistics/iucn_pie_chart.dart';
import 'package:mdd/screens/statistics/realm_pie_chart.dart';
import 'package:mdd/screens/statistics/type_kind_pie_chart.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/statistics.dart';

void main() {
  final stats = MddStatistics(
    speciesPerOrder: [],
    speciesPerFamily: [],
    speciesPerGenus: [],
    iucnStatus: const [
      MapEntry('CR', 120),
      MapEntry('EN', 240),
      MapEntry('LC', 900),
    ],
    discoveryDecade: [],
    discoveryYear: [],
    extinctSpecies: [
      StatExtinctSpeciesResult(isExtinct: 1, count: 100),
      StatExtinctSpeciesResult(isExtinct: 0, count: 900),
    ],
    domesticSpecies: [
      StatDomesticSpeciesResult(isDomestic: 1, count: 40),
      StatDomesticSpeciesResult(isDomestic: 0, count: 960),
    ],
    biogeographicRealm: const [
      MapEntry('Australasia', 300),
      MapEntry('Indomalayan realm with a long label', 700),
    ],
    topCountries: [],
    speciesWithMostImages: [],
    speciesWithImagesCount: 600,
    totalOrdersCount: 0,
    totalFamiliesCount: 0,
    totalGeneraCount: 0,
    livingWildSpeciesCount: 0,
    totalSpeciesCount: 1000,
    speciesWithMostSynonyms: [],
    typeKindProportion: const [
      MapEntry('Holotype', 750),
      MapEntry('Lectotype', 250),
    ],
    totalSynonymsCount: 0,
    totalImagesCount: 0,
  );

  Widget buildChart(Widget chart, {double width = 320}) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, height: 300, child: chart),
        ),
      ),
    );
  }

  testWidgets('all pie charts keep the legend beside the chart when small', (
    tester,
  ) async {
    final charts = <Widget>[
      ImagesPieChart(stats: stats),
      TypeKindPieChart(stats: stats),
      IucnPieChart(stats: stats),
      RealmPieChart(stats: stats),
      ExtinctPieChart(stats: stats),
      DomesticPieChart(stats: stats),
    ];

    for (final chart in charts) {
      await tester.pumpWidget(buildChart(chart));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('responsive-pie-chart-narrow')),
        findsOneWidget,
      );
      expect(find.byType(PieChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('donut and bar modes still toggle', (tester) async {
    await tester.pumpWidget(buildChart(ImagesPieChart(stats: stats)));
    await tester.pumpAndSettle();

    expect(find.byType(PieChart), findsOneWidget);
    await tester.tap(find.byTooltip('Switch to bar chart'));
    await tester.pumpAndSettle();
    expect(find.byType(BarChart), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to donut chart'));
    await tester.pumpAndSettle();
    expect(find.byType(PieChart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a touched slice expands without overflowing', (tester) async {
    await tester.pumpWidget(buildChart(ImagesPieChart(stats: stats)));
    await tester.pumpAndSettle();

    final chartFinder = find.byType(PieChart);
    final initialChart = tester.widget<PieChart>(chartFinder);
    initialChart.data.pieTouchData.touchCallback!(
      FlTapDownEvent(TapDownDetails(localPosition: const Offset(50, 50))),
      PieTouchResponse(
        touchLocation: const Offset(50, 50),
        touchedSection: PieTouchedSection(
          initialChart.data.sections.first,
          0,
          90,
          50,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pieChart = tester.widget<PieChart>(chartFinder);
    final chartSize = tester.getSize(chartFinder);
    final sections = pieChart.data.sections;
    final touchedRadius = sections.first.radius;
    expect(touchedRadius, greaterThan(sections.last.radius));
    // fl_chart paints sections outside the center space.
    final outerRadius = pieChart.data.centerSpaceRadius + touchedRadius;
    expect(outerRadius, lessThanOrEqualTo(chartSize.shortestSide / 2));
    expect(tester.takeException(), isNull);
  });
}
