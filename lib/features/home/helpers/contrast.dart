import 'dart:math'; // Importando a biblioteca de matemática

import 'package:flutter/material.dart';

Color getContrastingTextColor(Color background) {
  // Fórmula padrão para luminância relativa (https://www.w3.org/TR/WCAG20/#relativeluminancedef)
  final r = background.r / 255.0;
  final g = background.g / 255.0;
  final b = background.b / 255.0;

  final luminance =
      0.2126 * _linearize(r) + 0.7152 * _linearize(g) + 0.0722 * _linearize(b);

  // Ajusta a lógica de contraste para não falhar em cores muito claras
  if (luminance >= 0.85) {
    return Colors.black; // Em cores muito claras, o texto será preto
  }

  debugPrint('Luminância: $luminance, Cor de fundo: $background');

  // Garantindo que a luminância mínima para cores quase brancas não seja muito baixa
  return luminance > 0.5 ? Colors.black : Colors.white;
}

double _linearize(double channel) {
  return (channel <= 0.03928)
      ? channel / 12.92
      : pow((channel + 0.055) / 1.055, 2.4).toDouble();
}
