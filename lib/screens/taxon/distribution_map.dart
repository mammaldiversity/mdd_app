import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:maplibre/maplibre.dart';
import 'package:mdd/screens/shared/card.dart';
import 'package:mdd/screens/shared/maps/maplibre_camera_readiness.dart';
import 'package:mdd/screens/shared/maps/maplibre_gesture_surface.dart';
import 'package:mdd/screens/shared/maps/maplibre_load_watchdog.dart';
import 'package:mdd/services/distribution_map_style.dart';
import 'package:mdd/services/natural_earth.dart';
import 'package:mdd/services/providers/map_renderer.dart';
import 'package:mdd/services/topojson_parser.dart';
import 'package:url_launcher/url_launcher.dart';

final Future<List<NaturalEarthPolygon>> _naturalEarthPolygons =
    loadNaturalEarthPolygons();

class DistributionMap extends ConsumerStatefulWidget {
  const DistributionMap({super.key, required this.countryDistribution});

  final String? countryDistribution;

  @override
  ConsumerState<DistributionMap> createState() => _DistributionMapState();
}

class _DistributionMapState extends ConsumerState<DistributionMap> {
  DistributionMapData? _data;
  Object? _error;
  bool _isLoading = true;

  bool get _hasDistribution {
    final value = widget.countryDistribution;
    return value != null && value.isNotEmpty && value != 'NA';
  }

  @override
  void initState() {
    super.initState();
    _loadDistribution();
  }

  @override
  void didUpdateWidget(covariant DistributionMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryDistribution != widget.countryDistribution) {
      _loadDistribution();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasDistribution) return const SizedBox.shrink();

    final hasPredicted = widget.countryDistribution!.contains('?');
    return CommonCard(
      title: 'Distribution Map',
      description:
          'The map below provides a general overview. '
          'Some species inhabit only specific regions within countries.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPredicted) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _LegendItem(
                    color: DistributionMapStyleService.knownColor,
                    text: 'Known',
                  ),
                  _LegendItem(
                    color: DistributionMapStyleService.predictedColor,
                    text: 'Predicted distribution',
                    borderColor:
                        DistributionMapStyleService.predictedOutlineColor,
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
              child: _buildViewport(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewport() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return const _MapMessage('Unable to load the distribution map.');
    }
    final data = _data;
    if (data == null) return const SizedBox.shrink();
    return ref.watch(mapRendererProvider) == MapRenderer.mapLibre
        ? _MapLibreDistributionMap(data: data)
        : _NaturalEarthDistributionMap(key: ObjectKey(data), data: data);
  }

  Future<void> _loadDistribution() async {
    final requestedDistribution = widget.countryDistribution;
    if (!_hasDistribution) {
      if (!mounted) return;
      setState(() {
        _data = null;
        _error = null;
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _isLoading = true;
    });
    try {
      final source = await rootBundle.loadString(
        'assets/data/countries.geojson',
      );
      final topology = Map<String, dynamic>.from(jsonDecode(source) as Map);
      final data = TopoJsonParser.parseDistribution(
        topology,
        requestedDistribution!,
      );
      if (!mounted || widget.countryDistribution != requestedDistribution) {
        return;
      }
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading distribution map: $error');
      if (!mounted || widget.countryDistribution != requestedDistribution) {
        return;
      }
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }
}

class _MapLibreDistributionMap extends ConsumerWidget {
  const _MapLibreDistributionMap({required this.data});

  final DistributionMapData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = DistributionMapStyleService.build(
      isDark: Theme.of(context).brightness == Brightness.dark,
      colorScheme: Theme.of(context).colorScheme,
      data: data,
    );
    return FutureBuilder<DistributionMapStyle>(
      future: style,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _MapMessage('Unable to prepare the distribution map.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final value = snapshot.data!;
        return _MapLibreViewport(
          key: ValueKey(value.json.hashCode),
          data: data,
          style: value,
        );
      },
    );
  }
}

class _MapLibreViewport extends ConsumerStatefulWidget {
  const _MapLibreViewport({super.key, required this.data, required this.style});

  final DistributionMapData data;
  final DistributionMapStyle style;

