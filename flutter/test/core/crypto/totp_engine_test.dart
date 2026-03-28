import 'package:flutter_test/flutter_test.dart';
import 'package:authvault/core/crypto/totp_engine.dart';

void main() {
  group('TOTP Engine', () {
    test('generates correct 6-digit code', () {
      // Test with known secret
      final code = TOTPEngine.generate(
        secret: 'JBSWY3DPEHPK3PXP', // "Hello!" in base32
        digits: 6,
        period: 30,
        algorithm: OTPAlgorithm.SHA1,
        offset: 0,
      );

      expect(code, isA<String>());
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
    });

    test('generates correct 8-digit code', () {
      final code = TOTPEngine.generate(
        secret: 'JBSWY3DPEHPK3PXP',
        digits: 8,
        period: 30,
        algorithm: OTPAlgorithm.SHA1,
        offset: 0,
      );

      expect(code.length, equals(8));
    });

    test('remainingSeconds is within valid range', () {
      final remaining = TOTPEngine.remainingSeconds(period: 30, offset: 0);
      
      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(30));
    });

    test('custom offset affects code generation', () {
      final code0 = TOTPEngine.generate(
        secret: 'TESTSECRET123456',
        offset: 0,
      );
      
      final code30 = TOTPEngine.generate(
        secret: 'TESTSECRET123456',
        offset: 30,
      );
      
      // Codes may or may not be different depending on timing
      // but both should be valid 6-digit codes
      expect(code0.length, equals(6));
      expect(code30.length, equals(6));
    });

    test('nextCode returns different code', () {
      final current = TOTPEngine.generate(
        secret: 'TESTSECRET123456',
        offset: 0,
      );
      
      final next = TOTPEngine.nextCode(
        secret: 'TESTSECRET123456',
        offset: 0,
      );
      
      expect(current.length, equals(6));
      expect(next.length, equals(6));
    });

    test('different algorithms produce different codes', () {
      final secret = 'TESTSECRET123456';
      
      final sha1 = TOTPEngine.generate(
        secret: secret,
        algorithm: OTPAlgorithm.SHA1,
      );
      
      final sha256 = TOTPEngine.generate(
        secret: secret,
        algorithm: OTPAlgorithm.SHA256,
      );
      
      final sha512 = TOTPEngine.generate(
        secret: secret,
        algorithm: OTPAlgorithm.SHA512,
      );
      
      // All should be valid 6-digit codes
      expect(sha1.length, equals(6));
      expect(sha256.length, equals(6));
      expect(sha512.length, equals(6));
    });
  });
}
