import 'dart:typed_data';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/mac/hmac.dart';

/// Steam Guard TOTP variant
/// 
/// Steam uses SHA-1 TOTP with 30s period but encodes the result
/// as 5 characters from a custom alphabet instead of decimal digits.
class SteamGuard {
  static const _steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';

  /// Generates a Steam Guard code
  /// 
  /// [secret] Base32-encoded shared secret
  /// [offset] Custom time offset in seconds
  static String generateCode({
    required String secret,
    int offset = 0,
  }) {
    final adjustedTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + offset;
    final counter = adjustedTime ~/ 30;
    
    final key = _base32Decode(secret.toUpperCase().replaceAll(' ', ''));
    
    // Create counter bytes (big-endian 8 bytes)
    final counterBytes = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = c & 0xFF;
      c = c >> 8;
    }

    // Compute HMAC-SHA1
    final hmac = Hmac(SHA1(), key);
    final hash = hmac.process(counterBytes);

    // Dynamic truncation
    final offsetByte = hash[hash.length - 1] & 0x0F;
    var binaryCode = 0;
    for (var i = 0; i < 4; i++) {
      binaryCode = (binaryCode << 8) | (hash[offsetByte + i] & 0xFF);
    }
    binaryCode &= 0x7FFFFFFF;

    // Generate 5-character Steam code
    final result = StringBuffer();
    for (var i = 0; i < 5; i++) {
      result.write(_steamAlphabet[binaryCode % _steamAlphabet.length]);
      binaryCode ~/= _steamAlphabet.length;
    }

    return result.toString();
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
