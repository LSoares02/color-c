import 'dart:convert';
import 'package:color_c/models/saved_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStorageKey = 'saved_palettes';

class PaletteStorageService {
  Future<List<SavedPalette>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => SavedPalette.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<SavedPalette> palettes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(palettes.map((p) => p.toJson()).toList());
    await prefs.setString(_kStorageKey, encoded);
  }
}
