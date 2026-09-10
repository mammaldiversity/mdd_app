import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mdd/services/distribution_map_style.dart';
import 'package:mdd/services/topojson_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('uses Liberty in light mode and Dark in dark mode', () {
    expect(
      DistributionMapStyleService.styleUrl(isDark: false),
      'https://tiles.openfreemap.org/styles/liberty',
    );
    expect(
      DistributionMapStyleService.styleUrl(isDark: true),
      'https://tiles.openfreemap.org/styles/dark',
    );
  });

  test('adds known and predicted layers to a remote style', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'version': 8, 'sources': {}, 'layers': []}),
        200,
      ),
    );

    final result = await DistributionMapStyleService.build(
      isDark: false,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      data: _data,
      client: client,
    );
    final style = jsonDecode(result.json) as Map<String, dynamic>;
    final layers = (style['layers'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(result.basemap, DistributionBasemap.openFreeMap);
    expect(
      (style['sources'] as Map),
      contains(DistributionMapStyleService.sourceId),
    );
    expect(
      layers.map((layer) => layer['id']),
      containsAll([
        'mdd-distribution-known-fill',
        'mdd-distribution-known-outline',
        'mdd-distribution-predicted-fill',
        'mdd-distribution-predicted-outline',
      ]),
    );
    final byId = {for (final layer in layers) layer['id'] as String: layer};
    expect(byId['mdd-distribution-known-fill']!['filter'], [
      '==',
      ['get', 'distributionStatus'],
      'known',
    ]);
    expect(
      (byId['mdd-distribution-known-fill']!['paint'] as Map)['fill-color'],
      '#117554',
    );
    expect(
      (byId['mdd-distribution-predicted-fill']!['paint'] as Map)['fill-color'],
      '#ffeb00',
    );
    expect(
      (byId['mdd-distribution-predicted-outline']!['paint']
          as Map)['line-color'],
      '#b5a600',
    );
  });

  test('falls back to bundled Natural Earth after an HTTP failure', () async {
    final result = await DistributionMapStyleService.build(
      isDark: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      data: _data,
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );
    final style = jsonDecode(result.json) as Map<String, dynamic>;

    expect(result.basemap, DistributionBasemap.naturalEarth);
    expect(
      style['sources'] as Map,
      contains(DistributionMapStyleService.naturalEarthSourceId),
    );
    final source =
        (style['sources']
                as Map)[DistributionMapStyleService.naturalEarthSourceId]
            as Map;
    expect(source['attribution'], 'Natural Earth');
  });
}

const _data = DistributionMapData(
  polygons: [
    DistributionPolygon(
      status: DistributionStatus.known,
      rings: [
        [
          MapCoordinate(0, 0),
          MapCoordinate(1, 0),
          MapCoordinate(1, 1),
          MapCoordinate(0, 0),
        ],
      ],
    ),
  ],
  bounds: DistributionBounds(west: 0, south: 0, east: 1, north: 1),
);
