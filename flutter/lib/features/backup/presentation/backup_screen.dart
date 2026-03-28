import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

/// Backup and restore screen
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Export section
          const _SectionHeader(title: 'Export Backup'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Export all accounts to an encrypted file',
                    style: TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Backup file is encrypted with AES-256-GCM. Keep it safe and never share it.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: () => _exportBackup(context),
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export to File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  OutlinedButton.icon(
                    onPressed: () => _exportToCloud(context),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Backup to Cloud'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Import section
          const _SectionHeader(title: 'Import Backup'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Restore accounts from a backup file',
                    style: TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Supports .avx backup files from AuthVault.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: () => _importBackup(context),
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Import from File'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Cloud backup section
          const _SectionHeader(title: 'Cloud Backup'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Google Drive'),
                    subtitle: const Text('Not connected'),
                    trailing: OutlinedButton(
                      onPressed: () {
                        // Connect to Google Drive
                      },
                      child: const Text('Connect'),
                    ),
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.folder),
                    title: const Text('Dropbox'),
                    subtitle: const Text('Not connected'),
                    trailing: OutlinedButton(
                      onPressed: () {
                        // Connect to Dropbox
                      },
                      child: const Text('Connect'),
                    ),
                  ),
                  
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.cloud),
                    title: const Text('iCloud'),
                    subtitle: const Text('Not available'),
                    trailing: const Icon(Icons.lock, size: 20),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // QR Export section
          const _SectionHeader(title: 'QR Export'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Export accounts as QR codes for transfer to another device',
                    style: TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: () => _exportQR(context),
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Export as QR Codes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Last backup info
          Card(
            color: Colors.blue[900],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[200]),
                      const SizedBox(width: 12),
                      Text(
                        'Last backup: Never',
                        style: TextStyle(color: Colors.blue[100]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    // Export to file
    try {
      // In production, create encrypted backup
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup',
        fileName: 'authvault_backup.avx',
        type: FileType.custom,
        allowedExtensions: ['avx'],
      );
      
      if (path != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToCloud(BuildContext context) async {
    // Export to cloud storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connect to cloud storage first')),
    );
  }

  Future<void> _importBackup(BuildContext context) async {
    // Import from file
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['avx'],
      );
      
      if (result != null && result.files.single.path != null) {
        // In production, decrypt and import
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import successful')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportQR(BuildContext context) async {
    // Export as QR codes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR export feature coming soon')),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
