import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapRenderer { mapLibre, naturalEarth }

/// Native MapLibre exists only on Android and iOS. Desktop draws with
/// `flutter_map`, which keeps a web view and its CDN-hosted MapLibre GL JS
/// bundle out of the app.
bool get mapLibreIsExpected => Platform.isAndroid || Platform.isIOS;

final mapRendererProvider = NotifierProvider<MapRendererNotifier, MapRenderer>(
  MapRendererNotifier.new,
);

class MapRendererNotifier extends Notifier<MapRenderer> {
  @override
  MapRenderer build() =>
      mapLibreIsExpected ? MapRenderer.mapLibre : MapRenderer.naturalEarth;

  void markMapLibreUnavailable() {
    if (state == MapRenderer.naturalEarth) return;
    state = MapRenderer.naturalEarth;
  }

  void retryMapLibre() {
    if (!mapLibreIsExpected || state == MapRenderer.mapLibre) return;
    state = MapRenderer.mapLibre;
  }
}
