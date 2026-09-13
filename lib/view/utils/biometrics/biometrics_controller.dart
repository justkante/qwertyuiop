import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_darwin/types/auth_messages_ios.dart';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:local_auth_android/local_auth_android.dart';

class Biometrics {
  static LocalAuthentication auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      final hasBiometric = await auth.canCheckBiometrics;

      final bool canAuthenticate = hasBiometric || await auth.isDeviceSupported();

      if (canAuthenticate) {
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  static Future<BiometricType> enrolledBiometric() async {
    try {
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      for (var biometric in availableBiometrics) {
        switch (biometric) {
          case BiometricType.face:
            return BiometricType.face;
          case BiometricType.fingerprint:
            return BiometricType.fingerprint;
          case BiometricType.strong:
            return BiometricType.strong;
          default:
            return BiometricType.fingerprint;
        }
      }

      return BiometricType.fingerprint;
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> deviceEnrolledBiometric() async {
    try {
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      final List<BiometricType> availables = [
        BiometricType.face,
        BiometricType.fingerprint,
        BiometricType.strong
      ];

      bool containsAny = availables.any((biometric) => availableBiometrics.contains(biometric));
      if (containsAny) {
        return true;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> hasPassword(String password) async {
    final storage = inject.get<SecureStorage>();
    final res = await storage.containsData(password);
    return res;
  }

  static Future<bool> authenticate() async {
    try {
      if (await hasBiometrics() &&
          SharedPrefManager.hasBiometrics &&
          await hasPassword(PrefKeys.password)) {
        final isAuthenticated = await auth.authenticate(
          localizedReason: "Verify your Account with your Biometrics",
          authMessages: [
            const AndroidAuthMessages(
              biometricHint: 'Finger Print Authentication is Required!',
              cancelButton: 'No Thanks!',
            ),
            const IOSAuthMessages(),
          ],
          options: const AuthenticationOptions(
            useErrorDialogs: true,
            stickyAuth: false,
          ),
        );

        return isAuthenticated;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> reqAuthenticate() async {
    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: "Verify your Account with your Biometrics",
        authMessages: [
          const AndroidAuthMessages(
            biometricHint: 'Finger Print Authentication is Required!',
            cancelButton: 'No Thanks!',
          ),
          const IOSAuthMessages(),
        ],
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: false,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> saveOnAuth() async {
    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: "Verify your Account with your Biometrics",
        authMessages: [
          const AndroidAuthMessages(
            biometricHint: 'Finger Print Authentication is Required!',
            cancelButton: 'No Thanks!',
          ),
          const IOSAuthMessages(),
        ],
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: false,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      throw e.toString();
    }
  }
}
