import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Add account screen - choose method
class AddAccountScreen extends StatelessWidget {
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            
            // Scan QR option
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_scanner, size: 40),
                title: const Text('Scan QR Code'),
                subtitle: const Text('Use camera to scan a QR code'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/account/add/scan'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Image import option
            Card(
              child: ListTile(
                leading: const Icon(Icons.image, size: 40),
                title: const Text('Import from Image'),
                subtitle: const Text('Select an image with QR code'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open image picker
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Manual entry option
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit, size: 40),
                title: const Text('Manual Entry'),
                subtitle: const Text('Enter details manually'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/account/add/manual'),
              ),
            ),
            
            const Spacer(),
            
            // Help text
            Text(
              'You can add accounts from any service that supports TOTP or HOTP, including Google, GitHub, Microsoft, and more.',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
