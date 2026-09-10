class MapLibreCameraReadiness {
  bool _mapCreated = false;
  bool _styleLoaded = false;
  bool _initialCameraPending = true;
  bool _resetPending = false;

  bool get isReady => _mapCreated && _styleLoaded;

  void markMapCreated() => _mapCreated = true;

  void markStyleLoaded() => _styleLoaded = true;

  bool claimInitialCamera() {
    if (!isReady || !_initialCameraPending) return false;
    _initialCameraPending = false;
    return true;
  }

  bool requestReset() {
    if (!isReady) {
      _resetPending = true;
      return false;
    }
    return true;
  }

  bool takePendingReset() {
    if (!_resetPending) return false;
    _resetPending = false;
    return true;
  }
}
