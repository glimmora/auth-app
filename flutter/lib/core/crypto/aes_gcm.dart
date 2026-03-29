import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';

/// AES-256-GCM encryption/decryption
///
/// Uses 96-bit IV (standard for GCM mode)
/// Prepends IV to ciphertext for storage
class AESGCM {
  /// Encrypts plaintext using AES-256-GCM
  ///
  /// Returns a map containing:
  /// - iv: base64-encoded initialization vector
  /// - ciphertext: base64-encoded encrypted data
  /// - tag: base64-encoded authentication tag
  static Future<Map<String, String>> encrypt({
    required Uint8List plaintext,
    required Uint8List key,
  }) async {
    final algorithm = AesGcm.with256Bits();

    // Generate random 96-bit IV
    final iv = await _generateIV();

    // Encrypt
    final result = await algorithm.encrypt(
      plaintext,
      secretKey: SecretKey(key),
      nonce: iv,
    );

    return {
      'iv': base64Encode(iv),
      'ciphertext': base64Encode(result.ciphertext),
      'tag': base64Encode(result.authenticationTag),
    };
  }

  /// Decrypts ciphertext using AES-256-GCM
  ///
  /// Expects base64-encoded iv, ciphertext, and tag
  static Future<Uint8List> decrypt({
    required String ciphertext,
    required String iv,
    required String tag,
    required Uint8List key,
  }) async {
    final algorithm = AesGcm.with256Bits();

    final decrypted = await algorithm.decrypt(
      base64Decode(ciphertext),
      secretKey: SecretKey(key),
      nonce: base64Decode(iv),
      authenticationTag: base64Decode(tag),
    );

    return Uint8List.fromList(decrypted);
  }

  /// Encrypts and returns a single packed buffer (IV + ciphertext + tag)
  static Future<Uint8List> encryptPacked({
    required Uint8List plaintext,
    required Uint8List key,
  }) async {
    final encrypted = await encrypt(plaintext: plaintext, key: key);

    final iv = base64Decode(encrypted['iv']!);
    final ciphertext = base64Decode(encrypted['ciphertext']!);
    final tag = base64Decode(encrypted['tag']!);

    // Pack: IV (12 bytes) + ciphertext + tag (16 bytes)
    final packed = Uint8List(iv.length + ciphertext.length + tag.length);
    packed.setRange(0, iv.length, iv);
    packed.setRange(iv.length, iv.length + ciphertext.length, ciphertext);
    packed.setRange(iv.length + ciphertext.length, packed.length, tag);

    return packed;
  }

  /// Decrypts from a packed buffer (IV + ciphertext + tag)
  static Future<Uint8List> decryptPacked({
    required Uint8List packed,
    required Uint8List key,
  }) async {
    // Unpack: IV (12 bytes) + ciphertext + tag (16 bytes)
    final iv = packed.sublist(0, 12);
    final tag = packed.sublist(packed.length - 16);
    final ciphertext = packed.sublist(12, packed.length - 16);

    return decrypt(
      ciphertext: base64Encode(ciphertext),
      iv: base64Encode(iv),
      tag: base64Encode(tag),
      key: key,
    );
  }

  static Future<Uint8List> _generateIV() async {
    final random = await Random.secure();
    return Uint8List.fromList(
      List.generate(12, (_) => random.nextInt(256)),
    );
  }

  /// Generates a random 256-bit key
  static Future<Uint8List> generateKey() async {
    final random = await Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
  }
}
