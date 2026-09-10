import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mdd/services/natural_earth.dart';
import 'package:mdd/services/topojson_parser.dart';

enum DistributionBasemap { openFreeMap, naturalEarth }

class DistributionMapStyle {
  const DistributionMapStyle({required this.json, required this.basemap});

  final String json;
  final DistributionBasemap basemap;
}

class DistributionMapStyleService {
  DistributionMapStyleService._();

  static const sourceId = 'mdd-distribution';
  static const naturalEarthSourceId = 'mdd-natural-earth';
  static const knownColor = Color(0xFF117554);
  static const predictedColor = Color(0xFFFFEB00);
  static const predictedOutlineColor = Color(0xFFB5A600);

  static String styleUrl({required bool isDark}) =>
      'https://tiles.openfreemap.org/styles/${isDark ? 'dark' : 'liberty'}';

  static Future<DistributionMapStyle> build({
    required bool isDark,
    required ColorScheme colorScheme,
    required DistributionMapData data,
    http.Client? client,
  }) async {
    final ownedClient = client == null ? http.Client() : null;
    final effectiveClient = client ?? ownedClient!;
    try {
      final response = await effectiveClient
          .get(Uri.parse(styleUrl(isDark: isDark)))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final style = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        _addDistribution(style, data);
        return DistributionMapStyle(
          json: jsonEncode(style),
          basemap: DistributionBasemap.openFreeMap,
        );
      }
    } catch (_) {
      // The bundled Natural Earth style is the intentional offline path.
    } finally {
      ownedClient?.close();
    }

    final style = _blankStyle(colorScheme);
    await _addNaturalEarth(style, colorScheme);
    _addDistribution(style, data);
    return DistributionMapStyle(
      json: jsonEncode(style),
      basemap: DistributionBasemap.naturalEarth,
    );
  }

  static Map<String, dynamic> _blankStyle(ColorScheme colorScheme) => {
    'version': 8,
    'name': 'MDD Natural Earth',
    'sources': <String, dynamic>{},
    'layers': [
      {
        'id': 'mdd-background',
        'type': 'background',
        'paint': {'background-color': _hex(colorScheme.surface)},
      },
    ],
  };

  static Future<void> _addNaturalEarth(
    Map<String, dynamic> style,
    ColorScheme colorScheme,
  ) async {
    final sources = Map<String, dynamic>.from(style['sources'] as Map? ?? {});
    sources[naturalEarthSourceId] = {
      'type': 'geojson',
      'data': await loadNaturalEarthGeoJson(),
      'attribution': 'Natural Earth',
    };
    style['sources'] = sources;
    final layers = _layers(style);
    layers.addAll([
      {
        'id': 'mdd-natural-earth-fill',
        'type': 'fill',
        'source': naturalEarthSourceId,
        'paint': {
          'fill-color': _hex(colorScheme.surfaceContainerHighest),
          'fill-opacity': 1,
        },
      },
      {
        'id': 'mdd-natural-earth-outline',
        'type': 'line',
        'source': naturalEarthSourceId,
        'paint': {
          'line-color': _hex(colorScheme.outlineVariant),
          'line-width': 0.6,
        },
      },
    ]);
    style['layers'] = layers;
  }

  static void _addDistribution(
    Map<String, dynamic> style,
    DistributionMapData data,
  ) {
    final sources = Map<String, dynamic>.from(style['sources'] as Map? ?? {});
    sources[sourceId] = {'type': 'geojson', 'data': data.featureCollection};
    style['sources'] = sources;
    final layers = _layers(style);
    layers.addAll([
      _fillLayer(DistributionStatus.known, knownColor),
      _lineLayer(DistributionStatus.known, knownColor),
      _fillLayer(DistributionStatus.predicted, predictedColor),
      _lineLayer(DistributionStatus.predicted, predictedOutlineColor),
    ]);
    style['layers'] = layers;
  }

  static Map<String, dynamic> _fillLayer(
    DistributionStatus status,
    Color color,
  ) => {
    'id': 'mdd-distribution-${status.name}-fill',
    'type': 'fill',
    'source': sourceId,
    'filter': [
      '==',
      ['get', 'distributionStatus'],
      status.name,
    ],
    'paint': {'fill-color': _hex(color), 'fill-opacity': 0.5},
  };

  static Map<String, dynamic> _lineLayer(
    DistributionStatus status,
    Color color,
  ) => {
    'id': 'mdd-distribution-${status.name}-outline',
    'type': 'line',
    'source': sourceId,
    'filter': [
      '==',
      ['get', 'distributionStatus'],
      status.name,
    ],
    'paint': {'line-color': _hex(color), 'line-width': 1},
  };

  static List<Map<String, dynamic>> _layers(Map<String, dynamic> style) =>
      (style['layers'] as List? ?? const [])
          .map((layer) => Map<String, dynamic>.from(layer as Map))
          .toList();

  static String _hex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }
}
