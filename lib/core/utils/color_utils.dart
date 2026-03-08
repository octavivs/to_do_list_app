// ---
// UTILITY: color_utils.dart
// ---
import 'package:flutter/material.dart';

// OOP CONCEPT: Utility Class
// A class containing static methods that act as generic helpers across the app.
class ColorUtils {
  // Converts a standard Hexadecimal color string (like '#FF5733')
  // into a Flutter-readable Color object.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    // Flutter expects an 8-digit hex value where the first 2 digits represent
    // the Alpha (opacity) channel. 'ff' means 100% opaque.
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
