import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:money_clone/utils/logging_service.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final LoggingService _logger = LoggingService();
  static const String _pinKey = 'user_pin';
  static const String _useBiometricsKey = 'use_biometrics';

  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) {
      // Biometric authentication is not available on web
      return false;
    }

    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      _logger.error('Error checking biometric availability', e);
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) {
      // No biometrics available on web
      return [];
    }

    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      _logger.error('Error getting available biometrics', e);
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (kIsWeb) {
      // Biometric authentication not supported on web
      return false;
    }

    try {
      final bool useBiometrics = await _getUseBiometrics();
      if (!useBiometrics) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your finance data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      _logger.error('Error authenticating with biometrics', e);
      return false;
    }
  }

  Future<bool> authenticateWithPIN(String pin) async {
    final storedPin = await _getStoredPIN();
    return storedPin == pin;
  }

  Future<bool> setPIN(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_pinKey, pin);
    } catch (e) {
      _logger.error('Error setting PIN', e);
      return false;
    }
  }

  Future<String?> getStoredPIN() async {
    return _getStoredPIN();
  }

  Future<String?> _getStoredPIN() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey);
    } catch (e) {
      _logger.error('Error getting stored PIN', e);
      return null;
    }
  }

  Future<bool> setUseBiometrics(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_useBiometricsKey, value);
    } catch (e) {
      _logger.error('Error setting use biometrics preference', e);
      return false;
    }
  }

  Future<bool> _getUseBiometrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_useBiometricsKey) ?? false;
    } catch (e) {
      _logger.error('Error getting use biometrics preference', e);
      return false;
    }
  }

  Future<bool> isBiometricEnrolled() async {
    if (kIsWeb) return false;

    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      // If we have any biometrics enrolled, the list won't be empty
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      _logger.error('Error checking biometric enrollment', e);
      return false;
    }
  }
}
