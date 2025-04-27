import 'package:flutter/material.dart';

Color getComplementaryColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  final newHue = (hsl.hue + 180.0) % 360.0;
  return hsl.withHue(newHue).toColor();
}

Color getAnalogousColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  final newHue = (hsl.hue + 30.0) % 360.0; // 30 graus pra frente
  return hsl.withHue(newHue).toColor();
}

Color getTriadicColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  final newHue = (hsl.hue + 120.0) % 360.0; // 120 graus pra frente
  return hsl.withHue(newHue).toColor();
}

Color getTetradicColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  final newHue = (hsl.hue + 90.0) % 360.0; // 90 graus pra frente
  return hsl.withHue(newHue).toColor();
}
