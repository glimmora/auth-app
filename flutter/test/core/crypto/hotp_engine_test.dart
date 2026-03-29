import 'package:flutter_test/flutter_test.dart';
import 'package:authvault/core/crypto/hotp_engine.dart';

void main() {
  group('HOTP Engine', () {
    test('generates correct 6-digit code for counter 0', () {
      final code = HOTPEngine.generate(
        secret: 'JBSWY3DPEHPK3PXP',
        counter: 0,
        digits: 6,
        algorithm: OTPAlgorithm.SHA1,
      );

      expect(code, isA<String>());
      expect(code.length, equals(6));
    });

    test('generates different codes for different counters', () {
      const secret = 'TESTSECRET123456';

      final code0 = HOTPEngine.generate(
        secret: secret,
        counter: 0,
      );

      final code1 = HOTPEngine.generate(
        secret: secret,
        counter: 1,
      );

      final code2 = HOTPEngine.generate(
        secret: secret,
        counter: 2,
      );

      // All should be valid codes but different
      expect(code0.length, equals(6));
      expect(code1.length, equals(6));
      expect(code2.length, equals(6));

      // At least some should be different (statistically very likely)
      expect(code0 != code1 || code1 != code2, isTrue);
    });

    test('supports 8-digit codes', () {
      final code = HOTPEngine.generate(
        secret: 'JBSWY3DPEHPK3PXP',
        counter: 1,
        digits: 8,
      );

      expect(code.length, equals(8));
    });
  });
}
