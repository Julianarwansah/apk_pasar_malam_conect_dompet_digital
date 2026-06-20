enum BiometricErrorCode {
  notAvailable,
  notEnrolled,
  authenticationFailed,
  cancelled,
  unknown,
}

class BiometricException implements Exception {
  final BiometricErrorCode code;
  final String message;

  const BiometricException(this.code, this.message);

  String get userMessage {
    switch (code) {
      case BiometricErrorCode.notAvailable:
        return 'Biometrik tidak tersedia di perangkat ini.';
      case BiometricErrorCode.notEnrolled:
        return 'Belum ada biometrik yang terdaftar.';
      case BiometricErrorCode.authenticationFailed:
        return 'Autentikasi biometrik gagal.';
      case BiometricErrorCode.cancelled:
        return 'Autentikasi dibatalkan.';
      case BiometricErrorCode.unknown:
        return message;
    }
  }

  @override
  String toString() => 'BiometricException($code, $message)';
}

class BiometricService {
  Future<bool> isBiometricAvailable() async => false;

  Future<void> authenticate({required String reason}) async {
    throw const BiometricException(
      BiometricErrorCode.notAvailable,
      'Biometric implementation is not configured.',
    );
  }
}
