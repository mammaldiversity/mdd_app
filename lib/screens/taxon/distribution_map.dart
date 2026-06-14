import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mdd/services/topojson_parser.dart';

class DistributionMap extends StatefulWidget {
  const DistributionMap({super.key, required this.countryDistribution});
  final String? countryDistribution;

  @override
  State<DistributionMap> createState() => _DistributionMapState();
}

class _DistributionMapState extends State<DistributionMap> {
  List<Polygon> _polygons = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

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

      final Set<String> knownCountries = {};
      final Set<String> predictedCountries = {};

      final parts = widget.countryDistribution!.split(RegExp(r'[|,]'));
      for (var p in parts) {
        final country = p.trim();
        if (country.isEmpty) continue;

        bool isPredicted = country.endsWith('?');
        final rawName = isPredicted
            ? country.substring(0, country.length - 1).trim()
            : country;

        final isoCode = TopoJsonParser.normalizeToIso(rawName);
        if (isoCode != null) {
          if (isPredicted) {
            predictedCountries.add(isoCode);
          } else {
            knownCountries.add(isoCode);
          }
        }
      }

      final loadedPolygons = TopoJsonParser.parsePolygons(
          json, knownCountries, predictedCountries);

      if (mounted) {
        setState(() {
          _polygons = loadedPolygons;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading Map: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.countryDistribution == null ||
        widget.countryDistribution!.isEmpty ||
        widget.countryDistribution == 'NA') {
      return const SizedBox.shrink();
    }

    final hasPredicted = widget.countryDistribution!.contains('?');
    final String mapDescription = 'The map below provides a general overview. '
        'Some species inhabit only specific regions within countries.';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPredicted) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildLegendItem(context,
                      color: const Color(0xFF117554), text: 'Known'),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                    context,
                    color: const Color(0xFFFFEB00),
                    text: 'Predicted distribution',
                    borderColor: const Color(0xFFB5A600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
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
                            MediaQuery.removePadding(
                              context: context,
                              removeBottom: true,
                              removeLeft: true,
                              removeRight: true,
                              removeTop: true,
                              child: RichAttributionWidget(
                                alignment: AttributionAlignment.bottomLeft,
                                openButton: (context, open) => IconButton(
                                  onPressed: open,
                                  tooltip: 'Attributions',
                                  icon: Icon(
                                    Icons.info_outlined,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                closeButton: (context, close) => IconButton(
                                  onPressed: close,
                                  icon: Icon(
                                    Icons.cancel_outlined,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                attributions: [
                                  TextSourceAttribution(
                                    'OpenStreetMap contributors, © CARTO',
                                    onTap: () => launchUrl(Uri.parse(
                                        'https://carto.com/attributions')),
                                  ),
                                  TextSourceAttribution(
                                    'Country Boundaries: Natural Earth',
                                    onTap: () => launchUrl(Uri.parse(
                                        'https://www.naturalearthdata.com/')),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: FloatingActionButton.small(
                            heroTag: null,
                            onPressed: () {
                              if (bounds != null) {
                                _mapController.fitCamera(
                                  CameraFit.bounds(
                                    bounds: bounds,
                                    padding: const EdgeInsets.all(16),
                                  ),
                                );
                              } else {
                                _mapController.move(const LatLng(0, 0), 1);
                              }
                            },
                            tooltip: 'Recenter Map',
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            elevation: 4,
                            child: Icon(
                              Icons.center_focus_strong,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context,
      {required Color color, required String text, Color? borderColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