  @override
  ConsumerState<_MapLibreViewport> createState() => _MapLibreViewportState();
}

class _MapLibreViewportState extends ConsumerState<_MapLibreViewport> {
  MapController? _controller;
  final _readiness = MapLibreCameraReadiness();
  late final _watchdog = MapLibreLoadWatchdog(onTimeout: _handleLoadTimeout);
  late final MapOptions _options = MapOptions(
    initStyle: widget.style.json,
    initCenter: const Geographic(lon: 0, lat: 18),
    initZoom: 1,
    minZoom: 1,
    maxZoom: 16,
    maxPitch: 0,
    gestures: const MapGestures(
      pan: true,
      zoom: true,
      rotate: false,
      pitch: false,
    ),
  );

  bool get _isReady => mounted && _readiness.isReady;

  @override
  void initState() {
    super.initState();
    _watchdog.start();
  }

  @override
  void dispose() {
    _watchdog.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      MapLibreMap(
        gestureRecognizers: {...mapLibreGestureRecognizers()},
        options: _options,
        onMapCreated: (controller) {
          if (!mounted) return;
          _controller = controller;
          _readiness.markMapCreated();
          _markRendered();
          _initializeCamera();
        },
        onStyleLoaded: (_) {
          _readiness.markStyleLoaded();
          _markRendered();
          _initializeCamera();
        },
        children: const [Positioned.fill(child: MapLibreGestureSurface())],
      ),
      if (_watchdog.isWaiting)
        const Positioned.fill(
          child: ColoredBox(
            color: Color(0x44000000),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      Positioned(
        left: 8,
        bottom: 8,
        child: _MapAttribution(basemap: widget.style.basemap),
      ),
      Positioned(
        right: 8,
        bottom: 8,
        child: _MapControls(
          onZoomIn: () => _changeZoom(1),
          onZoomOut: () => _changeZoom(-1),
          onReset: _resetCamera,
        ),
      ),
    ],
  );

  void _markRendered() {
    if (!_readiness.isReady) return;
    if (_watchdog.markReady() && mounted) setState(() {});
  }

  void _handleLoadTimeout() {
    if (!mounted) return;
    ref.read(mapRendererProvider.notifier).markMapLibreUnavailable();
  }

  Future<void> _initializeCamera() async {
    if (!_readiness.claimInitialCamera()) return;
    if (_readiness.takePendingReset()) {
      await _resetCamera();
      return;
    }
    await _fitDistribution();
  }

  Future<void> _fitDistribution() async {
    final controller = _controller;
    final bounds = widget.data.bounds;
    if (!_isReady || controller == null) return;
    if (bounds == null) {
      await controller.moveCamera(
        center: const Geographic(lon: 0, lat: 18),
        zoom: 1,
      );
      return;
    }
    await controller.fitBounds(
      bounds: LngLatBounds.fromPoints([
        Geographic(lon: bounds.west, lat: bounds.south),
        Geographic(lon: bounds.east, lat: bounds.north),
      ]),
      padding: const EdgeInsets.all(24),
      webMaxZoom: 8,
    );
  }

  Future<void> _resetCamera() async {
    final controller = _controller;
    if (!_isReady || controller == null) {
      _readiness.requestReset();
      return;
    }
    await _fitDistribution();
  }

  Future<void> _changeZoom(double amount) async {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    await controller.animateCamera(
      zoom: (controller.getCamera().zoom + amount).clamp(1, 16).toDouble(),
      nativeDuration: const Duration(milliseconds: 200),
    );
  }
}

class _NaturalEarthDistributionMap extends ConsumerStatefulWidget {
  const _NaturalEarthDistributionMap({super.key, required this.data});

  final DistributionMapData data;

