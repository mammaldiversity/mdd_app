import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/statistics/synonym_table_page.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/providers/database.dart';
import 'package:mdd/services/providers/statistics.dart';

void main() {
  late Directory dir;
  late AppDatabase db;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mdd_synonym_table_test');
    db = AppDatabase.forFile(File('${dir.path}/test.db'));
    await db.createMigrator().createAll();
    await db.batch((b) {
      b.insertAll(db.synonym, [
        // A blank record as mdd_api 0.10.1 writes for unparsable CSV rows.
        SynonymCompanion.insert(
          synId: const Value(0),
          hespId: const Value(0),
          authorityParentheses: const Value(0),
        ),
        SynonymCompanion.insert(
          synId: const Value(2),
          speciesId: const Value(20),
          species: const Value('Rattus'),
          rootName: const Value('norvegicus'),
          author: const Value('Berkenhout'),
          year: const Value('1769'),
          validity: const Value('valid'),
          typeCountry: const Value('NA'),
          genus: const Value('Rattus'),
          specificEpithet: const Value('norvegicus'),
          comments: const Value('Brown rat.'),
        ),
        SynonymCompanion.insert(
          synId: const Value(1),
          speciesId: const Value(10),
          originalCombination: const Value('Mus domesticus'),
          author: const Value('Schwarz'),
          year: const Value('1943'),
          validity: const Value('synonym'),
          nomenclatureStatus: const Value('name_combination|preoccupied'),
          originalRank: const Value('species'),
          typeCountry: const Value('Germany'),
          taxonOrder: const Value('Rodentia'),
          family: const Value('Muridae'),
          genus: const Value('Mus'),
          specificEpithet: const Value('musculus'),
          comments: const Value('House mouse.'),
          holotype: const Value('ZMB 1234'),
        ),
      ]);
    });
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('retrieveSynonymTable loads the shown text by valid species, '
      'without blank records', () async {
    final rows = await MddQuery(db).retrieveSynonymTable();

    expect(rows.map((r) => r.synId), [1, 2]);
    final mus = rows.first;
    expect(mus.name, 'Mus domesticus');
    expect(mus.author, 'Schwarz');
    expect(mus.validSpecies, 'Mus musculus');
    expect(mus.nomenclatureStatus, 'name combination, preoccupied');
    // Without an original combination, the name falls back to species
    // and root name; "NA" reads as empty.
    expect(rows[1].name, 'Rattus norvegicus');
    expect(rows[1].typeCountry, '');
  });

  test('retrieveSynonymById loads every column', () async {
    final row = await MddQuery(db).retrieveSynonymById(1);
    expect(row?.comments, 'House mouse.');
    expect(await MddQuery(db).retrieveSynonymById(99), isNull);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    final rows = await tester.runAsync(
      () => MddQuery(db).retrieveSynonymTable(),
    );
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithBuild((ref, notifier) => db),
          synonymTableProvider.overrideWith((ref) async => rows!),
        ],
        child: const MaterialApp(home: SynonymTablePage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists every synonym with readable labels', (tester) async {
    await pumpPage(tester);

    expect(find.text('Names and Synonyms'), findsOneWidget);
    expect(find.text('Records (2)'), findsOneWidget);
    expect(find.text('Mus domesticus'), findsOneWidget);
    expect(find.text('Rattus norvegicus'), findsNWidgets(2));
    expect(find.text('Mus musculus'), findsOneWidget);
    expect(find.text('name combination, preoccupied'), findsOneWidget);
    expect(find.text('NA'), findsNothing);
  });

  testWidgets('rows of one species keep their query order', (tester) async {
    // Over 32 rows, so List.sort leaves insertion sort and stops keeping
    // ties in order on its own.
    await tester.runAsync(
      () => db.batch((b) {
        b.insertAll(db.synonym, [
          for (var i = 0; i < 40; i++)
            SynonymCompanion.insert(
              synId: Value(100 + i),
              speciesId: const Value(10),
              species: const Value('Mus'),
              rootName: Value('name$i'),
              year: Value('${1700 + i}'),
              genus: const Value('Mus'),
              specificEpithet: const Value('musculus'),
            ),
        ]);
      }),
    );
    await pumpPage(tester);

    final shown = [
      for (var i = 0; i < 40; i++)
        if (find.text('${1700 + i}').evaluate().isNotEmpty)
          (i, tester.getTopLeft(find.text('${1700 + i}')).dy),
    ];
    expect(shown.map((e) => e.$1), [for (var i = 0; i < 25; i++) i]);
    for (var i = 1; i < shown.length; i++) {
      expect(shown[i - 1].$2, lessThan(shown[i].$2));
    }
  });

  testWidgets('search narrows the rows', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField).first, 'Germany');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Records (1)'), findsOneWidget);
    expect(find.text('Mus domesticus'), findsOneWidget);
    expect(find.text('Berkenhout'), findsNothing);
  });

  testWidgets('a row opens the full synonym details', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Mus domesticus'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    // The holotype isn't in the table query, so it shows the full record.
    expect(find.textContaining('ZMB 1234'), findsOneWidget);
  });
}
