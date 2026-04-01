import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/providers/providers.dart';

/// Lock screen - PIN and biometric authentication
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController(text: '');
  final _focusNode = FocusNode();
  bool _showError = false;
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  int _lockoutSeconds = 0;
  bool _isAuthenticating = false;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _hasBiometrics = false;
  bool _hasBiometricsEnrolled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _focusNode.requestFocus();
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (_canCheckBiometrics) {
        _hasBiometrics = await _localAuth.isDeviceSupported();
        _hasBiometricsEnrolled = await _localAuth.canCheckBiometrics;
      }
    } catch (e) {
      _canCheckBiometrics = false;
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock AuthVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate && mounted) {
        await _unlock();
      } else if (mounted) {
        setState(() {
          _showError = true;
          _errorMessage = 'Authentication cancelled';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showError = true;
          _errorMessage = 'Biometric error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  String _errorMessage = '';

  void _handlePinSubmit() async {
    final pin = _pinController.text;

    if (pin.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _showError = false;
    });

    try {
      final settings = ref.read(settingsProvider);
      if (settings.pinHash == null || settings.pinSalt == null) {
        throw Exception('PIN not set');
      }
      final hash = _hashPin(pin, settings.pinSalt!);
      
      if (hash == settings.pinHash) {
        await _unlock();
      } else {
        throw Exception('Invalid PIN');
      }
    } catch (e) {
      _failedAttempts++;
      _pinController.clear();

      if (_failedAttempts >= 5) {
        _isLockedOut = true;
        _lockoutSeconds = 30 * (1 << (_failedAttempts - 5));
        _startLockoutTimer();
      }

      setState(() {
        _isAuthenticating = false;
        _showError = true;
        _errorMessage = 'Incorrect PIN. $_failedAttempts attempts.';
      });
    }
  }

  Future<void> _unlock() async {
    // Log audit event
    final db = ref.read(databaseProvider);
    await db.logAction('UNLOCK', details: 'PIN authentication successful');

    // Reset failed attempts
    _failedAttempts = 0;

    // Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  void _startLockoutTimer() {
    Future.delayed(Duration(seconds: _lockoutSeconds), () {
      if (mounted) {
        setState(() {
          _isLockedOut = false;
          _lockoutSeconds = 0;
        });
      }
    });
  }

  String _hashPin(String pin, Uint8List salt) {
    final saltedPin = Uint8List.fromList(
      [...salt, ...utf8.encode(pin)],
    );
    return sha256.convert(saltedPin).toString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final biometricEnabled = settings.biometricEnabled && _hasBiometricsEnrolled;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.white,
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'AuthVault',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your PIN to unlock',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 48),

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

              // Lockout message
              if (_isLockedOut)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Too many attempts. Try again in $_lockoutSeconds seconds.',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // PIN input
              if (!_isLockedOut)
                TextField(
                  controller: _pinController,
                  focusNode: _focusNode,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '• • • •',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  maxLength: 6,
                  onSubmitted: (_) => _handlePinSubmit(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),

              const SizedBox(height: 24),

              // Submit button
              if (!_isLockedOut)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAuthenticating ? null : _handlePinSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAuthenticating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Unlock',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

              const SizedBox(height: 16),

              // Biometric button
              if (biometricEnabled && !_isLockedOut && !_isAuthenticating)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: const Text('Use Biometrics'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // Forgot PIN
              TextButton(
                onPressed: () {
                  _showResetDialog();
                },
                child: Text(
                  'Forgot PIN?',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),

              // Bottom padding for navigation bar
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'If you forgot your PIN, you\'ll need to reset the app. This will delete all accounts. Make sure you have a backup!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset app
              Navigator.pop(context);
              // Clear all data and redirect to setup
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
