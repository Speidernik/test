import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_app/core/theme/color_profiles.dart';

class SettingsNotifier extends ChangeNotifier {
  static const _keyDark = 'isDarkMode';
  static const _keyProfile = 'colorProfile';

  ThemeMode _themeMode = ThemeMode.system;
  ColorProfile _colorProfile = ColorProfile.normal;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  ColorProfile get colorProfile => _colorProfile;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final darkVal = prefs.getBool(_keyDark);
    _themeMode = darkVal == null
        ? ThemeMode.system
        : (darkVal ? ThemeMode.dark : ThemeMode.light);
    final profileIndex = prefs.getInt(_keyProfile) ?? 0;
    _colorProfile = ColorProfile
        .values[profileIndex.clamp(0, ColorProfile.values.length - 1)];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await prefs.remove(_keyDark);
    } else {
      await prefs.setBool(_keyDark, mode == ThemeMode.dark);
    }
  }

  Future<void> toggleTheme() async {
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setColorProfile(ColorProfile profile) async {
    if (_colorProfile == profile) return;
    _colorProfile = profile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyProfile, profile.index);
  }
}
