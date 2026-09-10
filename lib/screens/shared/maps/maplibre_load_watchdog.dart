import 'dart:async';

import 'package:mdd/services/providers/map_renderer.dart';

class MapLibreLoadWatchdog {
  MapLibreLoadWatchdog({
    required this.onTimeout,
    bool? enabled,
    this.timeout = mapLibreLoadTimeout,
  }) : enabled = enabled ?? mapLibreRunsInWebView;

  final void Function() onTimeout;
  final bool enabled;
  final Duration timeout;

  Timer? _timer;
  bool _isWaiting = false;

  bool get isWaiting => _isWaiting;

  void start() {
    if (!enabled || _timer != null || _isWaiting) return;
    _isWaiting = true;
    _timer = Timer(timeout, () {
      _timer = null;
      if (!_isWaiting) return;
      _isWaiting = false;
      onTimeout();
    });
  }

  bool markReady() {
    _timer?.cancel();
    _timer = null;
    if (!_isWaiting) return false;
    _isWaiting = false;
    return true;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isWaiting = false;
  }
}
