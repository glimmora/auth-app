import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _theme = 'system';
  bool _biometricEnabled = true;
  bool _tapToReveal = false;
  int _clipboardClearSeconds = 30;
  int _autoLockSeconds = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final settings = ref.read(settingsProvider);
      if (mounted) {
        setState(() {
          _theme = settings.theme;
          _biometricEnabled = settings.biometricEnabled;
          _tapToReveal = settings.tapToReveal;
          _clipboardClearSeconds = settings.clipboardClearSeconds;
        });
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  Future<void> _showChangePinDialog() async {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          String? error;
          bool isChanging = false;

          Future<void> handleChange() async {
            final currentPin = currentPinController.text;
            final newPin = newPinController.text;
            final confirmPin = confirmPinController.text;

            if (currentPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
              setDialogState(() {
                error = 'All fields are required';
              });
              return;
            }

            if (newPin.length < 4) {
              setDialogState(() {
                error = 'PIN must be at least 4 digits';
              });
              return;
            }

            if (newPin != confirmPin) {
              setDialogState(() {
                error = 'New PINs do not match';
              });
              return;
            }

            setDialogState(() {
              isChanging = true;
              error = null;
            });

            try {
              final settings = ref.read(settingsProvider);
              if (settings.pinHash != null && settings.pinSalt != null) {
                final verified = await ref.read(settingsProvider.notifier).verifyPin(currentPin);
                if (!verified) {
                  setDialogState(() {
                    isChanging = false;
                    error = 'Current PIN is incorrect';
                  });
                  return;
                }
              }
              await ref.read(settingsProvider.notifier).setPin(newPin);
              if (mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN changed successfully')),
                );
              }
            } catch (e) {
              setDialogState(() {
                isChanging = false;
                error = 'Failed to change PIN: $e';
              });
            }
          }

          return AlertDialog(
            title: const Text('Change PIN'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      labelText: 'Current PIN',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      labelText: 'New PIN',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      labelText: 'Confirm New PIN',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isChanging ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isChanging ? null : handleChange,
                child: isChanging
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Change'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAutoLockDialog() async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Auto-Lock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose when to auto-lock:'),
            const SizedBox(height: 16),
            ...[15, 30, 60, 120, 300].map((seconds) => ListTile(
              title: Text(_formatDuration(seconds)),
              onTap: () {
                setState(() {
                  _autoLockSeconds = seconds;
                });
                Navigator.pop(dialogContext);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds seconds';
    if (seconds < 3600) return '${seconds ~/ 60} minutes';
    return '${seconds ~/ 3600} hours';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Security'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Unlock'),
            subtitle: const Text('Use fingerprint or face to unlock'),
            value: _biometricEnabled,
            onChanged: (value) async {
              setState(() {
                _biometricEnabled = value;
              });
              try {
                await ref.read(settingsProvider.notifier).setBiometricEnabled(value);
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _biometricEnabled = !value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change PIN'),
            subtitle: const Text('Update your unlock PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePinDialog,
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Auto-Lock'),
            subtitle: Text(_formatDuration(_autoLockSeconds)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAutoLockDialog,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: const Text('Tap to Reveal'),
            subtitle: const Text('Tap code to show/hide'),
            value: _tapToReveal,
            onChanged: (value) async {
              setState(() {
                _tapToReveal = value;
              });
              try {
                await ref.read(settingsProvider.notifier).setTapToReveal(value);
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _tapToReveal = !value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_paste),
            title: const Text('Clipboard Clear'),
            subtitle: Text('After ${_clipboardClearSeconds} seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClipboardDurationDialog(),
          ),

          const _SectionHeader(title: 'Time'),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time Offset'),
            subtitle: Text('${settings.globalTimeOffset} seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/time-offset'),
          ),

          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(_theme == 'system'
                ? 'System default'
                : _theme == 'light'
                    ? 'Light'
                    : 'Dark'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon')),
              );
            },
          ),

          const _SectionHeader(title: 'Backup & Sync'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup'),
            subtitle: const Text('Last backup: Never'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore'),
            subtitle: const Text('Import from backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/backup'),
          ),

          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About AuthVault'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon')),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showClipboardDurationDialog() async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Clipboard After'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [10, 30, 60, 120].map((seconds) => ListTile(
            title: Text(_formatDuration(seconds)),
            selected: _clipboardClearSeconds == seconds,
            onTap: () {
              setState(() {
                _clipboardClearSeconds = seconds;
              });
              Navigator.pop(dialogContext);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.system_update),
              title: const Text('System default'),
              selected: _theme == 'system',
              onTap: () {
                setState(() {
                  _theme = 'system';
                });
                ref.read(settingsProvider.notifier).setTheme('system');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              selected: _theme == 'light',
              onTap: () {
                setState(() {
                  _theme = 'light';
                });
                ref.read(settingsProvider.notifier).setTheme('light');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              selected: _theme == 'dark',
              onTap: () {
                setState(() {
                  _theme = 'dark';
                });
                ref.read(settingsProvider.notifier).setTheme('dark');
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    if (!mounted) return;
    showAboutDialog(
      context: context,
      applicationName: 'AuthVault',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.security, size: 48),
      children: [
        const Text('Secure two-factor authenticator app with TOTP/HOTP support.'),
        const SizedBox(height: 16),
        const Text('© 2025-2026 AuthVault Team'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.blue[400],
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
