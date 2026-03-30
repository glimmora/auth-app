import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Key Derivation Functions
///
/// Supports PBKDF2 for deriving encryption keys from passwords
/// Argon2 is not supported by the cryptography package - use external package if needed
class KeyDerivation {
  /// PBKDF2 key derivation
  ///
  /// [password] - User password
  /// [salt] - Random salt (minimum 16 bytes recommended)
  /// [iterations] - Number of iterations (minimum 310,000 per OWASP 2023)
  /// [keyLength] - Desired key length in bytes (32 for AES-256)
  static Future<Uint8List> pbkdf2({
    required String password,
    required Uint8List salt,
    int iterations = 310000,
    int keyLength = 32,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: keyLength * 8,
    );

    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    return Uint8List.fromList(await key.extractBytes());
  }

  /// Argon2-like key derivation using PBKDF2 with higher iterations
  /// (Argon2 is not available in the cryptography package for all platforms)
  ///
  /// [password] - User password
  /// [salt] - Random salt (minimum 16 bytes)
  /// [iterations] - Number of iterations
  /// [keyLength] - Desired key length in bytes (32 for AES-256)
  static Future<Uint8List> argon2({
    required String password,
    required Uint8List salt,
    int iterations = 10,
    int memory = 65536,
    int parallelism = 4,
    int keyLength = 32,
  }) async {
    // Fall back to PBKDF2 with more iterations as Argon2 is not cross-platform
    // in the cryptography package. For true Argon2, use argon2_flutter package.
    return pbkdf2(
      password: password,
      salt: salt,
      iterations: iterations * 10000,
      keyLength: keyLength,
    );
  }

  /// Generates a cryptographically secure random salt
  static Uint8List generateSalt({int length = 32}) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Verifies a password against a stored derived key
  ///
  /// Returns true if the password matches
  static Future<bool> verifyPassword({
    required String password,
    required Uint8List salt,
    required Uint8List storedKey,
    String kdf = 'pbkdf2',
    int iterations = 310000,
  }) async {
    Uint8List derivedKey;

    if (kdf == 'argon2') {
      derivedKey = await argon2(password: password, salt: salt);
    } else {
      derivedKey = await pbkdf2(
        password: password,
        salt: salt,
        iterations: iterations,
      );
    }

    // Constant-time comparison
    if (derivedKey.length != storedKey.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < derivedKey.length; i++) {
      result |= derivedKey[i] ^ storedKey[i];
    }

    return result == 0;
  }
}
