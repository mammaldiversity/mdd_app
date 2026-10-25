import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/distribution_map_style.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

/// OpenFreeMap styles parsed for `vector_map_tiles`, keyed by dark mode.
///
/// Desktop has no native MapLibre, so `flutter_map` draws the basemap from
/// the same OpenFreeMap styles MapLibre reads on mobile.
final vectorBasemapStyleProvider = FutureProvider.family<Style, bool>(
  (ref, isDark) => loadVectorBasemapStyle(isDark: isDark),
);

const _loadTimeout = Duration(seconds: 8);

Future<Style> loadVectorBasemapStyle({required bool isDark}) async {
  final loaded = await StyleReader(
    uri: DistributionMapStyleService.styleUrl(isDark: isDark),
  ).read().timeout(_loadTimeout);
  // OpenFreeMap styles carry no `id`, and `vector_map_tiles` keys its tile
  // caches by theme id, so both styles would otherwise share one cache.
  return Style(
    name: loaded.name,
    theme: loaded.theme.copyWith(
      id: 'openfreemap-${isDark ? 'dark' : 'positron'}',
    ),
    providers: loaded.providers,
    sprites: loaded.sprites,
    center: loaded.center,
    zoom: loaded.zoom,
  );
}
