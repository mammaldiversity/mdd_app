import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mdd/screens/home/stats.dart';
import 'package:mdd/screens/taxon/external_resources.dart';
import 'package:mdd/styles/themes.dart';
import 'package:mdd/services/database/database.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/gbif_map_style.dart';
import 'package:mdd/services/topojson_parser.dart';
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
        expect(request.url.queryParameters['basisOfRecord'], isNull);
        if (request.url.path.endsWith('capabilities.json')) {
          return _json({
            'minLat': -37,
            'maxLat': 70,
            'minLng': -159,
            'maxLng': 101,
            'total': 16157,
          });
        }
        return _json({'count': 12345});
      });
      final summary = await GbifClient(client).fetchSummary('Panthera leo');
      expect(summary?.taxonKey, 5219404);
      expect(summary?.occurrences, 12345);
      expect(summary?.extent, (
        south: -37.0,
        west: -159.0,
        north: 70.0,
        east: 101.0,
      ));
    });

    test('has no extent without georeferenced records', () async {
      final client = MockClient((_) async => _json({'count': 0, 'facets': []}));
      expect(await GbifClient(client).occurrenceExtent(1), isNull);
    });

    test('returns null when there is no match', () async {
      final client = MockClient((_) async => _json({'matchType': 'NONE'}));
      expect(await GbifClient(client).fetchSummary('Nothing here'), isNull);
    });

    test('builds tile URLs', () {
      expect(GbifClient.densityTileUrl(42), contains('taxonKey=42'));
      expect(GbifClient.densityTileUrl(42), isNot(contains('basisOfRecord')));
      expect(GbifClient.basemapTileUrl(isDark: true), contains('gbif-dark'));
      expect(GbifClient.speciesPageUrl(42), 'https://www.gbif.org/species/42');
    });
  });

  group('GbifMapStyleService', () {
    test('adds density tiles over the OpenFreeMap basemap', () async {
      final client = MockClient(
        (_) async => _json({'version': 8, 'sources': {}, 'layers': []}),
      );
      final style = await GbifMapStyleService.build(
        isDark: false,
        taxonKey: 42,
        client: client,
      );
      expect(style.basemap, GbifBasemap.openFreeMap);
      final json = jsonDecode(style.json) as Map<String, dynamic>;
      final density = json['sources']['gbif-density'] as Map<String, dynamic>;
      expect(density['tiles'].single, contains('taxonKey=42'));
      expect(density['tileSize'], 512);
      expect((json['layers'] as List).last['id'], 'gbif-density');
    });

    test('outlines MDD countries above the density layer', () async {
      final client = MockClient(
        (_) async => _json({'version': 8, 'sources': {}, 'layers': []}),
      );
      const distribution = DistributionMapData(
        polygons: [
          DistributionPolygon(
            rings: [
              [
                MapCoordinate(0, 0),
                MapCoordinate(1, 0),
                MapCoordinate(1, 1),
                MapCoordinate(0, 0),
              ],
            ],
            status: DistributionStatus.predicted,
          ),
        ],
        bounds: null,
      );
      final style = await GbifMapStyleService.build(
        isDark: false,
        taxonKey: 42,
        distribution: distribution,
        client: client,
      );
      final json = jsonDecode(style.json) as Map<String, dynamic>;
      final ids = [for (final layer in json['layers'] as List) layer['id']];
      expect(ids, [
        'gbif-density',
        'mdd-distribution-halo',
        'mdd-distribution-known',
        'mdd-distribution-predicted',
      ]);
      final predicted = (json['layers'] as List).last as Map<String, dynamic>;
      expect(predicted['paint']['line-dasharray'], isNotNull);
    });

    test('falls back to the GBIF raster basemap offline', () async {
      final client = MockClient((_) async => http.Response('', 503));
      final style = await GbifMapStyleService.build(
        isDark: true,
        taxonKey: 42,
        client: client,
      );
      expect(style.basemap, GbifBasemap.gbif);
      expect(style.json, contains('gbif-dark'));
    });
  });

  group('DistributionOverlayColors', () {
    // WCAG 2.x relative luminance and contrast ratio.
    double luminance(Color color) {
      double channel(double c) => c <= 0.03928
          ? c / 12.92
          : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
      return 0.2126 * channel(color.r) +
          0.7152 * channel(color.g) +
          0.0722 * channel(color.b);
    }

    double contrast(Color a, Color b) {
      final la = luminance(a), lb = luminance(b);
      return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
    }

    // Land, water and wood of the OpenFreeMap and GBIF basemaps.
    const lightBasemaps = [
      Color(0xFFF2F3F0),
      Color(0xFFC2C8CA),
      Color(0xFFDCE0DC),
      Color(0xFFD0D0D0),
    ];
    const darkBasemaps = [
      Color(0xFF0C0C0C),
      Color(0xFF1B1B1D),
      Color(0xFF202020),
      Color(0xFF303030),
    ];

    for (final isDark in [false, true]) {
      test('outlines clear 3:1 (WCAG 1.4.11), dark: $isDark', () {
        final halo = DistributionOverlayColors.halo(isDark: isDark);
        for (final line in [
          DistributionOverlayColors.known(isDark: isDark),
          DistributionOverlayColors.predicted(isDark: isDark),
        ]) {
          expect(contrast(line, halo), greaterThanOrEqualTo(4.5));
          for (final basemap in isDark ? darkBasemaps : lightBasemaps) {
            expect(contrast(line, basemap), greaterThanOrEqualTo(3));
          }
        }
      });
    }
  });

  group('statValueColor', () {
    for (final theme in [MddTheme.lightTheme(), MddTheme.darkTheme()]) {
      testWidgets('clears 4.5:1 on cards (WCAG 1.4.3), '
          '${theme.brightness.name}', (tester) async {
        late Color value;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                value = statValueColor(context);
                return const SizedBox();
              },
            ),
          ),
        );
        final double a = value.computeLuminance();
        final double b = theme.colorScheme.surfaceContainerLow
            .computeLuminance();
        final double ratio = (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
        expect(ratio, greaterThanOrEqualTo(4.5));
      });
    }
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

  group('formatBases', () {
    test('picks the unit and three significant figures', () {
      expect(formatBases(2297552363), (value: '2.30', unit: 'Gb'));
      expect(formatBases(245173502), (value: '245', unit: 'Mb'));
      expect(formatBases(17240), (value: '17.2', unit: 'kb'));
      expect(formatBases(512), (value: '512', unit: 'bp'));
    });
  });

  group('GeneComposition', () {
    test('sums gene types into categories', () {
      const genes = GeneComposition({
        'PROTEIN_CODING': 19483,
        'PSEUDO': 3546,
        'ncRNA': 6552,
        'tRNA': 713,
        'OTHER': 131,
      });
      expect(genes.total, 30425);
      expect(genes.byCategory, {
        GeneCategory.proteinCoding: 19483,
        GeneCategory.rna: 7265,
        GeneCategory.pseudo: 3546,
        GeneCategory.other: 131,
      });
    });
  });

  group('NcbiDatasetsClient', () {
    Map<String, dynamic> report(String accession, String level, int n50) => {
      'accession': accession,
      'organism': {'organism_name': 'Panthera leo'},
      'assembly_info': {'assembly_level': level},
      'assembly_stats': {
        'total_sequence_length': '2297552363',
        'contig_n50': n50,
      },
    };

    test('uses the reference genome when there is one', () async {
      final client = MockClient((request) async {
        if (request.url.path.endsWith('/counts')) {
          return _json({
            'report': [
              {'gene_type': 'PROTEIN_CODING', 'count': 100},
            ],
          });
        }
        if (request.url.queryParameters['filters.reference_only'] == 'true') {
          return _json({
            'reports': [
              {
                ...report('GCF_1', 'Chromosome', 1),
                'assembly_info': {
                  'assembly_level': 'Chromosome',
                  'refseq_category': 'reference genome',
                },
              },
            ],
          });
        }
        expect(request.url.queryParameters['returned_content'], 'ASSM_ACC');
        return _json({'total_count': 4, 'reports': []});
      });
      final summary = await NcbiDatasetsClient(
        client,
      ).fetchSummary('Panthera leo');
      expect(summary.assembly?.accession, 'GCF_1');
      expect(summary.assembly?.isReference, isTrue);
      expect(summary.assembly?.genomeSize, 2297552363);
      expect(summary.assemblyCount, 4);
      expect(summary.genes.total, 100);
    });

    test('chooses the most complete assembly without a reference', () async {
      final client = MockClient((request) async {
        final query = request.url.queryParameters;
        if (request.url.path.endsWith('/counts')) return _json({'report': []});
        if (query['filters.reference_only'] == 'true') return _json({});
        if (query['returned_content'] == 'ASSM_ACC') {
          return _json({'total_count': 2});
        }
        return _json({
          'reports': [
            report('GCA_contig', 'Contig', 900000),
            report('GCA_chrom', 'Chromosome', 1000),
          ],
        });
      });
      final summary = await NcbiDatasetsClient(
        client,
      ).fetchSummary('Panthera leo');
      expect(summary.assembly?.accession, 'GCA_chrom');
      expect(summary.assembly?.isReference, isFalse);
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
            genomeSummaryProvider.overrideWith(
              (ref, name) async => const GenomeSummary(
                assembly: GenomeAssembly(
                  accession: 'GCF_018350215.1',
                  isReference: true,
                  genomeSize: 2297552363,
                ),
                assemblyCount: 3,
                genes: GeneComposition({'PROTEIN_CODING': 3, 'tRNA': 1}),
              ),
            ),
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
            crossrefWorksProvider.overrideWith(
              (ref, name) async => const [
                CrossrefWork(
                  title: 'Diet of Panthera leo in Kenya',
                  authors: 'Smith et al.',
                  year: 2024,
                  journal: 'Journal of Mammalogy',
                  doi: '10.1/a',
                ),
                CrossrefWork(
                  title: 'Panthera leo genetics',
                  authors: 'Doe',
                  year: 1998,
                  journal: 'Mammalia',
                  doi: '10.1/b',
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
      expect(find.text('1,200'), findsOneWidget);
      expect(
        find.text(
          'Fetched automatically from NCBI (GenBank and Datasets) and not '
          'curated by the MDD team. Its taxonomy may differ from MDD.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reference genome'), findsOneWidget);
      expect(find.text('2.30 Gb'), findsOneWidget);
      expect(find.text('Annotated genes'), findsOneWidget);
      expect(find.text('Records in NCBI'), findsOneWidget);
    });

    testWidgets('opens a dialog on wide screens', (tester) async {
      await pumpPanel(tester, const Size(1000, 800));
      await tester.tap(find.text('Genetics'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Genetic data · GenBank'), findsOneWidget);
      expect(find.text('2.30 Gb'), findsOneWidget);
    });

    for (final size in const [Size(375, 812), Size(1000, 800)]) {
      testWidgets('shows publication stats and copies a citation at '
          '${size.width.toInt()} px', (tester) async {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
        await pumpPanel(tester, size);
        await tester.tap(find.text('Publications'));
        await tester.pumpAndSettle();
        expect(find.text('Latest'), findsOneWidget);
        expect(find.text('2024'), findsOneWidget);
        expect(find.text('Earliest'), findsOneWidget);
        expect(find.text('1998'), findsOneWidget);
        expect(find.text('Copy citation'), findsNWidgets(2));
        await tester.tap(find.text('Copy citation').first);
        await tester.pump();
        expect(find.text('Copied'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('Copied'), findsNothing);
      });
    }
  });
}
