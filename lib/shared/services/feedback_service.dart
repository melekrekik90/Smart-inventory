import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  static const String _keySound = 'pref_sound';
  static const String _keyVibration = 'pref_vibration';

  /// Joue le son de clic système par défaut si activé
  static Future<void> playClickSound() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSoundEnabled = prefs.getBool(_keySound) ?? true;
    if (isSoundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Déclenche une vibration forte (utilisée après un scan réussi) si activée
  static Future<void> playScanVibration() async {
    final prefs = await SharedPreferences.getInstance();
    bool isVibrationEnabled = prefs.getBool(_keyVibration) ?? true;
    if (isVibrationEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySound) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
  }

  static Future<bool> isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibration) ?? true;
  }

  static Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibration, value);
  }
}
