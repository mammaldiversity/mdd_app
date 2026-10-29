import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:maplibre/maplibre.dart';
import 'package:mdd/screens/shared/maps/map_controls.dart';
import 'package:mdd/screens/shared/maps/maplibre_camera_readiness.dart';
import 'package:mdd/screens/shared/maps/maplibre_gesture_surface.dart';
import 'package:mdd/services/external_resources.dart';
import 'package:mdd/services/gbif_map_style.dart';
import 'package:mdd/services/providers/map_renderer.dart';
import 'package:mdd/services/topojson_parser.dart';
import 'package:mdd/services/vector_basemap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart' as vmt;

/// GBIF's occurrence density map, fitted to where the records are.
///
/// Drawn with MapLibre where it runs, like the distribution map, and with
/// flutter_map elsewhere or when MapLibre fails to load.
class GbifDensityMap extends ConsumerWidget {
  const GbifDensityMap({
    super.key,
    required this.taxonKey,
    this.extent,
    this.distribution,
  });

  final int taxonKey;

  /// Where the records are; the camera opens fitted to it.
  final OccurrenceExtent? extent;

  /// MDD's countries, outlined over the records.
  final DistributionMapData? distribution;

  /// The records and the MDD range together, so neither opens off-screen.
  OccurrenceExtent? get _fitExtent {
    final bounds = distribution?.bounds;
    final OccurrenceExtent? range = bounds == null
        ? null
        : (
            south: bounds.south,
            west: bounds.west,
            north: bounds.north,
            east: bounds.east,
          );
    final a = extent;
    if (a == null || range == null) return a ?? range;
    return (
      south: math.min(a.south, range.south),
      west: math.min(a.west, range.west),
      north: math.max(a.north, range.north),
      east: math.max(a.east, range.east),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(mapRendererProvider) == MapRenderer.mapLibre
        ? _GbifMapLibreMap(
            taxonKey: taxonKey,
            extent: _fitExtent,
            distribution: distribution,
          )
        : _GbifFlutterMap(
            taxonKey: taxonKey,
            extent: _fitExtent,
            distribution: distribution,
          );
  }
}

const double _minZoom = 0;
const double _maxZoom = 14;

/// Never closer than a region: a species known from one locality would
/// otherwise open at street level.
const double _fitMaxZoom = 6;
const EdgeInsets _fitPadding = EdgeInsets.all(24);

class _GbifMapLibreMap extends StatefulWidget {
  const _GbifMapLibreMap({
    required this.taxonKey,
    this.extent,
    this.distribution,
  });

  final int taxonKey;
  final OccurrenceExtent? extent;
  final DistributionMapData? distribution;

  @override
  State<_GbifMapLibreMap> createState() => _GbifMapLibreMapState();
}

class _GbifMapLibreMapState extends State<_GbifMapLibreMap> {
  Future<GbifMapStyle>? _style;
  Brightness? _brightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (brightness == _brightness) return;
    _brightness = brightness;
    _style = GbifMapStyleService.build(
      isDark: brightness == Brightness.dark,
      taxonKey: widget.taxonKey,
      distribution: widget.distribution,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<GbifMapStyle>(
    future: _style,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final style = snapshot.data!;
      return _GbifMapLibreViewport(
        key: ValueKey(style.json.hashCode),
        style: style,
        extent: widget.extent,
      );
    },
  );
}

class _GbifMapLibreViewport extends StatefulWidget {
  const _GbifMapLibreViewport({super.key, required this.style, this.extent});

  final GbifMapStyle style;
  final OccurrenceExtent? extent;

  @override
  State<_GbifMapLibreViewport> createState() => _GbifMapLibreViewportState();
}

class _GbifMapLibreViewportState extends State<_GbifMapLibreViewport> {
  MapController? _controller;
  final _readiness = MapLibreCameraReadiness();
  late final MapOptions _options = MapOptions(
    initStyle: widget.style.json,
    initCenter: const Geographic(lon: 0, lat: 18),
    initZoom: 1,
    minZoom: _minZoom,
    maxZoom: _maxZoom,
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
  void dispose() {
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
          _initializeCamera();
        },
        onStyleLoaded: (_) {
          _readiness.markStyleLoaded();
          _initializeCamera();
        },
        children: const [Positioned.fill(child: MapLibreGestureSurface())],
      ),
      Positioned(
        left: 8,
        bottom: 8,
        child: _BasemapAttribution(basemap: widget.style.basemap),
      ),
      Positioned(
        right: 8,
        bottom: 8,
        child: MapControls(
          onZoomIn: () => _changeZoom(1),
          onZoomOut: () => _changeZoom(-1),
          onReset: _resetCamera,
        ),
      ),
    ],
  );

  Future<void> _initializeCamera() async {
    if (!_readiness.claimInitialCamera()) return;
    _readiness.takePendingReset();
    await _fitRecords();
  }

  Future<void> _fitRecords() async {
    final controller = _controller;
    final extent = widget.extent;
    if (!_isReady || controller == null) return;
    if (extent == null) {
      await controller.moveCamera(
        center: const Geographic(lon: 0, lat: 18),
        zoom: 1,
      );
      return;
    }
    await controller.fitBounds(
      bounds: LngLatBounds.fromPoints([
        Geographic(lon: extent.west, lat: extent.south),
        Geographic(lon: extent.east, lat: extent.north),
      ]),
      padding: _fitPadding,
      webMaxZoom: _fitMaxZoom,
    );
  }

  Future<void> _resetCamera() async {
    if (!_isReady || _controller == null) {
      _readiness.requestReset();
      return;
    }
    await _fitRecords();
  }

  Future<void> _changeZoom(double amount) async {
    final controller = _controller;
    if (!_isReady || controller == null) return;
    await controller.animateCamera(
      zoom: (controller.getCamera().zoom + amount).clamp(_minZoom, _maxZoom),
      nativeDuration: const Duration(milliseconds: 200),
    );
  }
}

