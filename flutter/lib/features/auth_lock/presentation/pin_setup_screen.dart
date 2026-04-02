import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';

/// PIN setup screen
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController(text: '');
  final _confirmController = TextEditingController(text: '');
  bool _showError = false;
  String _errorMessage = '';
  bool _isSubmitting = false;

  void _handleSubmit() async {
    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin.length < 4) {
      setState(() {
        _showError = true;
        _errorMessage = 'PIN must be at least 4 digits';
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _showError = true;
        _errorMessage = 'PINs do not match';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showError = false;
    });

    try {
      await ref.read(settingsProvider.notifier).setPin(pin);
      ref.read(lockStateProvider.notifier).setUnlocked();
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showError = true;
          _errorMessage = 'Failed to set PIN: $e';
        });
      }
    }
  }

    if (pin != confirm) {
      setState(() {
        _showError = true;
        _errorMessage = 'PINs do not match';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showError = false;
    });

    try {
      await ref.read(settingsProvider.notifier).setPin(pin);
      ref.read(lockStateProvider.notifier).setUnlocked();
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showError = true;
          _errorMessage = 'Failed to set PIN: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.blue,
              ),

              const SizedBox(height: 24),

              const Text(
                'Create a PIN to protect your AuthVault',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'You\'ll need this PIN to unlock the app on future launches',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // PIN input
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'New PIN',
                  hintText: '• • • •',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: '4-6 digits',
                ),
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              const SizedBox(height: 16),

              // Confirm PIN
              TextField(
                controller: _confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'Confirm PIN',
                  hintText: '• • • •',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),

              // Error message
              if (_showError)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Set PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
