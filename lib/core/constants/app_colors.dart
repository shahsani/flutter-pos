import 'package:flutter/material.dart';

class AppColors {
  // Primary - Vibrant Pale Sky Blue for POS actions (MokPOS often uses warm accents)
  static const Color primary = Color(0xFFB9CDDA); // Soft Pale Sky Blue
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFFFD9D9);
  static const Color onPrimaryContainer = Color(0xFF680000);

  // Secondary - Teal/Blue for info
  static const Color secondary = Color(0xFF4ECDC4); // Teal
  static const Color onSecondary = Colors.black;
  static const Color secondaryContainer = Color(0xFFCBF3F0);
  static const Color onSecondaryContainer = Color(0xFF004E4A);

  // Tertiary - Yellow for warnings/highlights
  static const Color tertiary = Color(0xFFFFD166);
  static const Color onTertiary = Colors.black;

  // Backgrounds
  static const Color backgroundLight = Color(
    0xFFF7F9FC,
  ); // Very light grey blue
  static const Color surfaceLight = Colors.white;

  static const Color backgroundDark = Color(0xFF1A1C1E);
  static const Color surfaceDark = Color(0xFF2C3035);

  // Text
  static const Color textLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);

  static const Color textDark = Color(0xFFDFE6E9);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);

  // Status
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
}
