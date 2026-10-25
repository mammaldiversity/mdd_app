import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/shared/maps/maplibre_camera_readiness.dart';

void main() {
  test('camera becomes ready regardless of callback order', () {
    final mapFirst = MapLibreCameraReadiness()
      ..markMapCreated()
      ..markStyleLoaded();
    final styleFirst = MapLibreCameraReadiness()
      ..markStyleLoaded()
      ..markMapCreated();

    expect(mapFirst.claimInitialCamera(), isTrue);
    expect(styleFirst.claimInitialCamera(), isTrue);
    expect(mapFirst.claimInitialCamera(), isFalse);
  });

  test('camera keeps reset requests made before readiness', () {
    final readiness = MapLibreCameraReadiness()..markMapCreated();

    expect(readiness.requestReset(), isFalse);
    readiness.markStyleLoaded();
    expect(readiness.claimInitialCamera(), isTrue);
    expect(readiness.takePendingReset(), isTrue);
  });
}
