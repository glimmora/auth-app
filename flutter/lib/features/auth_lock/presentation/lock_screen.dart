import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

/// Lock screen - PIN and biometric authentication
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _pinController = TextEditingController(text: '');
  final _focusNode = FocusNode();
  bool _showError = false;
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  int _lockoutSeconds = 0;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _hasBiometrics = false;

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
      }
    } catch (e) {
      _canCheckBiometrics = false;
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock AuthVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate && mounted) {
        _handleSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showError = true;
        setState(() {});
      }
    }
  }

  void _handlePinSubmit() {
    final pin = _pinController.text;

    // In production, verify against stored hash
    if (pin == '1234') {
      // Placeholder
      _handleSuccess();
    } else {
      _failedAttempts++;
      _showError = true;
      _pinController.clear();

      if (_failedAttempts >= 5) {
        _isLockedOut = true;
        _lockoutSeconds =
            30 * (1 << (_failedAttempts - 5)); // Exponential backoff
        _startLockoutTimer();
      }

      setState(() {});
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

  void _handleSuccess() {
    // Log audit event
    // Reset failed attempts
    // Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Incorrect PIN. $_failedAttempts attempts.',
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
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
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
                    onPressed: _handlePinSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Unlock',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Biometric button
              if (_hasBiometrics && !_isLockedOut)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
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
                  // Show reset dialog
                },
                child: Text(
                  'Forgot PIN?',
                  style: TextStyle(color: Colors.grey[500]),
                ),
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
    _focusNode.dispose();
    super.dispose();
  }
}
