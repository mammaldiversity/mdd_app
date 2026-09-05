import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/chart_export_dialog.dart';
import 'package:mdd/screens/statistics/stat_table_page.dart';
import 'package:mdd/services/export.dart';
import 'package:mdd/services/providers/settings.dart';

class _FakeShowInfoTextSetting extends ShowInfoTextSetting {
  @override
  bool build() => true;
}

void main() {
  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        showInfoTextProvider.overrideWith(() => _FakeShowInfoTextSetting()),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('TableDataExporter Unit Tests', () {
    const headers = ['Order', 'Count', 'Percentage'];
    final rows = [
      ['Rodentia', 2600, '39.00%'],
      ['Chiroptera', 1400, '21.00%'],
      ['Eulipotyphla, "shrews"', 500, '7.50%'],
    ];

    test('toCsv produces RFC 4180 compliant CSV', () {
      final csv = TableDataExporter.toCsv(headers, rows);
      final lines = csv.trim().split('\n');

      expect(lines.length, 4);
      expect(lines[0].trim(), 'Order,Count,Percentage');
      expect(lines[1].trim(), 'Rodentia,2600,39.00%');
      expect(lines[2].trim(), 'Chiroptera,1400,21.00%');
      // Quotes and commas should be properly quoted and escaped
      expect(lines[3].trim(), '"Eulipotyphla, ""shrews""",500,7.50%');
    });

    test('toTsv produces tab-separated text and cleans tabs/newlines', () {
      final tsvRows = [
        ['Order\tWithTab', 10, '1.0%'],
        ['Order\nWithNewline', 20, '2.0%'],
      ];
      final tsv = TableDataExporter.toTsv(headers, tsvRows);
      final lines = tsv.trim().split('\n');

      expect(lines.length, 3);
      expect(lines[0].trim(), 'Order\tCount\tPercentage');
      // Tabs and newlines should be replaced with spaces
      expect(lines[1].trim(), 'Order WithTab\t10\t1.0%');
      expect(lines[2].trim(), 'Order WithNewline\t20\t2.0%');
    });

    test('toJson produces structured JSON array of objects', () {
      final jsonStr = TableDataExporter.toJson(headers, rows);
      final dynamic decoded = json.decode(jsonStr);

      expect(decoded, isA<List<dynamic>>());
      final list = decoded as List<dynamic>;
      expect(list.length, 3);

      expect(list[0]['Order'], 'Rodentia');
      expect(list[0]['Count'], 2600);
      expect(list[0]['Percentage'], '39.00%');

      expect(list[2]['Order'], 'Eulipotyphla, "shrews"');
      expect(list[2]['Count'], 500);
    });

    test('serialize delegates correctly based on ExportFormat', () {
      final exporterCsv = TableDataExporter(
        fileName: 'test',
        format: ExportFormat.csv,
        headers: headers,
        rows: rows,
      );
      expect(exporterCsv.serialize(), contains('Order,Count,Percentage'));

      final exporterTsv = TableDataExporter(
        fileName: 'test',
        format: ExportFormat.tsv,
        headers: headers,
        rows: rows,
      );
      expect(exporterTsv.serialize(), contains('Order\tCount\tPercentage'));

      final exporterJson = TableDataExporter(
        fileName: 'test',
        format: ExportFormat.json,
        headers: headers,
        rows: rows,
      );
      expect(exporterJson.serialize(), contains('"Order": "Rodentia"'));
    });
  });

  group('ChartExportDialog Widget Tests', () {
    testWidgets('renders dialog with default file name and export formats', (
      WidgetTester tester,
    ) async {
      ExportSettings? submittedSettings;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  submittedSettings = await showDialog<ExportSettings>(
                    context: context,
                    builder: (_) => const ChartExportDialog(
                      defaultFileName: 'sample_chart_export',
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify title, filename field, and formats
      expect(find.text('Export Table Data'), findsOneWidget);
      expect(find.text('sample_chart_export'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('TSV'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);

      // Tap TSV format
      await tester.tap(find.text('TSV'));
      await tester.pumpAndSettle();

      // Tap Export button
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();

      expect(submittedSettings, isNotNull);
      expect(submittedSettings!.fileName, 'sample_chart_export');
      expect(submittedSettings!.format, ExportFormat.tsv);
    });
  });

  group('StatTablePage Widget Tests', () {
    final columns = const [
      StatTableColumn(title: 'Order'),
      StatTableColumn(title: 'Species Count', numeric: true),
      StatTableColumn(title: 'Percentage', numeric: true),
    ];

    final rows = [
      const StatTableRow(
        values: ['Rodentia', 2600, '39.00%'],
        searchText: 'Rodentia',
      ),
      const StatTableRow(
        values: ['Chiroptera', 1400, '21.00%'],
        searchText: 'Chiroptera bats',
      ),
      const StatTableRow(
        values: ['Carnivora', 300, '4.50%'],
        searchText: 'Carnivora',
      ),
      const StatTableRow(
        values: ['Cetartiodactyla', 350, '5.20%'],
        searchText: 'Cetartiodactyla whales',
      ),
    ];

    testWidgets('renders table, headers, info text and initial rows', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatTablePage(
            title: 'Species Diversity by Order',
            infoText: 'Summary of orders',
            exportDefaultFileName: 'order_diversity',
            columns: columns,
            rows: rows,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Species Diversity by Order'), findsOneWidget);
      expect(find.text('Summary of orders'), findsOneWidget);
      expect(find.text('Rodentia'), findsOneWidget);
      expect(find.text('Chiroptera'), findsOneWidget);
      expect(find.text('Carnivora'), findsOneWidget);
      expect(find.text('Cetartiodactyla'), findsOneWidget);
    });

    testWidgets('filters rows when searching', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatTablePage(
            title: 'Species Diversity by Order',
            infoText: 'Summary of orders',
            exportDefaultFileName: 'order_diversity',
            columns: columns,
            rows: rows,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'bats');
      await tester.pumpAndSettle();

      // Only Chiroptera should match
      expect(find.text('Chiroptera'), findsOneWidget);
      expect(find.text('Rodentia'), findsNothing);
      expect(find.text('Carnivora'), findsNothing);
    });

    testWidgets('sorts rows when column header is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatTablePage(
            title: 'Species Diversity by Order',
            infoText: 'Summary of orders',
            exportDefaultFileName: 'order_diversity',
            columns: columns,
            rows: rows,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Order column header to sort
      await tester.tap(find.text('Order'));
      await tester.pumpAndSettle();

      // Verify the page still renders properly and without errors
      expect(find.text('Carnivora'), findsOneWidget);
    });
  });
}
