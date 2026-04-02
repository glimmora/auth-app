import 'dart:typed_data';
import 'package:pointycastle/digests/sha1.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/macs/hmac.dart';

import 'otp_algorithm.dart';

class TOTPEngine {
  static String generate({
    required String secret,
    int digits = 6,
    int period = 30,
    OTPAlgorithm algorithm = OTPAlgorithm.SHA1,
    int offset = 0,
  }) {
    final adjustedTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + offset;
    final counter = adjustedTime ~/ period;
    return _computeHOTP(
      secret: secret,
      counter: counter,
      digits: digits,
      algorithm: algorithm,
    );
  }

  static int remainingSeconds({int period = 30, int offset = 0}) {
    final adjustedTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + offset;
    return period - (adjustedTime % period);
  }

  static double progress({int period = 30, int offset = 0}) {
    final adjustedTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + offset;
    return (adjustedTime % period) / period;
  }

  static String nextCode({
    required String secret,
    int digits = 6,
    int period = 30,
    OTPAlgorithm algorithm = OTPAlgorithm.SHA1,
    int offset = 0,
  }) {
    final adjustedTime =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + offset;
    final counter = (adjustedTime ~/ period) + 1;
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
    final key = _base32Decode(secret.toUpperCase().replaceAll(' ', ''));

    final counterBytes = Uint8List(8);
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = counter & 0xFF;
      counter = counter >> 8;
    }

    final hmac = _getHmac(algorithm, key);
    final hash = hmac.process(counterBytes);

    final offset = hash[hash.length - 1] & 0x0F;
    var binaryCode = 0;
    for (var i = 0; i < 4; i++) {
      binaryCode = (binaryCode << 8) | (hash[offset + i] & 0xFF);
    }
    binaryCode &= 0x7FFFFFFF;

    final otp = binaryCode % _pow10(digits);

    return otp.toString().padLeft(digits, '0');
  }

  static HMac _getHmac(OTPAlgorithm algorithm, Uint8List key) {
    final HMac hmac;
    switch (algorithm) {
      case OTPAlgorithm.SHA1:
        hmac = HMac(SHA1Digest(), 64);
      case OTPAlgorithm.SHA256:
        hmac = HMac(SHA256Digest(), 64);
      case OTPAlgorithm.SHA512:
        hmac = HMac(SHA512Digest(), 128);
    }
    hmac.init(KeyParameter(key));
    return hmac;
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
