import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mdd/screens/shared/rule_filter_panel.dart';
import 'package:mdd/screens/statistics/table_filter_bar.dart';
import 'package:mdd/services/rule_filter.dart';

void main() {
  const columns = [
    RuleField(key: 0, label: 'Country'),
    RuleField(key: 1, label: 'Living Species', numeric: true),
  ];

  Future<RuleFilter<int>> Function() pumpBar(
    WidgetTester tester, {
    required double width,
  }) {
    var rules = const RuleFilter<int>();
    int? searchColumn;
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return () async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Padding(
                padding: const EdgeInsets.all(16),
                child: TableFilterBar(
                  controller: controller,
                  hintText: 'Search table...',
                  columns: columns,
                  searchColumn: searchColumn,
                  rules: rules,
                  onQueryChanged: (_) => setState(() {}),
                  onSearchColumnChanged: (v) =>
                      setState(() => searchColumn = v),
                  onRulesChanged: (v) => setState(() => rules = v),
                ),
              ),
            ),
          ),
        ),
      );
      return rules;
    };
  }

  for (final width in [360.0, 1024.0]) {
    testWidgets('adds and edits a rule at width $width', (tester) async {
      final pump = pumpBar(tester, width: width);
      await pump();

      expect(find.text('All columns'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Search table...'),
        'mexico',
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear), findsOneWidget);
      final rulesButton = width < 600
          ? find.byTooltip('Filter rules')
          : find.text('Rules');
      await tester.tap(rulesButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add rule'));
      await tester.pumpAndSettle();

      expect(find.text('contains'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Value'), 'bra');
      await tester.pumpAndSettle();
      if (width >= 600) expect(find.text('Rules (1)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Remove rule'));
      await tester.pumpAndSettle();
      expect(find.text('Add rule'), findsOneWidget);
      expect(find.text('Clear all'), findsNothing);
    });
  }

  testWidgets('reports typing after a pause', (tester) async {
    final queries = <String>[];
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TableFilterBar(
            controller: controller,
            hintText: 'Search table...',
            columns: columns,
            searchColumn: null,
            rules: const RuleFilter(),
            onQueryChanged: queries.add,
            onSearchColumnChanged: (_) {},
            onRulesChanged: (_) {},
          ),
        ),
      ),
    );
    final field = find.widgetWithText(TextField, 'Search table...');
    await tester.enterText(field, 'm');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(field, 'me');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(field, 'mex');
    expect(queries, isEmpty);
    // The clear button shows right away, before the table updates.
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    expect(queries, ['mex']);

    await tester.tap(find.byIcon(Icons.clear));
    expect(queries, ['mex', '']);
  });
}
