import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/home/release_changes.dart';
import 'package:mdd/services/providers/statistics.dart';
import 'package:mdd/services/release_changes.dart';

const _source = '''
[
  {"version": "2.4", "prevVersion": "2.3", "releaseDate": "2026-01-02",
   "deNovo": 22, "split": 23, "lump": 9, "added": 0, "removed": 1},
  {"version": "2.10", "prevVersion": "2.9", "releaseDate": null,
   "deNovo": 1, "split": 0, "lump": 4, "added": 0, "removed": 0},
  {"version": "2.5", "prevVersion": "2.4", "releaseDate": "2026-07-28",
   "deNovo": 27, "split": 11, "lump": 6, "added": 1, "removed": 0}
]
''';

void main() {
  group('parseReleaseChanges', () {
    final releases = parseReleaseChanges(_source);

    test('sorts newest release first by numeric version', () {
      expect(releases.map((r) => r.version), ['2.10', '2.5', '2.4']);
    });

    test('nets additions against lumps and removals', () {
      final v25 = releases[1];
      expect(v25.gained, 39);
      expect(v25.lost, 6);
      expect(v25.net, 33);
      expect(releases[2].net, 35);
      expect(releases[0].net, -3);
    });

    test('reads a missing date as null', () {
      expect(releases[0].releaseDate, isNull);
      expect(releases[1].releaseDate, DateTime(2026, 7, 28));
    });
  });

  test('formatSignedCount', () {
    expect(formatSignedCount(33), '+33');
    expect(formatSignedCount(-3), '−3');
    expect(formatSignedCount(0), '0');
  });

  Future<void> pumpAtWidth(WidgetTester tester, double width) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          releaseChangesProvider.overrideWith(
            (ref) async => parseReleaseChanges(_source),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: width, child: const TaxonomyChanges()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('wide screens show the release ledger with a total', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpAtWidth(tester, 1000);

    expect(find.text('Change in MDD taxonomy'), findsOneWidget);
    expect(find.text('Since v2.3'), findsOneWidget);
    expect(find.text('+65'), findsOneWidget);
    expect(find.text('net species over 3 releases'), findsOneWidget);
    for (final version in ['v2.10', 'v2.5', 'v2.4']) {
      expect(find.text(version), findsOneWidget);
    }
    expect(find.text('Jul 2026'), findsOneWidget);
  });

  testWidgets('phones show swipeable release cards, newest first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpAtWidth(tester, 360);

    expect(find.text('Since v2.3'), findsNothing);
    expect(find.text('v2.10'), findsOneWidget);
    expect(find.text('−3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('v2.5 · Jul 2026'), findsOneWidget);
    expect(find.textContaining('27 de novo · 11 splits'), findsOneWidget);
  });
}
