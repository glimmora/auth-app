import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Security section
          const _SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Unlock'),
            subtitle: const Text('Use fingerprint or face to unlock'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change PIN'),
            onTap: () {
              // Navigate to change PIN
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Auto-Lock'),
            subtitle: const Text('After 30 seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to auto-lock settings
            },
          ),
          
          // Time Offset section
          const _SectionHeader(title: 'Time'),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Time Offset'),
            subtitle: const Text('Adjust for clock drift'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/time-offset'),
          ),
          
          // Appearance section
          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Dark'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to theme settings
            },
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
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to restore
            },
          ),
          
          // Import/Export section
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to import
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Export'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to export
            },
          ),
          
          // About section
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About AuthVault'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              // Show about dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Open privacy policy
            },
          ),
        ],
      ),
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