/// The occurrence map drawn with `flutter_map`: the only renderer on
/// desktop, and the stand-in for a MapLibre map that failed on mobile.
///
/// On desktop the basemap is the OpenFreeMap vector style the distribution
/// map uses, so both maps match. GBIF's raster basemap stands in when that
/// style fails and on the mobile fallback, since the density tiles need the
/// network anyway.
class _GbifFlutterMap extends ConsumerStatefulWidget {
  const _GbifFlutterMap({
    required this.taxonKey,
    this.extent,
    this.distribution,
  });

  final int taxonKey;

  /// Where the records are; the camera opens fitted to it.
  final OccurrenceExtent? extent;
  final DistributionMapData? distribution;

  @override
  ConsumerState<_GbifFlutterMap> createState() => _GbifFlutterMapState();
}

class _GbifFlutterMapState extends ConsumerState<_GbifFlutterMap> {
  static const latlong.LatLng _worldCenter = latlong.LatLng(18, 0);

  final _controller = flutter_map.MapController();

  flutter_map.CameraFit? get _fit {
    final extent = widget.extent;
    if (extent == null) return null;
    // GBIF unwraps an extent across the antimeridian (e.g. 136 to 462), which
    // flutter_map bounds reject, so such records fit the whole width.
    final bool crossesAntimeridian = extent.west < -180 || extent.east > 180;
    return flutter_map.CameraFit.bounds(
      bounds: flutter_map.LatLngBounds(
        latlong.LatLng(extent.south, crossesAntimeridian ? -180 : extent.west),
        latlong.LatLng(extent.north, crossesAntimeridian ? 180 : extent.east),
      ),
      padding: _fitPadding,
      maxZoom: _fitMaxZoom,
    );
  }

  void _zoomBy(double delta) => _controller.move(
    _controller.camera.center,
    (_controller.camera.zoom + delta).clamp(_minZoom, _maxZoom),
  );

