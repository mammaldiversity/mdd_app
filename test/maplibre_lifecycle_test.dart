import 'package:flutter_test/flutter_test.dart';
import 'package:mdd/screens/shared/maps/maplibre_camera_readiness.dart';
import 'package:mdd/screens/shared/maps/maplibre_load_watchdog.dart';

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

  test('watchdog reports a map that never draws', () async {
    var timedOut = false;
    final watchdog = MapLibreLoadWatchdog(
      onTimeout: () => timedOut = true,
      enabled: true,
      timeout: const Duration(milliseconds: 10),
    )..start();
    addTearDown(watchdog.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(timedOut, isTrue);
    expect(watchdog.isWaiting, isFalse);
  });

  test('watchdog stops after the map draws', () async {
    var timedOut = false;
    final watchdog = MapLibreLoadWatchdog(
      onTimeout: () => timedOut = true,
      enabled: true,
      timeout: const Duration(milliseconds: 10),
    )..start();
    addTearDown(watchdog.dispose);

    expect(watchdog.markReady(), isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(timedOut, isFalse);
  });
}
