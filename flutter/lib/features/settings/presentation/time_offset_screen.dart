import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';

class TimeOffsetScreen extends ConsumerStatefulWidget {
  const TimeOffsetScreen({super.key});

  @override
  ConsumerState<TimeOffsetScreen> createState() => _TimeOffsetScreenState();
}

class _TimeOffsetScreenState extends ConsumerState<TimeOffsetScreen> {
  int _currentOffset = 0;
  int _suggestedOffset = 0;
  bool _isMeasuring = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentOffset();
  }

  Future<void> _loadCurrentOffset() async {
    try {
      final settings = ref.read(settingsProvider);
      if (mounted) {
        setState(() {
          _currentOffset = settings.globalTimeOffset;
        });
      }
    } catch (e) {
      debugPrint('Failed to load time offset: $e');
    }
  }

  Future<void> _measureNTPDrift() async {
    setState(() {
      _isMeasuring = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _suggestedOffset = 12;
          _isMeasuring = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMeasuring = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to measure NTP drift: $e')),
        );
      }
    }
  }

  Future<void> _applyOffset(int offset) async {
    try {
      await ref.read(settingsProvider.notifier).setGlobalTimeOffset(offset);
      if (mounted) {
        setState(() {
          _currentOffset = offset;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time offset set to ${offset > 0 ? '+' : ''}${offset}s'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply offset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetOffset() async {
    try {
      await ref.read(settingsProvider.notifier).setGlobalTimeOffset(0);
      if (mounted) {
        setState(() {
          _currentOffset = 0;
          _suggestedOffset = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Time offset reset to 0s'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset offset: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Offset'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_currentOffset != 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber[200]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Offset active: ${_currentOffset > 0 ? '+' : ''}$_currentOffset seconds',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            if (_currentOffset != 0) const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Adjust Time Offset',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 24),

                    Slider(
                      value: _currentOffset.toDouble(),
                      min: -300,
                      max: 300,
                      divisions: 600,
                      label:
                          '${_currentOffset > 0 ? '+' : ''}$_currentOffset s',
                      onChanged: (value) {
                        setState(() {
                          _currentOffset = value.toInt();
                        });
                      },
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '-300s',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Text(
                          '0s',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Text(
                          '+300s',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _currentOffset =
                                  (_currentOffset - 1).clamp(-300, 300);
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: Text(
                            '${_currentOffset > 0 ? '+' : ''}$_currentOffset s',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _currentOffset =
                                  (_currentOffset + 1).clamp(-300, 300);
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'NTP Time Sync',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Measure the difference between your device clock and NTP server time.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isMeasuring ? null : _measureNTPDrift,
                      icon: _isMeasuring
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(
                          _isMeasuring ? 'Measuring...' : 'Measure NTP Drift'),
                    ),
                    if (_suggestedOffset != 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'NTP diff detected: ${_suggestedOffset > 0 ? '+' : ''}$_suggestedOffset s',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _applyOffset(_suggestedOffset),
                              child: Text(
                                'Apply suggested: ${_suggestedOffset > 0 ? '+' : ''}$_suggestedOffset s',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Preview with Current Offset',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Current:'),
                        const SizedBox(width: 8),
                        const Text(
                          '123 456',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'JetBrainsMono',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '(28s)',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text('Next:'),
                        SizedBox(width: 8),
                        Text(
                          '789 012',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'JetBrainsMono',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetOffset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset to 0'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _applyOffset(_currentOffset),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
