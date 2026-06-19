import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'color_profiles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData buildDark(ColorProfile profile) {
    final c = profileColors(profile);
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: c.primary,
        secondary: c.primaryLight,
        surface: AppColors.darkSurface,
        error: c.error,
        onPrimary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: _textTheme(
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.darkCard,
        border: AppColors.darkBorder,
        label: AppColors.darkTextSecondary,
        hint: AppColors.darkTextSecondary,
        focusBorder: c.primary,
      ),
      elevatedButtonTheme: _buttonTheme(c.primary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.primary),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: c.primary.withAlpha(51),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.primary);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: c.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 11,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerColor: AppColors.darkBorder,
    );
  }

  static ThemeData buildLight(ColorProfile profile) {
    final c = profileColors(profile);
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBgStart,
      colorScheme: ColorScheme.light(
        primary: c.primaryDark,
        secondary: c.primary,
        surface: AppColors.lightSurface,
        error: c.error,
        onPrimary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: _textTheme(
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
      ),
      inputDecorationTheme: _inputTheme(
        fill: Colors.white,
        border: AppColors.lightBorder,
        label: AppColors.lightTextSecondary,
        hint: AppColors.lightTextSecondary,
        focusBorder: c.primaryDark,
      ),
      elevatedButtonTheme: _buttonTheme(c.primaryDark),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.primaryDark),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: c.primaryDark.withAlpha(26),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.primaryDark);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: c.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 11,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      dividerColor: AppColors.lightBorder,
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: TextStyle(color: primary, fontWeight: FontWeight.w900),
    displayMedium: TextStyle(color: primary, fontWeight: FontWeight.w800),
    headlineLarge: TextStyle(color: primary, fontWeight: FontWeight.w800),
    headlineMedium: TextStyle(color: primary, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: secondary, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: primary),
    bodyMedium: TextStyle(color: primary),
    bodySmall: TextStyle(color: secondary, fontSize: 12),
    labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
  );

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color label,
    required Color hint,
    required Color focusBorder,
  }) => InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: TextStyle(color: label, fontSize: 14),
    hintStyle: TextStyle(color: hint.withAlpha(153), fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focusBorder, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
  );

  static ElevatedButtonThemeData _buttonTheme(Color primary) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
}
