// lib/features/home/helpers/image_selector.dart
// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:io';
import 'package:color_c/features/image_previewer/image_previewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

bool _isPickingImage = false;

/// Abre câmera/galeria, navega para o preview e retorna a cor clicada (ou null).
Future<Color?> handleImageSelection(
  BuildContext context,
  ImageSource source,
) async {
  if (_isPickingImage) return null;
  _isPickingImage = true;

  try {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);

    if (picked == null) {
      debugPrint("Nenhuma imagem selecionada.");
      return null;
    }

    final imageFile = File(picked.path);
    // Aqui esperamos o push retornar a cor selecionada
    final Color? selectedColor = await Navigator.push<Color?>(
      context,
      MaterialPageRoute(builder: (_) => ImagePreviewer(imageFile: imageFile)),
    );

    debugPrint("Cor retornada do preview: $selectedColor");
    return selectedColor;
  } catch (e) {
    debugPrint("Erro ao selecionar imagem: $e");
    return null;
  } finally {
    _isPickingImage = false;
  }
}