  @override
  ConsumerState<_NaturalEarthDistributionMap> createState() =>
      _NaturalEarthDistributionMapState();
}

class _NaturalEarthDistributionMapState
    extends ConsumerState<_NaturalEarthDistributionMap> {
  final _controller = flutter_map.MapController();

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<NaturalEarthPolygon>>(
    future: _naturalEarthPolygons,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const _MapMessage('Unable to load the offline map.');
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final colorScheme = Theme.of(context).colorScheme;
      final bounds = _flutterBounds(widget.data.bounds);
      return Stack(
        children: [
          flutter_map.FlutterMap(
            mapController: _controller,
            options: flutter_map.MapOptions(
              initialCenter: const latlong.LatLng(18, 0),
              initialZoom: 1,
              minZoom: 1,
              maxZoom: 16,
              interactionOptions: const flutter_map.InteractionOptions(
                flags:
                    flutter_map.InteractiveFlag.all &
                    ~flutter_map.InteractiveFlag.rotate,
              ),
              initialCameraFit: bounds == null
                  ? null
                  : flutter_map.CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(24),
                    ),
            ),
            children: [
              ColoredBox(color: colorScheme.surface),
              flutter_map.PolygonLayer(
                polygons: [
                  for (final polygon in snapshot.data!)
                    flutter_map.Polygon(
                      points: polygon.points,
                      holePointsList: polygon.holes,
                      color: colorScheme.surfaceContainerHighest,
                      borderColor: colorScheme.outlineVariant,
                      borderStrokeWidth: 0.6,
                    ),
                  for (final polygon in widget.data.polygons)
                    flutter_map.Polygon(
                      points: [
                        for (final point in polygon.rings.first)
                          latlong.LatLng(point.latitude, point.longitude),
                      ],
                      holePointsList: [
                        for (final ring in polygon.rings.skip(1))
                          [
                            for (final point in ring)
                              latlong.LatLng(point.latitude, point.longitude),
                          ],
                      ],
                      color: _fillColor(polygon.status),
                      borderColor: _outlineColor(polygon.status),
                      borderStrokeWidth: 1,
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: mapLibreIsExpected
                ? _OfflineMapNotice(
                    onRetry: () =>
                        ref.read(mapRendererProvider.notifier).retryMapLibre(),
                  )
                : const _MapAttribution(
                    basemap: DistributionBasemap.naturalEarth,
                  ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: _MapControls(
              onZoomIn: () => _controller.move(
                _controller.camera.center,
                (_controller.camera.zoom + 1).clamp(1, 16).toDouble(),
              ),
              onZoomOut: () => _controller.move(
                _controller.camera.center,
                (_controller.camera.zoom - 1).clamp(1, 16).toDouble(),
              ),
              onReset: () {
                if (bounds == null) {
                  _controller.move(const latlong.LatLng(18, 0), 1);
                } else {
                  _controller.fitCamera(
                    flutter_map.CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(24),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      );
    },
  );

  flutter_map.LatLngBounds? _flutterBounds(DistributionBounds? bounds) {
    if (bounds == null) return null;
    return flutter_map.LatLngBounds(
      latlong.LatLng(bounds.south, bounds.west),
      latlong.LatLng(bounds.north, bounds.east),
    );
  }

  Color _fillColor(DistributionStatus status) => switch (status) {
    DistributionStatus.known =>
      DistributionMapStyleService.knownColor.withValues(alpha: 0.5),
    DistributionStatus.predicted =>
      DistributionMapStyleService.predictedColor.withValues(alpha: 0.5),
  };

  Color _outlineColor(DistributionStatus status) => switch (status) {
    DistributionStatus.known => DistributionMapStyleService.knownColor,
    DistributionStatus.predicted =>
      DistributionMapStyleService.predictedOutlineColor,
  };
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom in',
          visualDensity: VisualDensity.compact,
          onPressed: onZoomIn,
          icon: const Icon(Icons.add),
        ),
        IconButton(
          tooltip: 'Zoom out',
          visualDensity: VisualDensity.compact,
          onPressed: onZoomOut,
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          tooltip: 'Recenter map',
          visualDensity: VisualDensity.compact,
          onPressed: onReset,
          icon: const Icon(Icons.center_focus_strong_outlined),
        ),
      ],
    ),
  );
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution({required this.basemap});

  final DistributionBasemap basemap;

  @override
  Widget build(BuildContext context) {
    final isNaturalEarth = basemap == DistributionBasemap.naturalEarth;
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => launchUrl(
          Uri.parse(
            isNaturalEarth
                ? 'https://www.naturalearthdata.com/'
                : 'https://openfreemap.org/',
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            isNaturalEarth
                ? 'Natural Earth'
                : '© OpenStreetMap contributors · OpenFreeMap',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

class _OfflineMapNotice extends StatelessWidget {
  const _OfflineMapNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 6),
        const Icon(Icons.cloud_off_outlined, size: 18),
        const SizedBox(width: 6),
        Text(
          'Natural Earth · offline',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        IconButton(
          tooltip: 'Try the detailed map again',
          visualDensity: VisualDensity.compact,
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
        ),
      ],
    ),
  );
}

class _MapMessage extends StatelessWidget {
  const _MapMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.text,
    this.borderColor,
  });

  final Color color;
  final String text;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 1),
        ),
      ),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
