import 'dart:math';
import 'package:flutter/material.dart';

String? describeColor(Color? color) {
  if (color != null) {
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;
    final saturation = hsl.saturation;
    final lightness = hsl.lightness;

    debugPrint(hue.toString());
    debugPrint(saturation.toString());
    debugPrint(lightness.toString());

    String baseColor;

    if (lightness < 0.15) {
      baseColor = 'black';
    } else if (lightness > 0.85 && saturation < 0.2) {
      baseColor = 'white';
    } else if (saturation < 0.25) {
      baseColor = 'gray';
    } else if (hue >= 20 && hue < 40 && saturation > 0.4 && lightness < 0.5) {
      baseColor = 'brown';
    } else if (hue >= 30 && hue < 50 && saturation < 0.5 && lightness > 0.6) {
      baseColor = 'beige';
    } else if (hue >= 70 && hue < 95 && saturation < 0.5 && lightness > 0.4) {
      baseColor = 'olive';
    } else if (hue < 15 || hue >= 345) {
      baseColor = 'red';
    } else if (hue >= 15 && hue < 45) {
      baseColor = 'orange';
    } else if (hue >= 45 && hue < 75) {
      baseColor = 'yellow';
    } else if (hue >= 75 && hue < 150) {
      baseColor = 'green';
    } else if (hue >= 150 && hue < 210) {
      baseColor = 'cyan';
    } else if (hue >= 210 && hue < 270) {
      baseColor = 'blue';
    } else if (hue >= 270 && hue < 330) {
      baseColor = 'purple';
    } else {
      baseColor = 'pink';
    }

    final variations = [
      'looks like $baseColor',
      'appears to be $baseColor',
      'resembles a $baseColor shade',
      'seems like $baseColor',
      'kind of like $baseColor',
    ];

    final random = Random();
    return variations[random.nextInt(variations.length)];
  }
  return null;
}
