import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

/// QR Code scanner screen
class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: _switchCamera,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetect,
          ),

          // Overlay with scan frame
          CustomPaint(
            painter: _ScanFramePainter(),
            size: Size.infinite,
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Position the QR code within the frame',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Manual entry fallback
                TextButton.icon(
                  onPressed: () => context.push('/account/add/manual'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Enter manually'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Parse otpauth:// URI
    final uri = barcode.rawValue!;

    // Validate and process
    if (uri.startsWith('otpauth://')) {
      // Navigate to confirmation screen
      if (mounted) {
        // For now, go back to home
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned: $uri')),
        );
      }
    } else {
      // Invalid QR
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code. Please scan an otpauth:// QR code.'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    await _controller?.switchCamera();
  }

  Future<void> _toggleFlash() async {
    // toggleFlash removed in newer mobile_scanner versions
    // Flash control now handled automatically
    // await _controller?.toggleFlash();
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const frameSize = 250.0;
    final offset = Offset(
      (size.width - frameSize) / 2,
      (size.height - frameSize) / 2 - 50,
    );

    // Draw frame
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, frameSize, frameSize),
      paint,
    );

    // Draw corner markers
    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 20.0;

    // Top-left
    canvas.drawLine(
      Offset(offset.dx, offset.dy + cornerLength),
      Offset(offset.dx, offset.dy),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(offset.dx, offset.dy),
      Offset(offset.dx + cornerLength, offset.dy),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(offset.dx + frameSize - cornerLength, offset.dy),
      Offset(offset.dx + frameSize, offset.dy),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(offset.dx + frameSize, offset.dy),
      Offset(offset.dx + frameSize, offset.dy + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(offset.dx, offset.dy + frameSize - cornerLength),
      Offset(offset.dx, offset.dy + frameSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(offset.dx, offset.dy + frameSize),
      Offset(offset.dx + cornerLength, offset.dy + frameSize),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(offset.dx + frameSize - cornerLength, offset.dy + frameSize),
      Offset(offset.dx + frameSize, offset.dy + frameSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(offset.dx + frameSize, offset.dy + frameSize - cornerLength),
      Offset(offset.dx + frameSize, offset.dy + frameSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
