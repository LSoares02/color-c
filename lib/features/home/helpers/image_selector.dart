// ignore_for_file: use_build_context_synchronously, file_names

import 'dart:io';
import 'package:color_c/features/image_previewer/image_previewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Opens camera/gallery, navigates to the image preview, and returns
/// the tapped color (or null if cancelled).
Future<Color?> handleImageSelection(
  BuildContext context,
  ImageSource source,
) async {
  try {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source);

    if (picked == null) return null;

    final imageFile = File(picked.path);
    final Color? selectedColor = await Navigator.push<Color?>(
      context,
      MaterialPageRoute(builder: (_) => ImagePreviewer(imageFile: imageFile)),
    );

    return selectedColor;
  } catch (e) {
    debugPrint('Error selecting image: $e');
    return null;
  }
}
