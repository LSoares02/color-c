import 'package:flutter/material.dart';

/// Returns the 6-character uppercase hex string for a [Color] (no # prefix).
/// e.g. Color(0xFF3A7BD5) → "3A7BD5"
String colorToHex(Color color) {
  final argb = color.toARGB32();
  return argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
}
