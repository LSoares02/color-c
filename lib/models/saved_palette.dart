import 'package:flutter/material.dart';

class SavedPalette {
  final String id;
  final Color baseColor;
  final String colorApiName;
  final String schemeName;
  final List<Color> schemeColors;
  final DateTime savedAt;

  const SavedPalette({
    required this.id,
    required this.baseColor,
    required this.colorApiName,
    required this.schemeName,
    required this.schemeColors,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'baseColor': baseColor.toARGB32(),
    'colorApiName': colorApiName,
    'schemeName': schemeName,
    'schemeColors': schemeColors.map((c) => c.toARGB32()).toList(),
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedPalette.fromJson(Map<String, dynamic> json) => SavedPalette(
    id: json['id'] as String,
    baseColor: Color(json['baseColor'] as int),
    colorApiName: json['colorApiName'] as String,
    schemeName: json['schemeName'] as String,
    schemeColors:
        (json['schemeColors'] as List).map((v) => Color(v as int)).toList(),
    savedAt: DateTime.parse(json['savedAt'] as String),
  );
}
