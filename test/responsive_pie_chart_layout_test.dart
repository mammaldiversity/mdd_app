import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/screens/statistics/responsive_pie_chart_layout.dart';

void main() {
  Widget buildLayout({required double width, double height = 240}) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            height: height,
            child: ResponsivePieChartLayout(
              chartBuilder: (context, radiusScale) => ColoredBox(
                key: const ValueKey('test-chart'),
                color: Colors.blue,
              ),
              legend: const Indicator(
                color: Colors.red,
                text: 'CR - Critically Endangered: 1234 species (56.7 percent)',
                isSquare: true,
                expandText: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('puts the legend right of the chart in one horizontal scroll', (
    tester,
  ) async {
    await tester.pumpWidget(buildLayout(width: 320));

    final narrow = find.byKey(const ValueKey('responsive-pie-chart-narrow'));
    expect(narrow, findsOneWidget);
    expect(
      find.byKey(const ValueKey('responsive-pie-chart-wide')),
      findsNothing,
    );
    expect(
      tester.widget<SingleChildScrollView>(narrow).scrollDirection,
      Axis.horizontal,
    );

    final chartFinder = find.byKey(const ValueKey('test-chart'));
    expect(
      tester.getCenter(chartFinder).dx,
      lessThan(tester.getCenter(find.byType(Indicator)).dx),
    );

    // Long labels stay on one line and scroll together with the chart.
    expect(
      tester.getSize(find.textContaining('Critically')).height,
      lessThan(20),
    );
    final chartLeft = tester.getTopLeft(chartFinder).dx;
    await tester.drag(narrow, const Offset(-200, 0));
    await tester.pump();
    expect(tester.getTopLeft(chartFinder).dx, lessThan(chartLeft));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sizes the chart to the container height', (tester) async {
    await tester.pumpWidget(buildLayout(width: 375, height: 200));

    final chartSize = tester.getSize(find.byKey(const ValueKey('test-chart')));
    expect(chartSize.height, 200);
    expect(chartSize.width, 200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the narrow layout at 375 logical pixels', (tester) async {
    await tester.pumpWidget(buildLayout(width: 375));

    expect(
      find.byKey(const ValueKey('responsive-pie-chart-narrow')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the chart and legend side by side when wide', (
    tester,
  ) async {
    await tester.pumpWidget(buildLayout(width: 600));

    expect(
      find.byKey(const ValueKey('responsive-pie-chart-wide')),
      findsOneWidget,
    );

    final chartCenter = tester.getCenter(
      find.byKey(const ValueKey('test-chart')),
    );
    final legendCenter = tester.getCenter(find.byType(Indicator));
    expect(chartCenter.dx, lessThan(legendCenter.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('scales the full donut to fit the narrow chart box', (
    tester,
  ) async {
    late double scale;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              height: 254,
              child: ResponsivePieChartLayout(
                chartBuilder: (context, radiusScale) {
                  scale = radiusScale;
                  return const SizedBox(key: ValueKey('test-chart'));
                },
                legend: const Text('Legend'),
              ),
            ),
          ),
        ),
      ),
    );

    final chartSize = tester.getSize(find.byKey(const ValueKey('test-chart')));
    // Center space (38) + touched section radius (66).
    expect((38 + 66) * scale, lessThanOrEqualTo(chartSize.shortestSide / 2));
    expect(scale, greaterThan(0.5));
  });

  testWidgets('scales chart radii when the available extent is very small', (
    tester,
  ) async {
    double? observedScale;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 120,
              height: 180,
              child: ResponsivePieChartLayout(
                chartBuilder: (context, radiusScale) {
                  observedScale = radiusScale;
                  return const SizedBox();
                },
                legend: const Text('Legend'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(observedScale, isNotNull);
    expect(observedScale!, lessThan(1));
    expect(observedScale!, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
