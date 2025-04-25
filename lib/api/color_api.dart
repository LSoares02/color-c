import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> fetchColorName(String hexColor) async {
  // Garante que estamos pegando apenas os 6 primeiros caracteres (RGB)
  final cleanHexColor =
      hexColor.length > 6 ? hexColor.substring(2, 8) : hexColor;

  final url = Uri.parse('https://www.thecolorapi.com/id?hex=$cleanHexColor');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name']['value'] as String?;
    } else {
      return 'Failed to load color name';
    }
  } catch (e) {
    return 'Error: $e';
  }
}
