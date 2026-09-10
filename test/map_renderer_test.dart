import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/services/providers/map_renderer.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('starts on the renderer supported by the platform', () {
    expect(
      container.read(mapRendererProvider),
      mapLibreIsExpected ? MapRenderer.mapLibre : MapRenderer.naturalEarth,
    );
  });

  test('latches fallback and retries only where MapLibre exists', () {
    final notifier = container.read(mapRendererProvider.notifier);
    notifier.markMapLibreUnavailable();
    expect(container.read(mapRendererProvider), MapRenderer.naturalEarth);

    notifier.retryMapLibre();
    expect(
      container.read(mapRendererProvider),
      mapLibreIsExpected ? MapRenderer.mapLibre : MapRenderer.naturalEarth,
    );
  });
}
