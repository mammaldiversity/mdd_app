import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mdd/screens/taxon/external_resources.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/providers/external_resources.dart';

http.Response _json(Object body) => http.Response(jsonEncode(body), 200);

void main() {
  group('formatCount', () {
    test('adds thousands separators', () {
      expect(formatCount(0), '0');
      expect(formatCount(999), '999');
      expect(formatCount(12345), '12,345');
      expect(formatCount(1234567), '1,234,567');
    });
  });

  group('GbifClient', () {
    test('uses accepted key and fetches occurrence count', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/v1/species/match') {
          expect(request.url.queryParameters['name'], 'Panthera leo');
          return _json({
            'matchType': 'EXACT',
            'usageKey': 1,
            'acceptedUsageKey': 5219404,
            'species': 'Panthera leo',
          });
        }
        expect(request.url.queryParameters['taxonKey'], '5219404');
        return _json({'count': 12345});
      });
      final summary = await GbifClient(client).fetchSummary('Panthera leo');
      expect(summary?.taxonKey, 5219404);
      expect(summary?.occurrences, 12345);
    });

    test('returns null when there is no match', () async {
      final client = MockClient((_) async => _json({'matchType': 'NONE'}));
      expect(await GbifClient(client).fetchSummary('Nothing here'), isNull);
    });

    test('builds tile URLs', () {
      expect(GbifClient.densityTileUrl(42), contains('taxonKey=42'));
      expect(GbifClient.basemapTileUrl(isDark: true), contains('gbif-dark'));
      expect(GbifClient.speciesPageUrl(42), 'https://www.gbif.org/species/42');
    });
  });

  group('GenBankClient', () {
    test('parses counts for each database', () async {
      final requests = <Uri>[];
      final client = MockClient((request) async {
        requests.add(request.url);
        final db = request.url.queryParameters['db'];
        final term = request.url.queryParameters['term']!;
        final count = switch (db) {
          'assembly' => '3',
          'gene' => '20000',
          _ => term.contains('mitochondrion') ? '150' : '9000',
        };
        return _json({
          'esearchresult': {'count': count},
        });
      });
      final counts = await GenBankClient(
        client,
        requestGap: Duration.zero,
      ).fetchSummary('Panthera leo');
      expect(counts.map((e) => e.count), [3, 20000, 150, 9000]);
      expect(
        requests.first.queryParameters['term'],
        '"Panthera leo"[Organism]',
      );
    });
  });

  group('CrossrefClient', () {
    test('keeps works with the binomial in the title', () async {
      final client = MockClient(
        (_) async => _json({
          'message': {
            'items': [
              {
                'DOI': '10.1/a',
                'title': ['Diet of <i>Panthera leo</i> in Kenya'],
                'author': [
                  {'family': 'Smith', 'given': 'Jane Ann'},
                  {'family': 'Doe'},
                  {'family': 'Roe'},
                ],
                'issued': {
                  'date-parts': [
                    [2020, 5],
                  ],
                },
                'container-title': ['Journal of Mammalogy'],
                'volume': '101',
                'issue': '2',
                'page': '12-20',
              },
              {
                'DOI': '10.1/b',
                'title': ['Unrelated lions'],
              },
            ],
          },
        }),
      );
      final works = await CrossrefClient(client).fetchWorks('Panthera leo');
      expect(works, hasLength(1));
      expect(works.first.title, 'Diet of Panthera leo in Kenya');
      expect(works.first.authors, 'Smith et al.');
      expect(works.first.year, 2020);
      expect(works.first.journal, 'Journal of Mammalogy');
      expect(works.first.url, 'https://doi.org/10.1/a');
      expect(works.first.source, 'Journal of Mammalogy, 101 (2), 12-20');
      expect(
        works.first.citation,
        'Smith, J. A., Doe, Roe. (2020). Diet of Panthera leo in Kenya. '
        'Journal of Mammalogy, 101 (2), 12-20. https://doi.org/10.1/a',
      );
    });

    test('groups works by year, newest first', () {
      CrossrefWork work(int? year) => CrossrefWork(
        title: 't',
        authors: '',
        year: year,
        journal: '',
        doi: 'd',
      );
      final groups = CrossrefClient.groupByYear([
        work(2001),
        work(null),
        work(2020),
        work(2001),
      ]);
      expect(groups.map((g) => g.$1), [2020, 2001, null]);
      expect(groups[1].$2, hasLength(2));
    });
  });

  group('CrossrefWork', () {
    test('strips escaped markup from titles', () {
      final work = CrossrefWork.fromJson({
        'DOI': '10.1/x',
        'title': [
          'Tool use in capuchins ( &lt;i&gt;Cebus capucinus&lt;/i&gt; ) &amp; kin',
        ],
      });
      expect(work.title, 'Tool use in capuchins (Cebus capucinus) & kin');
    });
  });

  group('italicizeName', () {
    test('italicizes each occurrence, ignoring case', () {
      final spans = italicizeName(
        'On panthera leo and Panthera leo',
        'Panthera leo',
      );
      expect(spans.map((s) => s.text), [
        'On ',
        'panthera leo',
        ' and ',
        'Panthera leo',
      ]);
      expect(spans[1].style?.fontStyle, FontStyle.italic);
    });
  });

  group('ExternalResourcesPanel', () {
    const taxon = TaxonomyData(
      id: 1,
      genus: 'Panthera',
      specificEpithet: 'leo',
    );

    Future<void> pumpPanel(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            genBankSummaryProvider.overrideWith(
              (ref, name) async => const [
                GenBankCount(
                  record: GenBankRecord.genes,
                  label: 'Genes',
                  description: 'NCBI Gene records',
                  count: 1200,
                  url: 'https://example.org',
                ),
              ],
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ExternalResourcesPanel(taxonData: taxon),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows tiles in a row on wide screens', (tester) async {
      await pumpPanel(tester, const Size(1000, 800));
      final occ = tester.getCenter(find.text('Occurrences'));
      final gen = tester.getCenter(find.text('Genetics'));
      expect(occ.dy, gen.dy);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('stacks tiles on phones and opens a bottom sheet', (
      tester,
    ) async {
      await pumpPanel(tester, const Size(375, 812));
      final occ = tester.getCenter(find.text('Occurrences'));
      final gen = tester.getCenter(find.text('Genetics'));
      expect(gen.dy, greaterThan(occ.dy));

      await tester.tap(find.text('Genetics'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('1,200 records', findRichText: true), findsOneWidget);
      expect(find.text(externalDataNote), findsOneWidget);
    });

    testWidgets('opens a dialog on wide screens', (tester) async {
      await pumpPanel(tester, const Size(1000, 800));
      await tester.tap(find.text('Genetics'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Genetic data · GenBank'), findsOneWidget);
    });
  });
}
