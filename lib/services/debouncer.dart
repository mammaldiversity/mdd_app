import 'dart:async';

import 'package:flutter/foundation.dart';

/// Runs only the last action given within [delay], so fast typing triggers
/// one update instead of one per keystroke.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() => _timer?.cancel();
}
