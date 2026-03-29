import 'dart:math';
import 'dart:typed_data';

/// Base32 encoding/decoding utilities
///
/// Uses RFC 4648 Base32 alphabet (A-Z, 2-7)
class Base32 {
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const _padding = '=';

  /// Encodes bytes to Base32 string
  static String encode(Uint8List data) {
    final buffer = StringBuffer();
    var bufferValue = 0;
    var bitsLeft = 0;

    for (final byte in data) {
      bufferValue = (bufferValue << 8) | byte;
      bitsLeft += 8;

      while (bitsLeft >= 5) {
        final index = (bufferValue >> (bitsLeft - 5)) & 0x1F;
        buffer.write(_alphabet[index]);
        bitsLeft -= 5;
      }
    }

    if (bitsLeft > 0) {
      final index = (bufferValue << (5 - bitsLeft)) & 0x1F;
      buffer.write(_alphabet[index]);
    }

    // Add padding
    final mod = buffer.length % 8;
    if (mod != 0) {
      buffer.write(_padding * (8 - mod));
    }

    return buffer.toString();
  }

  /// Decodes Base32 string to bytes
  static Uint8List decode(String input) {
    // Remove padding and whitespace, convert to uppercase
    input = input.toUpperCase().replaceAll('=', '').replaceAll(' ', '');

    final buffer = <int>[];
    var bufferValue = 0;
    var bitsLeft = 0;

    for (final char in input.split('')) {
      final index = _alphabet.indexOf(char);
      if (index == -1) {
        throw ArgumentError('Invalid Base32 character: $char');
      }

      bufferValue = (bufferValue << 5) | index;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        buffer.add((bufferValue >> (bitsLeft - 8)) & 0xFF);
        bitsLeft -= 8;
      }
    }

    return Uint8List.fromList(buffer);
  }

  /// Validates if a string is valid Base32
  static bool isValid(String input) {
    final cleaned = input.toUpperCase().replaceAll('=', '').replaceAll(' ', '');
    if (cleaned.isEmpty) return false;

    for (final char in cleaned.split('')) {
      if (!_alphabet.contains(char)) {
        return false;
      }
    }

    return true;
  }

  /// Generates a random Base32 secret
  static Future<String> generateSecret({int bytes = 20}) async {
    final random = Random.secure();
    final bytesList = List.generate(bytes, (_) => random.nextInt(256));
    return encode(Uint8List.fromList(bytesList));
  }
}