  void _recenter() {
    final fit = _fit;
    if (fit == null) {
      _controller.move(_worldCenter, 1);
    } else {
      _controller.fitCamera(fit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final vectorStyle = mapLibreIsExpected
        ? null
        : ref.watch(vectorBasemapStyleProvider(isDark));
    final loadedStyle = vectorStyle?.value;
    final bool useGbifBasemap = vectorStyle == null || vectorStyle.hasError;
    return Stack(
      children: [
        flutter_map.FlutterMap(
          mapController: _controller,
          options: flutter_map.MapOptions(
            initialCenter: _worldCenter,
            initialZoom: 1,
            initialCameraFit: _fit,
            backgroundColor: Theme.of(context).colorScheme.surface,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            interactionOptions: flutter_map.InteractionOptions(
              flags:
                  flutter_map.InteractiveFlag.all &
                  ~flutter_map.InteractiveFlag.rotate,
            ),
          ),
          children: [
            if (loadedStyle != null)
              vmt.VectorTileLayer(
                theme: loadedStyle.theme,
                sprites: loadedStyle.sprites,
                tileProviders: loadedStyle.providers,
              )
            else if (useGbifBasemap)
              flutter_map.TileLayer(
                urlTemplate: GbifClient.basemapTileUrl(isDark: isDark),
                userAgentPackageName: 'com.hhandika.mdd',
              ),
            flutter_map.TileLayer(
              urlTemplate: GbifClient.densityTileUrl(widget.taxonKey),
              userAgentPackageName: 'com.hhandika.mdd',
            ),
            if (widget.distribution != null)
              _distributionLayer(widget.distribution!, isDark: isDark),
          ],
        ),
        if (loadedStyle != null || useGbifBasemap)
          Positioned(
            left: 8,
            bottom: 8,
            child: _BasemapAttribution(
              basemap: loadedStyle != null
                  ? GbifBasemap.openFreeMap
                  : GbifBasemap.gbif,
            ),
          ),
        Positioned(
          right: 8,
          bottom: 8,
          child: MapControls(
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
            onReset: _recenter,
          ),
        ),
      ],
    );
  }

  /// The halo first, then the outline, mirroring the MapLibre style.
  Widget _distributionLayer(DistributionMapData data, {required bool isDark}) {
    List<latlong.LatLng> ring(List<MapCoordinate> points) => [
      for (final point in points)
        latlong.LatLng(point.latitude, point.longitude),
    ];
    flutter_map.Polygon outline(
      DistributionPolygon polygon,
      Color color,
      double width, {
      bool dashed = false,
    }) => flutter_map.Polygon(
      points: ring(polygon.rings.first),
      holePointsList: [for (final hole in polygon.rings.skip(1)) ring(hole)],
      color: Colors.transparent,
      borderColor: color,
      borderStrokeWidth: width,
      pattern: dashed
          ? flutter_map.StrokePattern.dashed(
              segments: [
                for (final unit in DistributionOverlayColors.dash)
                  unit * DistributionOverlayColors.lineWidth,
              ],
            )
          : const flutter_map.StrokePattern.solid(),
    );
    return flutter_map.PolygonLayer(
      polygons: [
        for (final polygon in data.polygons)
          outline(
            polygon,
            DistributionOverlayColors.halo(
              isDark: isDark,
            ).withValues(alpha: 0.9),
            DistributionOverlayColors.haloWidth,
          ),
        for (final polygon in data.polygons)
          polygon.status == DistributionStatus.known
              ? outline(
                  polygon,
                  DistributionOverlayColors.known(isDark: isDark),
                  DistributionOverlayColors.lineWidth,
                )
              : outline(
                  polygon,
                  DistributionOverlayColors.predicted(isDark: isDark),
                  DistributionOverlayColors.lineWidth,
                  dashed: true,
                ),
      ],
    );
  }
}

class _BasemapAttribution extends StatelessWidget {
  const _BasemapAttribution({required this.basemap});

  final GbifBasemap basemap;

  @override
  Widget build(BuildContext context) {
    final bool isOpenFreeMap = basemap == GbifBasemap.openFreeMap;
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => launchUrl(
          Uri.parse(
            isOpenFreeMap
                ? 'https://openfreemap.org/'
                : 'https://www.gbif.org/',
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            isOpenFreeMap
                ? '© OpenStreetMap contributors · OpenFreeMap'
                : '© GBIF · OpenMapTiles · OpenStreetMap contributors',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}

/// Names every mark on the occurrence map in text, so nothing on it is told
/// by colour alone.
class GbifMapLegend extends StatelessWidget {
  const GbifMapLegend({super.key, required this.hasDistribution});

  final bool hasDistribution;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextStyle? style = Theme.of(context).textTheme.bodySmall;
    Widget item(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: swatch),
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: style)),
      ],
    );
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        item(const _HexSwatch(), 'Occurrences (GBIF; darker is fewer)'),
        if (hasDistribution) ...[
          item(
            _LineSwatch(
              color: DistributionOverlayColors.known(isDark: isDark),
              halo: DistributionOverlayColors.halo(isDark: isDark),
            ),
            'Known countries (MDD)',
          ),
          item(
            _LineSwatch(
              color: DistributionOverlayColors.predicted(isDark: isDark),
              halo: DistributionOverlayColors.halo(isDark: isDark),
              dashed: true,
            ),
            'Predicted countries (MDD)',
          ),
        ],
      ],
    );
  }
}

class _HexSwatch extends StatelessWidget {
  const _HexSwatch();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 14,
    child: CustomPaint(painter: _HexPainter()),
  );
}

class _HexPainter extends CustomPainter {
  // The ends of GBIF's purpleYellow ramp: few records to many.
  static const _colors = [Color(0xFF5B0E6E), Color(0xFFFFE100)];

  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.height / 2;
    for (final (index, color) in _colors.indexed) {
      final Offset center = Offset(r + index * (size.width - 2 * r), r);
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final double angle = math.pi / 3 * i + math.pi / 6;
        final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
        i == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path..close(), Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LineSwatch extends StatelessWidget {
  const _LineSwatch({
    required this.color,
    required this.halo,
    this.dashed = false,
  });

  final Color color;
  final Color halo;
  final bool dashed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 14,
    child: CustomPaint(painter: _LinePainter(color, halo, dashed)),
  );
}

class _LinePainter extends CustomPainter {
  const _LinePainter(this.color, this.halo, this.dashed);

  final Color color;
  final Color halo;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height / 2;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = halo
        ..strokeWidth = DistributionOverlayColors.haloWidth,
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = DistributionOverlayColors.lineWidth;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    const double width = DistributionOverlayColors.lineWidth;
    final double on = DistributionOverlayColors.dash[0] * width;
    final double off = DistributionOverlayColors.dash[1] * width;
    for (double x = 0; x < size.width; x += on + off) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + on, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.color != color || old.halo != halo || old.dashed != dashed;
}
