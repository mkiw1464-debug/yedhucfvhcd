import 'package:flutter/material.dart';

class FFTheme {
  static const Color bg = Color(0xFF0D0D0F);
  static const Color bgCard = Color(0xFF1A1A1F);
  static const Color surface = Color(0xFF22222A);
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color accent = Color(0xFF5B8DEF);
  static const Color accentGlow = Color(0x335B8DEF);
  static const Color green = Color(0xFF34C759);
  static const Color red = Color(0xFFFF3B30);
  static const Color orange = Color(0xFFFF9F0A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF48484A);
  static const Color divider = Color(0xFF2C2C2E);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: bgCard,
          background: bg,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          titleMedium: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          labelSmall: TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: glass,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          hintStyle: const TextStyle(color: textMuted, fontSize: 15),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        useMaterial3: true,
      );
}
