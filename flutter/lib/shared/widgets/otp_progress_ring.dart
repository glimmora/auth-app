import 'package:flutter/material.dart';

/// Animated circular progress ring for OTP countdown
class OTPProgressRing extends StatelessWidget {
  final double progress;
  final int remainingSeconds;
  final double size;
  final double strokeWidth;

  const OTPProgressRing({
    super.key,
    required this.progress,
    required this.remainingSeconds,
    this.size = 48,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: Colors.grey[700],
              backgroundColor: Colors.transparent,
            ),
          ),

          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: Transform.rotate(
              angle: -0.5 * 3.14159, // Start from top
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                color: _getColor(progress),
                backgroundColor: Colors.transparent,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),

          // Time remaining text
          Text(
            '$remainingSeconds',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getColor(progress),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(double progress) {
    if (progress > 0.5) {
      return Colors.green[400]!;
    } else if (progress > 0.2) {
      return Colors.orange[400]!;
    } else {
      return Colors.red[400]!;
    }
  }
}

// Alias for consistency
typedef OtpProgressRing = OTPProgressRing;
