import 'dart:async';
import 'package:flutter/foundation.dart';

/// Time Service
///
/// Provides accurate time for TOTP/HOTP generation
/// with optional NTP synchronization
class TimeService {
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;
  TimeService._internal();

  final ValueNotifier<DateTime> _currentTime =
      ValueNotifier<DateTime>(DateTime.now());
  final StreamController<DateTime> _streamController =
      StreamController<DateTime>.broadcast();
  Timer? _timer;

  /// Current time
  DateTime get now => _currentTime.value;

  /// Current Unix timestamp in seconds
  int get timestamp => now.millisecondsSinceEpoch ~/ 1000;

  /// Starts the time update timer
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
<<<<<<< HEAD
      final newTime = DateTime.now();
      _currentTime.value = newTime;
      if (!_streamController.isClosed) {
        _streamController.add(newTime);
=======
      final now = DateTime.now();
      _currentTime.value = now;
      if (!_streamController.isClosed) {
        _streamController.add(now);
>>>>>>> babb3b59814fd1012c5cb601c2dd89a61feb6d50
      }
    });
  }

  /// Stops the time update timer
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Returns seconds until next period
  int secondsUntilNextPeriod(int period, {int offset = 0}) {
    final adjustedTime = timestamp + offset;
    return period - (adjustedTime % period);
  }

  /// Returns progress (0.0 to 1.0) through current period
  double periodProgress(int period, {int offset = 0}) {
    final adjustedTime = timestamp + offset;
    return (adjustedTime % period) / period;
  }

  final StreamController<DateTime> _streamController =
      StreamController<DateTime>.broadcast();

  /// Stream of time updates (emits every second)
<<<<<<< HEAD
  Stream<DateTime> get timeStream {
    return _streamController.stream;
  }
=======
  Stream<DateTime> get timeStream => _streamController.stream;
>>>>>>> babb3b59814fd1012c5cb601c2dd89a61feb6d50

  /// Disposes resources
  void dispose() {
    stop();
    _streamController.close();
    _currentTime.dispose();
  }
}

