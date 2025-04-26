import 'dart:math';
import 'package:flutter/material.dart';

String? describeColor(Color? color) {
  if (color != null) {
    final hsl = HSLColor.fromColor(color);
    final hue = hsl.hue;
    final saturation = hsl.saturation;
    final lightness = hsl.lightness;

    debugPrint('Hue: $hue');
    debugPrint('Saturation: $saturation');
    debugPrint('Lightness: $lightness');

    String baseColor;

    // Primeiro: identificar pela tonalidade
    if (hue < 15 || hue >= 345) {
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

    // Depois: tratar extremos de brilho e saturação
    if (lightness < 0.08) {
      baseColor = 'black';
    } else if (lightness > 0.92) {
      baseColor = 'white';
    } else if (saturation < 0.15) {
      baseColor = 'gray';
    } else {
      // Se não caiu nos neutros, ajusta com light/dark
      if (lightness < 0.3) {
        baseColor = 'dark $baseColor';
      } else if (lightness > 0.7) {
        baseColor = 'light $baseColor';
      }
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
