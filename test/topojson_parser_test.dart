import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/topojson_parser.dart';

void main() {
  group('TopoJsonParser', () {
    test('normalizeToIso maps known names', () {
      expect(TopoJsonParser.normalizeToIso('Bolivia'), 'BO');
      expect(TopoJsonParser.normalizeToIso('United States'), 'US');
      expect(TopoJsonParser.normalizeToIso('Somalia'), 'SO');
      expect(TopoJsonParser.normalizeToIso('Ascension'), 'AC');
      expect(TopoJsonParser.normalizeToIso('Unknown Country'), isNull);
    });

    test('parses known and predicted countries with known precedence', () {
      final data = TopoJsonParser.parseDistribution(
        _topology(),
        'United States?, Mexico? | United States',
      );

      expect(data.polygons, hasLength(2));
      expect(data.polygons[0].status, DistributionStatus.known);
      expect(data.polygons[1].status, DistributionStatus.predicted);
      expect(data.bounds?.west, 1);
      expect(data.bounds?.south, 1);
      expect(data.bounds?.east, 4);
      expect(data.bounds?.north, 4);

      final features = data.featureCollection['features'] as List<dynamic>;
      expect(features, hasLength(2));
      expect((features.first as Map)['properties'], {
        'distributionStatus': 'known',
      });
    });

    test('preserves holes and closes rings', () {
      final topology = _topology(
        geometries: [
          {
            'type': 'Polygon',
            'arcs': [
              [0],
              [1],
            ],
            'properties': {'ISO_A2': 'US'},
          },
        ],
        arcs: [
          [
            [0, 0],
            [4, 0],
            [4, 4],
            [0, 4],
          ],
          [
            [1, 1],
            [2, 1],
            [2, 2],
            [1, 2],
          ],
        ],
      );

      final polygon = TopoJsonParser.parseDistribution(
        topology,
        'United States',
      ).polygons.single;

      expect(polygon.rings, hasLength(2));
      expect(polygon.rings.first, hasLength(5));
      expect(polygon.rings.last, hasLength(5));
      expect(
        polygon.rings.first.first.toGeoJson(),
        polygon.rings.first.last.toGeoJson(),
      );
    });

    test('expands every polygon in a multipolygon', () {
      final topology = _topology(
        geometries: [
          {
            'type': 'MultiPolygon',
            'arcs': [
              [
                [0],
              ],
              [
                [1],
              ],
            ],
            'properties': {'ISO_A2': 'US'},
          },
        ],
      );

      final data = TopoJsonParser.parseDistribution(topology, 'United States');

      expect(data.polygons, hasLength(2));
      expect(
        data.polygons.every((polygon) => polygon.rings.length == 1),
        isTrue,
      );
    });

    test('decodes reversed arcs and a TopoJSON transform', () {
      final topology = _topology(
        geometries: [
          {
            'type': 'Polygon',
            'arcs': [
              [-1],
            ],
            'properties': {'ISO_A2': 'US'},
          },
        ],
        arcs: [
          [
            [0, 0],
            [1, 0],
            [0, 1],
          ],
        ],
      );
      topology['transform'] = {
        'scale': [2, 3],
        'translate': [10, 20],
      };

      final ring = TopoJsonParser.parseDistribution(
        topology,
        'United States',
      ).polygons.single.rings.single;

      expect(ring.first.toGeoJson(), [12, 23]);
      expect(ring[1].toGeoJson(), [12, 20]);
      expect(ring[2].toGeoJson(), [10, 20]);
    });

    test('returns empty data for invalid topology and unknown countries', () {
      expect(
        TopoJsonParser.parseDistribution({}, 'United States').polygons,
        isEmpty,
      );
      expect(
        TopoJsonParser.parseDistribution(_topology(), 'Atlantis').polygons,
        isEmpty,
      );
      final malformed = _topology()
        ..['transform'] = {
          'scale': ['invalid'],
          'translate': const [],
        };
      expect(
        () => TopoJsonParser.parseDistribution(malformed, 'United States'),
        returnsNormally,
      );
    });
  });
}

Map<String, dynamic> _topology({
  List<Map<String, dynamic>>? geometries,
  List<List<List<num>>>? arcs,
}) => {
  'type': 'Topology',
  'objects': {
    'countries_mdd': {
      'type': 'GeometryCollection',
      'geometries':
          geometries ??
          [
            {
              'type': 'Polygon',
              'arcs': [
                [0],
              ],
              'properties': {'ISO_A2': 'US'},
            },
            {
              'type': 'Polygon',
              'arcs': [
                [1],
              ],
              'properties': {'ISO_A2': 'MX'},
            },
          ],
    },
  },
  'arcs':
      arcs ??
      [
        [
          [1, 1],
          [2, 1],
          [2, 2],
        ],
        [
          [3, 3],
          [4, 3],
          [4, 4],
        ],
      ],
};
