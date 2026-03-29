import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _kTimeout = Duration(seconds: 8);

Future<String?> fetchColorName(String hexColor) async {
  final cleanHex = hexColor.length > 6 ? hexColor.substring(0, 6) : hexColor;
  final url = Uri.parse('https://www.thecolorapi.com/id?hex=$cleanHex');

  try {
    final response = await http.get(url).timeout(_kTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name']['value'] as String?;
    }

    debugPrint('fetchColorName: unexpected status ${response.statusCode}');
    return null;
  } on TimeoutException {
    debugPrint('fetchColorName: request timed out');
    return null;
  } catch (e) {
    debugPrint('fetchColorName: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> fetchColorScheme(
  String hexColor,
  String mode,
) async {
  final cleanHex = hexColor.length > 6 ? hexColor.substring(0, 6) : hexColor;
  final url = Uri.parse(
    'https://www.thecolorapi.com/scheme?hex=$cleanHex&mode=$mode&count=4',
  );

  try {
    final response = await http.get(url).timeout(_kTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    debugPrint('fetchColorScheme: unexpected status ${response.statusCode}');
    return null;
  } on TimeoutException {
    debugPrint('fetchColorScheme: request timed out');
    return null;
  } catch (e) {
    debugPrint('fetchColorScheme: $e');
    return null;
  }
}
