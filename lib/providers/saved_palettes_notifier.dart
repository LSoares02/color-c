import 'package:color_c/models/saved_palette.dart';
import 'package:color_c/services/palette_storage_service.dart';
import 'package:flutter/material.dart';

class SavedPalettesNotifier extends ChangeNotifier {
  final _service = PaletteStorageService();
  List<SavedPalette> _palettes = [];

  List<SavedPalette> get palettes => List.unmodifiable(_palettes);

  SavedPalettesNotifier() {
    _load();
  }

  Future<void> _load() async {
    _palettes = await _service.load();
    notifyListeners();
  }

  bool isSaved(String id) => _palettes.any((p) => p.id == id);

  static const _kMaxPalettes = 50;

  Future<void> add(SavedPalette palette) async {
    if (isSaved(palette.id)) return;
    _palettes.insert(0, palette);
    if (_palettes.length > _kMaxPalettes) {
      _palettes = _palettes.sublist(0, _kMaxPalettes);
    }
    notifyListeners();
    await _service.save(_palettes);
  }

  Future<void> remove(String id) async {
    _palettes.removeWhere((p) => p.id == id);
    notifyListeners();
    await _service.save(_palettes);
  }
}
