import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/topojson_parser.dart';

void main() {
  group('TopoJsonParser', () {
    test('normalizeToIso maps correctly', () {
      expect(TopoJsonParser.normalizeToIso('Bolivia'), 'BO');
      expect(TopoJsonParser.normalizeToIso('United States'), 'US');
      expect(TopoJsonParser.normalizeToIso('Somalia'), 'SO');
      expect(TopoJsonParser.normalizeToIso('Ascension'), 'AC');
      expect(TopoJsonParser.normalizeToIso('Unknown Country'), null);
    });

    test('parsePolygons correctly identifies known and predicted', () {
      final json = {
        "type": "Topology",
        "objects": {
          "countries_mdd": {
            "type": "GeometryCollection",
            "geometries": [
              {
                "type": "Polygon",
                "arcs": [[0]],
                "properties": {
                  "ISO_A2": "US"
                }
              },
              {
                "type": "Polygon",
                "arcs": [[1]],
                "properties": {
                  "ISO_A2": "MX"
                }
              }
            ]
          }
        },
        "arcs": [
          [[1.0, 1.0], [2.0, 2.0]],
          [[3.0, 3.0], [4.0, 4.0]]
        ]
      };

      final knownCountries = {'US'};
      final predictedCountries = {'MX'};

      final polygons = TopoJsonParser.parsePolygons(json, knownCountries, predictedCountries);
      expect(polygons.length, 2);

      // Verify colors
      final knownPoly = polygons[0];
      final predictedPoly = polygons[1];

      expect(knownPoly.color, const Color(0xFF117554).withValues(alpha: 0.5));
      expect(predictedPoly.color, const Color(0xFFFFEB00).withValues(alpha: 0.5));
    });
  });
}
