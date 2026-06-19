import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_app/core/l10n/app_strings.dart';
import 'package:starter_app/core/theme/color_profiles.dart';

enum AppLanguage { english, german }

class SettingsNotifier extends ChangeNotifier {
  static const _keyDark = 'isDarkMode';
  static const _keyProfile = 'colorProfile';
  static const _keyLang = 'language';

  ThemeMode _themeMode = ThemeMode.dark;
  ColorProfile _colorProfile = ColorProfile.normal;
  AppLanguage _language = AppLanguage.english;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  ColorProfile get colorProfile => _colorProfile;
  AppLanguage get language => _language;

  Locale get locale => _language == AppLanguage.german
      ? const Locale('de')
      : const Locale('en');

  AppStrings get strings => AppStrings(locale);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        (prefs.getBool(_keyDark) ?? true) ? ThemeMode.dark : ThemeMode.light;
    final profileIndex = prefs.getInt(_keyProfile) ?? 0;
    _colorProfile = ColorProfile.values[profileIndex.clamp(0, ColorProfile.values.length - 1)];
    final langIndex = prefs.getInt(_keyLang) ?? 0;
    _language = AppLanguage.values[langIndex.clamp(0, AppLanguage.values.length - 1)];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDark, isDark);
  }

  Future<void> setColorProfile(ColorProfile profile) async {
    if (_colorProfile == profile) return;
    _colorProfile = profile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyProfile, profile.index);
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLang, language.index);
  }
}
