enum OTPAlgorithm { SHA1, SHA256, SHA512 }

extension OTPAlgorithmExtension on OTPAlgorithm {
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
