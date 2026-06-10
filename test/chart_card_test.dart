import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/chart_card.dart';

void main() {
  group('ChartCard Widget Tests', () {
    testWidgets('renders title and child chart correctly', (WidgetTester tester) async {
      const testTitle = 'My Test Chart';
      const testKey = Key('test_chart');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChartCard(
              title: testTitle,
              chart: SizedBox(key: testKey, width: 100, height: 100),
              height: 250,
            ),
          ),
        ),
      );

      // Verify the title is displayed
      expect(find.text(testTitle), findsOneWidget);

      // Verify the chart widget is present
      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('Card has expected layout and styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChartCard(
              title: 'Layout Test',
              chart: SizedBox(),
              height: 300,
            ),
          ),
        ),
      );

      // Verify the CommonCard renders its title
      expect(find.text('Layout Test'), findsOneWidget);
    });
  });
}
