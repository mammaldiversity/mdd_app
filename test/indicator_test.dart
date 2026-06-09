import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/indicator.dart';

void main() {
  group('Indicator Widget Tests', () {
    testWidgets('renders correctly with given text and color', (WidgetTester tester) async {
      const testColor = Colors.red;
      const testText = 'Test Indicator';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Indicator(
              color: testColor,
              text: testText,
              isSquare: true,
            ),
          ),
        ),
      );

      // Find the text
      expect(find.text(testText), findsOneWidget);

      // Verify the container has the correct color
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, testColor);
    });

    testWidgets('renders as a circle when isSquare is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Indicator(
              color: Colors.blue,
              text: 'Circle',
              isSquare: false,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('renders as a rectangle when isSquare is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Indicator(
              color: Colors.green,
              text: 'Rectangle',
              isSquare: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.rectangle);
    });
  });
}
