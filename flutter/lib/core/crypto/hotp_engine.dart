import 'dart:typed_data';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'otp_algorithm.dart';

/// HOTP Algorithm as per RFC 4226
/// Counter-based OTP (used for hardware tokens and some services)
class HOTPEngine {
  /// Generates a HOTP code per RFC 4226.
  ///
  /// [secret]    Base32-encoded shared secret
  /// [counter]   Counter value (incremented after each use)
  /// [digits]    Code length: 6, 7, or 8
  /// [algorithm] HmacSHA1 | HmacSHA256 | HmacSHA512
  static String generate({
    required String secret,
    required int counter,
    int digits = 6,
    OTPAlgorithm algorithm = OTPAlgorithm.SHA1,
  }) {
    return _computeHOTP(
      secret: secret,
      counter: counter,
      digits: digits,
      algorithm: algorithm,
    );
  }

  static String _computeHOTP({
    required String secret,
    required int counter,
    int digits = 6,
    OTPAlgorithm algorithm = OTPAlgorithm.SHA1,
  }) {
    // Decode base32 secret
    final key = _base32Decode(secret.toUpperCase().replaceAll(' ', ''));

    // Create counter bytes (big-endian 8 bytes)
    final counterBytes = Uint8List(8);
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = counter & 0xFF;
      counter = counter >> 8;
    }

    // Select hash algorithm
    final hmac = _getHmac(algorithm, key);

    // Compute HMAC
    final hash = hmac.process(counterBytes);

    // Dynamic truncation (RFC 4226)
    final offset = hash[hash.length - 1] & 0x0F;
    var binaryCode = 0;
    for (var i = 0; i < 4; i++) {
      binaryCode = (binaryCode << 8) | (hash[offset + i] & 0xFF);
    }
    binaryCode &= 0x7FFFFFFF;

    // Generate OTP
    final otp = binaryCode % _pow10(digits);

    // Pad with leading zeros
    return otp.toString().padLeft(digits, '0');
  }

  static HMac _getHmac(OTPAlgorithm algorithm, Uint8List key) {
    switch (algorithm) {
      case OTPAlgorithm.SHA1:
        return HMac.withDigest(SHA1Digest());
      case OTPAlgorithm.SHA256:
        return HMac.withDigest(SHA256Digest());
      case OTPAlgorithm.SHA512:
        return HMac.withDigest(SHA512Digest());
    }
  }

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  static Uint8List _base32Decode(String input) {
    input = input.replaceAll('=', '').replaceAll(' ', '');

    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final buffer = <int>[];

    var bufferValue = 0;
    var bufferLength = 0;

    for (final char in input.split('')) {
      final index = alphabet.indexOf(char);
      if (index == -1) continue;

      bufferValue = (bufferValue << 5) | index;
      bufferLength += 5;

      if (bufferLength >= 8) {
        bufferLength -= 8;
        buffer.add((bufferValue >> bufferLength) & 0xFF);
      }
    }

    return Uint8List.fromList(buffer);
  }
}

extension HOTPAlgorithmExtension on OTPAlgorithm {
  String get name {
    switch (this) {
      case OTPAlgorithm.SHA1:
        return 'SHA1';
      case OTPAlgorithm.SHA256:
        return 'SHA256';
      case OTPAlgorithm.SHA512:
        return 'SHA512';
    }
  }

  static OTPAlgorithm fromName(String name) {
    switch (name.toUpperCase()) {
      case 'SHA1':
      case 'HMACSHA1':
        return OTPAlgorithm.SHA1;
      case 'SHA256':
      case 'HMACSHA256':
        return OTPAlgorithm.SHA256;
      case 'SHA512':
      case 'HMACSHA512':
        return OTPAlgorithm.SHA512;
      default:
        return OTPAlgorithm.SHA1;
    }
  }
}
