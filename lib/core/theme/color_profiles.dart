import 'package:flutter/material.dart';

enum ColorProfile { normal, highContrast, deuteranopia, protanopia, tritanopia }

class ProfileColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color success;
  final Color error;
  final Color info;

  const ProfileColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.success,
    required this.error,
    required this.info,
  });
}

const Map<ColorProfile, ProfileColors> colorProfiles = {
  ColorProfile.normal: ProfileColors(
    primary: Color(0xFF6366F1),
    primaryLight: Color(0xFF818CF8),
    primaryDark: Color(0xFF4F46E5),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    info: Color(0xFF0EA5E9),
  ),
  ColorProfile.highContrast: ProfileColors(
    primary: Color(0xFFFFD700),
    primaryLight: Color(0xFFFFE44D),
    primaryDark: Color(0xFFCCAC00),
    success: Color(0xFF00FF88),
    error: Color(0xFFFF3333),
    info: Color(0xFF44AAFF),
  ),
  // Red–green colorblind: swap red/green semantic colors for blue shades
  ColorProfile.deuteranopia: ProfileColors(
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFBBF24),
    primaryDark: Color(0xFFD97706),
    success: Color(0xFF0072B2),
    error: Color(0xFFCC79A7),
    info: Color(0xFF56B4E9),
  ),
  // Red-deficient: use orange/yellow for error instead of red
  ColorProfile.protanopia: ProfileColors(
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFBBF24),
    primaryDark: Color(0xFFD97706),
    success: Color(0xFF009E73),
    error: Color(0xFFE69F00),
    info: Color(0xFF56B4E9),
  ),
  // Blue–yellow colorblind: use pink/magenta for brand, avoid pure blue
  ColorProfile.tritanopia: ProfileColors(
    primary: Color(0xFFFF6DAE),
    primaryLight: Color(0xFFFF9DC8),
    primaryDark: Color(0xFFCC3A7B),
    success: Color(0xFF009E73),
    error: Color(0xFFEF4444),
    info: Color(0xFF009E73),
  ),
};

ProfileColors profileColors(ColorProfile p) => colorProfiles[p]!;

extension ColorProfileLabel on ColorProfile {
  String get label => switch (this) {
    ColorProfile.normal => 'Normal',
    ColorProfile.highContrast => 'High Contrast',
    ColorProfile.deuteranopia => 'Deuteranopia',
    ColorProfile.protanopia => 'Protanopia',
    ColorProfile.tritanopia => 'Tritanopia',
  };
}
