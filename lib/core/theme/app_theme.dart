import 'package:flutter/material.dart';

/// Sistema de diseño minimalista inspirado en portales del Estado peruano (gob.pe / PRONABEC).
class AppTheme {
  const AppTheme._();

  static const Color primary = Color(0xFFBF0909);
  static const Color primarySoft = Color(0xFFFEF2F2);
  static const Color accent = Color(0xFF15803D);
  static const Color accentSoft = Color(0xFFF0FDF4);
  static const Color destructive = Color(0xFF991B1B);
  static const Color destructiveSoft = Color(0xFFFEF2F2);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color mutedSurface = Color(0xFFF8FAFC);
  static const Color foreground = Color(0xFF111827);
  static const Color mutedForeground = Color(0xFF4B5563);
  static const Color border = Color(0xFFE5E7EB);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      error: destructive,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: foreground,
          height: 1.25,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: foreground,
          height: 1.4,
          letterSpacing: -0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w400,
          color: foreground,
          height: 1.65,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: mutedForeground,
          height: 1.6,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
