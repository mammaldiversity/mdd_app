import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    if (widget.countryDistribution == null || widget.countryDistribution!.isEmpty || widget.countryDistribution == 'NA') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final String geoJsonData = await rootBundle.loadString('assets/data/countries.geojson');
      final Map<String, dynamic> json = jsonDecode(geoJsonData);
      final features = json['features'] as List;

      final Set<String> targetCountries = widget.countryDistribution!
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .toSet();

      bool isTargetCountry(String name) {
        final lowerName = name.toLowerCase();
        return targetCountries.any((target) => target.contains(lowerName) || lowerName.contains(target));
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
      color: const Color(0xFF117554).withOpacity(0.5), // Known color from website
      borderColor: const Color(0xFF117554),
      borderStrokeWidth: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.countryDistribution == null || widget.countryDistribution!.isEmpty || widget.countryDistribution == 'NA') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Distribution Map',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(0, 0),
                initialZoom: 1,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'org.mammaldiversity.mdd',
                ),
                if (!_isLoading && _polygons.isNotEmpty)
                  PolygonLayer(
                    polygons: _polygons,
                  ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
