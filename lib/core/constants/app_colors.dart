// ---
// CONSTANTS: app_colors.dart
// ---
import 'package:flutter/material.dart';

// OOP CONCEPT: Static Configuration Class
// By using static constant variables, we create a single source of truth for
// the app's visual identity. The private constructor `AppColors._()` prevents
// developers from accidentally instantiating this class as an object.
class AppColors {
  // Private constructor
  AppColors._();

  // ---
  // BRAND COLORS
  // ---
  // The main identity colors of the application.
  static const Color primary = Colors.blueAccent;
  static const Color primaryDark = Color(
    0xFF1E3A8A,
  ); // A deeper blue for contrast

  // ---
  // BACKGROUNDS
  // ---
  static const Color background = Color(0xFFF3F4F6); // Very light gray/blue
  static const Color surface =
      Colors.white; // Used for cards, modals, and sheets

  // ---
  // TYPOGRAPHY (TEXT COLORS)
  // ---
  static const Color textPrimary = Color(
    0xFF1F2937,
  ); // Dark gray, softer than pure black
  static const Color textSecondary = Color(
    0xFF6B7280,
  ); // Medium gray for subtitles
  static const Color textLight = Colors.white; // Text over dark backgrounds

  // ---
  // SYSTEM & STATUS
  // ---
  static const Color error = Color(
    0xFFEF4444,
  ); // Red for destructive actions (Delete)
  static const Color success = Color(0xFF10B981); // Green for completions
  static const Color divider = Color(0xFFE5E7EB); // Subtle line separators
}
