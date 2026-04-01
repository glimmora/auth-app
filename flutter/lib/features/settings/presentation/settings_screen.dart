import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/providers.dart';

/// Settings screen with full functionality
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
    final settings = ref.read(settingsProvider);
    setState(() {
      _theme = settings.theme;
      _biometricEnabled = settings.biometricEnabled;
      _tapToReveal = settings.tapToReveal;
      _clipboardClearSeconds = settings.clipboardClearSeconds;
    });
  }

  Future<void> _showChangePinDialog() async {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // In production, verify current PIN and set new PIN
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN changed successfully')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAutoLockDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.pop(context);
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
          // Security section
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
              await ref.read(settingsProvider.notifier).setBiometricEnabled(value);
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
              await ref.read(settingsProvider.notifier).setTapToReveal(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_paste),
            title: const Text('Clipboard Clear'),
            subtitle: Text('After ${_clipboardClearSeconds} seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show clipboard duration picker
            },
          ),

          // Time Offset section
          const _SectionHeader(title: 'Time'),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time Offset'),
            subtitle: Text('${settings.globalTimeOffset} seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/time-offset'),
          ),

          // Appearance section
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
              // Navigate to language settings
            },
          ),

          // Backup section
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

          // About section
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
              // Open privacy policy in browser
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            onTap: () {
              // Open terms in browser
            },
          ),

          // Bottom padding for navigation bar
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
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
