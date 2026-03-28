import 'package:flutter/foundation.dart';

/// Time Offset Service
/// 
/// Manages custom time offset for TOTP/HOTP synchronization
/// Range: -300 to +300 seconds (±5 minutes)
class TimeOffsetService {
  static const _key = 'time_offset_seconds';
  static const _maxOffset = 300;
  static const _minOffset = -300;

  final ValueNotifier<int> _offsetNotifier = ValueNotifier<int>(0);

  /// Current offset in seconds
  int get currentOffset => _offsetNotifier.value;

  /// Stream of offset changes
  ValueListenable<int> get offsetNotifier => _offsetNotifier;

  /// Returns the currently configured offset in seconds
  Future<int> getOffset() async {
    // Will be implemented with secure storage
    return _offsetNotifier.value;
  }

  /// Sets the time offset
  /// 
  /// [seconds] must be between -300 and +300
  Future<void> setOffset(int seconds) async {
    if (seconds < _minOffset || seconds > _maxOffset) {
      throw ArgumentError('Offset must be between $_minOffset and $_maxOffset seconds');
    }
    _offsetNotifier.value = seconds;
    // Will persist to secure storage
  }

  /// Resets offset to zero (auto mode)
  Future<void> resetToAuto() async {
    await setOffset(0);
  }

  /// Checks difference between device time and NTP time
  /// 
  /// Returns suggested offset based on NTP pool measurement
  Future<int> measureNTPDrift() async {
    try {
      // Query NTP pool and calculate delta
      // This is a simplified version - full implementation would use NTP protocol
      final deviceTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // In production, query pool.ntp.org via NTP protocol
      // For now, return 0 (no adjustment)
      final ntpTime = deviceTime; // Placeholder
      
      return ntpTime - deviceTime;
    } catch (e) {
      debugPrint('Error measuring NTP drift: $e');
      return 0;
    }
  }

  /// Applies suggested offset with one tap
  Future<void> applySuggestedOffset(int suggestedOffset) async {
    await setOffset(suggestedOffset);
  }

  /// Validates offset is within acceptable range
  bool isValidOffset(int seconds) {
    return seconds >= _minOffset && seconds <= _maxOffset;
  }

  /// Formats offset for display (e.g., "+15s", "-30s", "0s")
  String formatOffset(int seconds) {
    if (seconds == 0) return '0s';
    return seconds > 0 ? '+${seconds}s' : '${seconds}s';
  }

  /// Disposes resources
  void dispose() {
    _offsetNotifier.dispose();
  }
}
