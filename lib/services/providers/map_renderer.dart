import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapRenderer { mapLibre, naturalEarth }

bool get mapLibreIsExpected => !Platform.isLinux;

bool get mapLibreRunsInWebView => Platform.isMacOS || Platform.isWindows;

const mapLibreLoadTimeout = Duration(seconds: 8);

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
