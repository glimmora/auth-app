import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Add Account'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
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
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.image, size: 40),
                    title: const Text('Import from Image'),
                    subtitle: const Text('Select an image with QR code'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _isProcessing ? null : _importFromImage,
                  ),
                ),
                const SizedBox(height: 16),
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
                Text(
                  'You can add accounts from any service that supports TOTP or HOTP, including Google, GitHub, Microsoft, and more.',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (_isProcessing)
          const Stack(
            children: [
              ModalBarrier(dismissible: false, color: Colors.black26),
              Center(child: CircularProgressIndicator()),
            ],
          ),
      ],
    );
  }

  Future<void> _importFromImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null || !mounted) return;

      setState(() {
        _isProcessing = true;
      });

      final controller = MobileScannerController();
      try {
        final barcodeCapture = await controller.analyzeImage(image.path);

        if (!mounted) return;

        if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
          final barcode = barcodeCapture.barcodes.first;
          final rawValue = barcode.rawValue;
          if (rawValue != null && rawValue.startsWith('otpauth://')) {
            if (mounted) {
              context.pop(rawValue);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No valid otpauth:// QR code found in image'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No QR code detected in image'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
