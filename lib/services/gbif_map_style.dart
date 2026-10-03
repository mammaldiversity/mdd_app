import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:mdd/services/distribution_map_style.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/topojson_parser.dart';

/// Colours for the MDD country outlines drawn over the GBIF map.
///
/// Each outline sits on a halo in [halo], so what it has to contrast with is
/// the halo, whatever basemap or occurrence hexagon lies beneath. Every pair
/// clears the WCAG 1.4.11 ratio of 3:1 for graphics: known 5.6:1 and
/// predicted 5.6:1 on the light halo, 10.2:1 and 13.8:1 on the dark one.
/// Against the basemaps alone, without the halo, they still clear 3.3:1.
///
/// Known and predicted also differ by line pattern, solid against dashed,
/// so status is never told by colour alone (WCAG 1.4.1).
class DistributionOverlayColors {
  DistributionOverlayColors._();

  static Color known({required bool isDark}) =>
      isDark ? const Color(0xFF4FD1A1) : const Color(0xFF117554);

  static Color predicted({required bool isDark}) =>
      isDark ? const Color(0xFFF5D90A) : const Color(0xFF8A5A00);

  static Color halo({required bool isDark}) =>
      isDark ? const Color(0xFF0C0C0C) : const Color(0xFFFFFFFF);

  static const double lineWidth = 2;
  static const double haloWidth = 5;

  /// Dash and gap, in line widths.
  static const List<double> dash = [2, 1.5];
}

enum GbifBasemap { openFreeMap, gbif }

class GbifMapStyle {
  const GbifMapStyle({required this.json, required this.basemap});

  final String json;
  final GbifBasemap basemap;
}

/// MapLibre styles for the GBIF occurrence density map: the OpenFreeMap
/// basemap the distribution map uses, with GBIF's density tiles on top.
///
/// GBIF's own raster basemap is the fallback when OpenFreeMap cannot be
/// reached, since the density tiles need the network anyway.
class GbifMapStyleService {
  GbifMapStyleService._();

  static const densitySourceId = 'gbif-density';
  static const distributionSourceId = 'mdd-distribution';
  static const basemapSourceId = 'gbif-basemap';

  static Future<GbifMapStyle> build({
    required bool isDark,
    required int taxonKey,
    DistributionMapData? distribution,
    http.Client? client,
  }) async {
    final ownedClient = client == null ? http.Client() : null;
    final effectiveClient = client ?? ownedClient!;
    try {
      final response = await effectiveClient
          .get(Uri.parse(DistributionMapStyleService.styleUrl(isDark: isDark)))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final style = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        _addDensity(style, taxonKey);
        _addDistribution(style, distribution, isDark: isDark);
        return GbifMapStyle(
          json: jsonEncode(style),
          basemap: GbifBasemap.openFreeMap,
        );
      }
    } catch (_) {
      // Falls through to GBIF's raster basemap.
    } finally {
      ownedClient?.close();
    }
    final style = <String, dynamic>{
      'version': 8,
      'name': 'MDD GBIF',
      'sources': {
        basemapSourceId: _raster(
          GbifClient.basemapTileUrl(isDark: isDark),
          '© GBIF · OpenMapTiles · OpenStreetMap contributors',
        ),
      },
      'layers': [
        {'id': 'gbif-basemap', 'type': 'raster', 'source': basemapSourceId},
      ],
    };
    _addDensity(style, taxonKey);
    _addDistribution(style, distribution, isDark: isDark);
    return GbifMapStyle(json: jsonEncode(style), basemap: GbifBasemap.gbif);
  }

  static Map<String, dynamic> _raster(String url, String attribution) => {
    'type': 'raster',
    'tiles': [url],
    // GBIF serves 512 px tiles at @1x.
    'tileSize': 512,
    'attribution': attribution,
  };

  static void _addDensity(Map<String, dynamic> style, int taxonKey) {
    final sources = Map<String, dynamic>.from(style['sources'] as Map? ?? {});
    sources[densitySourceId] = _raster(
      GbifClient.densityTileUrl(taxonKey),
      '© GBIF',
    );
    style['sources'] = sources;
    style['layers'] = [
      ...(style['layers'] as List? ?? const []),
      {'id': 'gbif-density', 'type': 'raster', 'source': densitySourceId},
    ];
  }

  /// MDD's countries as outlines above the occurrences: a halo under every
  /// line, then known countries solid and predicted ones dashed.
  static void _addDistribution(
    Map<String, dynamic> style,
    DistributionMapData? distribution, {
    required bool isDark,
  }) {
    if (distribution == null || distribution.polygons.isEmpty) return;
    final sources = Map<String, dynamic>.from(style['sources'] as Map? ?? {});
    sources[distributionSourceId] = {
      'type': 'geojson',
      'data': distribution.featureCollection,
    };
    style['sources'] = sources;
    Map<String, dynamic> line(
      DistributionStatus status,
      Color color, {
      bool dashed = false,
    }) => {
      'id': 'mdd-distribution-${status.name}',
      'type': 'line',
      'source': distributionSourceId,
      'filter': [
        '==',
        ['get', 'distributionStatus'],
        status.name,
      ],
      'layout': {'line-join': 'round', 'line-cap': 'round'},
      'paint': {
        'line-color': _hex(color),
        'line-width': DistributionOverlayColors.lineWidth,
        if (dashed) 'line-dasharray': DistributionOverlayColors.dash,
      },
    };
    style['layers'] = [
      ...(style['layers'] as List? ?? const []),
      {
        'id': 'mdd-distribution-halo',
        'type': 'line',
        'source': distributionSourceId,
        'layout': {'line-join': 'round', 'line-cap': 'round'},
        'paint': {
          'line-color': _hex(DistributionOverlayColors.halo(isDark: isDark)),
          'line-width': DistributionOverlayColors.haloWidth,
          'line-opacity': 0.9,
        },
      },
      line(
        DistributionStatus.known,
        DistributionOverlayColors.known(isDark: isDark),
      ),
      line(
        DistributionStatus.predicted,
        DistributionOverlayColors.predicted(isDark: isDark),
        dashed: true,
      ),
    ];
  }

  static String _hex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }
}
