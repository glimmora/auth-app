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
  Timer? _timer;

  /// Current time
  DateTime get now => _currentTime.value;

  /// Current Unix timestamp in seconds
  int get timestamp => now.millisecondsSinceEpoch ~/ 1000;

  /// Starts the time update timer
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime.value = DateTime.now();
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

  /// Stream of time updates (emits every second)
  Stream<DateTime> get timeStream {
    return _currentTime.stream;
  }

  /// Disposes resources
  void dispose() {
    stop();
    _currentTime.dispose();
  }
}
