import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
      setState(() {
        _hasCameraPermission = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera not available: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/account/add/manual'),
                icon: const Icon(Icons.edit),
                label: const Text('Enter Manually'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: _controller != null ? _switchCamera : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasCameraPermission)
            MobileScanner(
              controller: _controller,
              onDetect: _handleDetect,
            )
          else
            const Center(child: CircularProgressIndicator()),
          CustomPaint(
            painter: _ScanFramePainter(),
            size: Size.infinite,
          ),
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
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isProcessing || !mounted) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (rawValue.startsWith('otpauth://')) {
        if (mounted) {
          context.pop(rawValue);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid QR code. Please scan an otpauth:// QR code.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing QR code: $e'),
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

  Future<void> _switchCamera() async {
    try {
      await _controller?.switchCamera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, frameSize, frameSize),
      paint,
    );

    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 20.0;

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
