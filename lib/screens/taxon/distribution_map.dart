import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:url_launcher/url_launcher.dart';

const String mapDescription = 'The map below provides a general overview. '
    'Most species inhabit only specific regions within countries.';

class DistributionMap extends StatefulWidget {
  const DistributionMap({super.key, required this.countryDistribution});
  final String? countryDistribution;

  @override
  State<DistributionMap> createState() => _DistributionMapState();
}

class _DistributionMapState extends State<DistributionMap> {
  List<Polygon> _polygons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolygons();
  }

  Future<void> _loadPolygons() async {
    if (widget.countryDistribution == null ||
        widget.countryDistribution!.isEmpty ||
        widget.countryDistribution == 'NA') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final String geoJsonData =
          await rootBundle.loadString('assets/data/countries.geojson');
      final Map<String, dynamic> json = jsonDecode(geoJsonData);
      final features = json['features'] as List;

      final Set<String> targetCountries = widget.countryDistribution!
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .toSet();

      bool isTargetCountry(String name) {
        final lowerName = name.toLowerCase();
        return targetCountries.any((target) =>
            target.contains(lowerName) || lowerName.contains(target));
      }

      List<Polygon> loadedPolygons = [];

      for (var feature in features) {
        final properties = feature['properties'] ?? {};
        final name = properties['name'] as String?;
        if (name != null && isTargetCountry(name)) {
          final geometry = feature['geometry'];
          if (geometry == null) continue;

          final type = geometry['type'];
          if (type == 'Polygon') {
            final coords = geometry['coordinates'] as List;
            if (coords.isNotEmpty) {
              loadedPolygons.add(_createPolygon(coords[0]));
            }
          } else if (type == 'MultiPolygon') {
            final coords = geometry['coordinates'] as List;
            for (var polyCoords in coords) {
              if ((polyCoords as List).isNotEmpty) {
                loadedPolygons.add(_createPolygon(polyCoords[0]));
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _polygons = loadedPolygons;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Polygon _createPolygon(List coordinates) {
    List<LatLng> points = [];
    for (var coord in coordinates) {
      final lon = (coord[0] as num).toDouble();
      final lat = (coord[1] as num).toDouble();
      points.add(LatLng(lat, lon));
    }
    return Polygon(
      points: points,
      color: const Color(0xFF117554)
          .withValues(alpha: 0.5), // Known color from website
      borderColor: const Color(0xFF117554),
      borderStrokeWidth: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.countryDistribution == null ||
        widget.countryDistribution!.isEmpty ||
        widget.countryDistribution == 'NA') {
      return const SizedBox.shrink();
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapUrl = isDarkMode
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    LatLngBounds? getBounds() {
      if (_polygons.isEmpty) return null;
      final points = _polygons.expand((p) => p.points).toList();
      if (points.isEmpty) return null;
      return LatLngBounds.fromPoints(points);
    }

    final bounds = getBounds();

    return CommonCard(
      title: 'Distribution Map',
      description: mapDescription,
      child: SizedBox(
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(0, 0),
                    initialZoom: 1,
                    initialCameraFit: bounds != null
                        ? CameraFit.bounds(
                            bounds: bounds,
                            padding: const EdgeInsets.all(16),
                          )
                        : null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: mapUrl,
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'org.mammaldiversity.mdd',
                    ),
                    if (_polygons.isNotEmpty)
                      PolygonLayer(
                        polygons: _polygons,
                      ),
                    RichAttributionWidget(
                      alignment: AttributionAlignment.bottomLeft,
                      openButton: (context, open) => IconButton(
                        onPressed: open,
                        tooltip: 'Attributions',
                        icon: Icon(
                          Icons.info_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      closeButton: (context, close) => IconButton(
                        onPressed: close,
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors, © CARTO',
                          onTap: () => launchUrl(
                              Uri.parse('https://carto.com/attributions')),
                        ),
                        TextSourceAttribution(
                          'Country Boundaries: Natural Earth',
                          onTap: () => launchUrl(
                              Uri.parse('https://www.naturalearthdata.com/')),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
