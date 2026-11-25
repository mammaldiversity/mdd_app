import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/home/setup.dart';

Widget _atWidth(double width) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: const SetupFeatures()),
    ),
  ),
);

double _tileWidth(WidgetTester tester, String label) => tester
    .getSize(
      find
          .ancestor(of: find.text(label), matching: find.byType(SizedBox))
          .first,
    )
    .width;

void main() {
  testWidgets('lays out at zero width, as on the first Android frame', (
    tester,
  ) async {
    await tester.pumpWidget(_atWidth(0));
    expect(tester.takeException(), isNull);
    expect(find.text('Works offline'), findsNothing);
  });

  testWidgets('uses one column when two tiles would be too narrow', (
    tester,
  ) async {
    await tester.pumpWidget(_atWidth(200));
    expect(tester.takeException(), isNull);
    expect(_tileWidth(tester, 'Works offline'), 200);
  });

  testWidgets('uses two columns at normal widths', (tester) async {
    await tester.pumpWidget(_atWidth(400));
    expect(tester.takeException(), isNull);
    expect(_tileWidth(tester, 'Works offline'), (400 - 8) / 2);
  });
}
