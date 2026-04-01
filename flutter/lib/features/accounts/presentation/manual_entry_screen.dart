import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/providers.dart';
import '../domain/account.dart';

/// Manual entry screen for adding accounts
class ManualEntryScreen extends ConsumerStatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ConsumerState<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends ConsumerState<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _labelController = TextEditingController();
  final _secretController = TextEditingController();

  String _accountType = 'totp';
  String _algorithm = 'SHA1';
  int _digits = 6;
  int _period = 30;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _issuerController.dispose();
    _labelController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final accountType = AccountTypeExtension.fromName(_accountType);
        
        await ref.read(accountsProvider.notifier).addAccount(
          issuer: _issuerController.text.trim(),
          label: _labelController.text.trim(),
          secret: _secretController.text.trim().toUpperCase(),
          type: accountType,
          algorithm: _algorithm,
          digits: _digits,
          period: _period,
          counter: 0,
          iconName: _getIconForIssuer(_issuerController.text.trim()),
        );

        if (mounted) {
          // Log audit event
          final db = ref.read(databaseProvider);
          await db.logAction(
            'ADD_ACCOUNT',
            details: 'Added ${_issuerController.text} manually',
          );

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _generateSecret() {
    final secret = _generateRandomBase32(20);
    _secretController.text = secret;
  }

  String _generateRandomBase32(int length) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
      length,
      (i) => alphabet[(random + i) % alphabet.length],
    ).join();
  }

  String? _getIconForIssuer(String issuer) {
    final issuerLower = issuer.toLowerCase();
    if (issuerLower.contains('google')) return 'google';
    if (issuerLower.contains('github')) return 'github';
    if (issuerLower.contains('microsoft')) return 'microsoft';
    if (issuerLower.contains('amazon')) return 'amazon';
    if (issuerLower.contains('facebook')) return 'facebook';
    if (issuerLower.contains('twitter')) return 'twitter';
    if (issuerLower.contains('apple')) return 'apple';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Type
            DropdownButtonFormField<String>(
              value: _accountType,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'totp', child: Text('Time-based (TOTP)')),
                DropdownMenuItem(value: 'hotp', child: Text('Counter-based (HOTP)')),
                DropdownMenuItem(value: 'steam', child: Text('Steam Guard')),
              ],
              onChanged: (value) {
                setState(() {
                  _accountType = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Issuer
            TextFormField(
              controller: _issuerController,
              decoration: const InputDecoration(
                labelText: 'Issuer',
                hintText: 'e.g., Google, GitHub',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an issuer';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Label
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., your@email.com',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a label';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Secret
            TextFormField(
              controller: _secretController,
              decoration: InputDecoration(
                labelText: 'Secret Key',
                hintText: 'Base32-encoded secret',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.paste),
                      onPressed: () async {
                        final clipboard = await Clipboard.getData('text/plain');
                        if (clipboard?.text != null) {
                          _secretController.text = clipboard!.text!.toUpperCase();
                        }
                      },
                      tooltip: 'Paste',
                    ),
                    IconButton(
                      icon: const Icon(Icons.casino),
                      onPressed: _generateSecret,
                      tooltip: 'Generate',
                    ),
                  ],
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a secret key';
                }
                // Validate base32
                if (!RegExp(r'^[A-Z2-7]+$').hasMatch(value.toUpperCase())) {
                  return 'Invalid base32 format';
                }
                return null;
              },
            ),

            if (_accountType != 'steam') ...[
              const SizedBox(height: 16),

              // Algorithm
              DropdownButtonFormField<String>(
                value: _algorithm,
                decoration: const InputDecoration(
                  labelText: 'Algorithm',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'SHA1', child: Text('SHA1')),
                  DropdownMenuItem(value: 'SHA256', child: Text('SHA256')),
                  DropdownMenuItem(value: 'SHA512', child: Text('SHA512')),
                ],
                onChanged: (value) {
                  setState(() {
                    _algorithm = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Digits
              DropdownButtonFormField<int>(
                value: _digits,
                decoration: const InputDecoration(
                  labelText: 'Digits',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 6, child: Text('6 digits')),
                  DropdownMenuItem(value: 7, child: Text('7 digits')),
                  DropdownMenuItem(value: 8, child: Text('8 digits')),
                ],
                onChanged: (value) {
                  setState(() {
                    _digits = value!;
                  });
                },
              ),

              if (_accountType == 'totp') ...[
                const SizedBox(height: 16),

                // Period
                DropdownButtonFormField<int>(
                  value: _period,
                  decoration: const InputDecoration(
                    labelText: 'Period (seconds)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 seconds')),
                    DropdownMenuItem(value: 30, child: Text('30 seconds')),
                    DropdownMenuItem(value: 60, child: Text('60 seconds')),
                    DropdownMenuItem(value: 90, child: Text('90 seconds')),
                    DropdownMenuItem(value: 120, child: Text('120 seconds')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _period = value!;
                    });
                  },
                ),
              ],
            ],

            const SizedBox(height: 32),

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
                  : const Text('Add Account'),
            ),

            // Bottom padding for navigation bar
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
