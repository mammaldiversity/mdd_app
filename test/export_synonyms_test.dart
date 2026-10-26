import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/export.dart';

void main() {
  test('synonymFileName sits next to the species file', () {
    expect(synonymFileName('export', ExportFormat.csv), 'export_synonyms.csv');
    expect(
      synonymFileName('rodents.json', ExportFormat.json),
      'rodents_synonyms.json',
    );
  });

  group('csvToTsv', () {
    test('keeps quoted commas, quotes, and line breaks in one column', () {
      const csv =
          'id,mainCommonName,typeLocality\r\n'
          '1,House Mouse,"Uppsala, Sweden"\r\n'
          '2,"Rat, ""Norway""","line one\nline two"\r\n'
          '3,,\r\n';
      expect(
        csvToTsv(csv),
        'id\tmainCommonName\ttypeLocality\n'
        '1\tHouse Mouse\tUppsala, Sweden\n'
        '2\tRat, "Norway"\tline one line two\n'
        '3\t\t\n',
      );
    });

    test('handles a missing final line break and empty input', () {
      expect(parseCsv('a,b\n1,2'), [
        ['a', 'b'],
        ['1', '2'],
      ]);
      expect(csvToTsv(''), '');
    });
  });

  group('retrieveSynonymDataList', () {
    late Directory dir;
    late AppDatabase db;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('mdd_export_test');
      db = AppDatabase.forFile(File('${dir.path}/test.db'));
      await db.createMigrator().createAll();
      await db.batch((b) {
        b.insertAll(db.synonym, [
          SynonymCompanion.insert(
            synId: const Value(10),
            speciesId: const Value(2),
            rootName: const Value('norvegicus'),
          ),
          SynonymCompanion.insert(
            synId: const Value(11),
            speciesId: const Value(1),
            rootName: const Value('domesticus'),
            author: const Value('Rutty, Jr.'),
          ),
          SynonymCompanion.insert(
            synId: const Value(12),
            speciesId: const Value(3),
            rootName: const Value('excluded'),
          ),
        ]);
      });
    });

    tearDown(() async {
      await db.close();
      await dir.delete(recursive: true);
    });

    test('returns only synonyms of the exported species', () async {
      final synonyms = await MddQuery(db).retrieveSynonymDataList([1, 2]);
      expect(synonyms.map((s) => s.synId), [11, 10]);

      final records = synonyms.map((s) => s.toJson()).toList();
      final headers = records.first.keys.toList();
      final csv = TableDataExporter.toCsv(headers, [
        for (final r in records) [for (final h in headers) r[h]],
      ]);
      final lines = csv.trim().split('\n');
      expect(lines.first, contains('speciesId'));
      expect(lines, hasLength(3));
      expect(csv, contains('"Rutty, Jr."'));
    });
  });
}
