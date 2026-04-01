import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// TOTP/HOTP Algorithm implementation using dart crypto package
class OtpAlgorithm {
  /// Generate TOTP code
  String generateTOTP({
    required String secret,
    String algorithm = 'SHA1',
    int digits = 6,
    int period = 30,
    int timeOffset = 0,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final adjustedTime = now + timeOffset;
    final counter = adjustedTime ~/ period;
    
    return _generateOTP(
      secret: secret,
      counter: counter,
      algorithm: algorithm,
      digits: digits,
    );
  }

  /// Generate HOTP code
  String generateHOTP({
    required String secret,
    required int counter,
    String algorithm = 'SHA1',
    int digits = 6,
  }) {
    return _generateOTP(
      secret: secret,
      counter: counter,
      algorithm: algorithm,
      digits: digits,
    );
  }

  String _generateOTP({
    required String secret,
    required int counter,
    String algorithm = 'SHA1',
    int digits = 6,
  }) {
    // Decode base32 secret
    final key = _base32Decode(secret.toUpperCase().replaceAll(' ', ''));
    
    // Create counter bytes (big-endian 8 bytes)
    final counterBytes = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = c & 0xFF;
      c = c >> 8;
    }
    
    // Compute HMAC
    final hash = _computeHMAC(counterBytes, key, algorithm);
    
    // Dynamic truncation
    final offsetByte = hash[hash.length - 1] & 0x0F;
    var binaryCode = 0;
    for (var i = 0; i < 4; i++) {
      binaryCode = (binaryCode << 8) | (hash[offsetByte + i] & 0xFF);
    }
    binaryCode &= 0x7FFFFFFF;
    
    // Generate code with specified digits
    final otp = binaryCode % _pow(10, digits);
    return otp.toString().padLeft(digits, '0');
  }

  Uint8List _computeHMAC(Uint8List data, Uint8List key, String algorithm) {
    final hmac = Hmac(_getHash(algorithm), key);
    final mac = hmac.convert(data);
    return Uint8List.fromList(mac.bytes);
  }

  Hash _getHash(String algorithm) {
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        return sha256;
      case 'SHA512':
        return sha512;
      case 'SHA1':
      default:
        return sha1;
    }
  }

  Uint8List _base32Decode(String input) {
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

  int _pow(int base, int exp) {
    var result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
