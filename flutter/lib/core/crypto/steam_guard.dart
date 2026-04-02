import 'dart:typed_data';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha1.dart';

class SteamGuard {
  static const _steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';

  static String generateCode({
    required String secret,
    int offset = 0,
  }) {
    final adjustedTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + offset;
    final counter = adjustedTime ~/ 30;

    final keyBytes = _base32Decode(secret.toUpperCase().replaceAll(' ', ''));

    final counterBytes = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = c & 0xFF;
      c = c >> 8;
    }

    final hmac = HMac(SHA1Digest(), 64);
    hmac.init(KeyParameter(keyBytes));
    final hash = hmac.process(counterBytes);

    final offsetByte = hash[hash.length - 1] & 0x0F;
    var binaryCode = 0;
    for (var i = 0; i < 4; i++) {
      binaryCode = (binaryCode << 8) | (hash[offsetByte + i] & 0xFF);
    }
    binaryCode &= 0x7FFFFFFF;

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
