import 'dart:math';
import 'package:flutter/material.dart';

/// Guesses a phrased color name, e.g. "looks like purple", "seems like dark blue".
/// Used as the italic fallback label when the API name is unavailable,
/// and always shown as the italic description line alongside the API name.
String guessColorName(Color color) {
  final hsl = HSLColor.fromColor(color);
  final hue = hsl.hue;
  final sat = hsl.saturation;
  final lit = hsl.lightness;

  if (lit < 0.06) return 'looks like black';
  if (lit > 0.94) return 'looks like white';
  if (sat < 0.12) {
    if (lit < 0.35) return 'looks like dark grey';
    if (lit > 0.72) return 'looks like light grey';
    return 'looks like grey';
  }

  final String name;
  if (hue < 15 || hue >= 345) {
    name = 'red';
  } else if (hue < 45) {
    name = 'orange';
  } else if (hue < 70) {
    name = 'yellow';
  } else if (hue < 90) {
    name = 'lime';
  } else if (hue < 150) {
    name = 'green';
  } else if (hue < 195) {
    name = 'teal';
  } else if (hue < 255) {
    name = 'blue';
  } else if (hue < 285) {
    name = 'purple';
  } else if (hue < 330) {
    name = 'magenta';
  } else {
    name = 'pink';
  }

  final String fullName;
  if (lit < 0.30) {
    fullName = 'dark $name';
  } else if (lit > 0.68) {
    fullName = 'light $name';
  } else {
    fullName = name;
  }

  const variations = [
    'looks like',
    'appears to be',
    'resembles a',
    'seems like',
    'kind of like',
  ];
  final phrase = variations[Random().nextInt(variations.length)];
  return '$phrase $fullName';
}

/// Returns perceptual property tags for [color]: temperature, saturation, lightness.
/// Returns null for achromatic colors (black, white, grey) where properties are redundant.
///
/// Example: "cool · moderate · medium"
String? colorProperties(Color? color) {
  if (color == null) return null;

  final hsl = HSLColor.fromColor(color);
  final hue = hsl.hue;
  final sat = hsl.saturation;
  final lit = hsl.lightness;

  if (lit < 0.06 || lit > 0.94 || sat < 0.12) return null;

  final String temperature;
  if (hue < 65 || hue >= 335) {
    temperature = 'warm';
  } else if (hue < 120 || (hue >= 310 && hue < 335)) {
    temperature = 'neutral';
  } else {
    temperature = 'cool';
  }

  final String saturation;
  if (sat > 0.65) {
    saturation = 'vivid';
  } else if (sat > 0.35) {
    saturation = 'moderate';
  } else {
    saturation = 'muted';
  }

  final String lightness;
  if (lit < 0.30) {
    lightness = 'dark';
  } else if (lit > 0.68) {
    lightness = 'light';
  } else {
    lightness = 'medium';
  }

  return '$temperature · $saturation · $lightness';
}
