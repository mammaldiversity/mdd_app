import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/indicator.dart';

void main() {
  group('Indicator Widget Tests', () {
    testWidgets('renders correctly with given text and color', (
      WidgetTester tester,
    ) async {
      const testColor = Colors.red;
      const testText = 'Test Indicator';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Indicator(color: testColor, text: testText, isSquare: true),
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

    testWidgets('renders as a circle when isSquare is false', (
      WidgetTester tester,
    ) async {
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

    testWidgets('renders as a rectangle when isSquare is true', (
      WidgetTester tester,
    ) async {
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

    testWidgets('wraps long text when expanded inside a narrow width', (
      WidgetTester tester,
    ) async {
      const testText =
          'CR - Critically Endangered: 1234 species (56.7 percent)';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              child: Indicator(
                color: Colors.red,
                text: testText,
                isSquare: true,
                expandText: true,
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.text(testText)).height, greaterThan(20));
      expect(tester.takeException(), isNull);
    });
  });
}
