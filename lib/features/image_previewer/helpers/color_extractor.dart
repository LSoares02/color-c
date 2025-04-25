// lib/helpers/color_utils.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

Future<Map<String, dynamic>?> extractColorFromImage(
  ui.Image image,
  Offset pixelPosition,
) async {
  final x = pixelPosition.dx.round().clamp(0, image.width - 1);
  final y = pixelPosition.dy.round().clamp(0, image.height - 1);

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return null;

  final bytes = byteData.buffer.asUint8List();
  final index = (y * image.width + x) * 4;

  final r = bytes[index];
  final g = bytes[index + 1];
  final b = bytes[index + 2];
  final a = bytes[index + 3];

  final color = Color.fromARGB(a, r, g, b);
  final hex =
      '#'
              '${a.toRadixString(16).padLeft(2, '0')}'
              '${r.toRadixString(16).padLeft(2, '0')}'
              '${g.toRadixString(16).padLeft(2, '0')}'
              '${b.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();

  return {'color': color, 'hex': hex};
}

Offset? convertTapToImageCoordinates({
  required BuildContext context,
  required TapUpDetails details,
  required PhotoViewControllerValue controllerValue,
  required double imageWidth,
  required double imageHeight,
}) {
  final localTap = details.localPosition;
  final scale = controllerValue.scale!;
  final offset = controllerValue.position;

  final size = (context.findRenderObject() as RenderBox).size;

  final centeredTap = localTap - Offset(size.width / 2, size.height / 2);
  final unscaled = (centeredTap - offset) / scale;
  final imgX = unscaled.dx + (imageWidth / 2);
  final imgY = unscaled.dy + (imageHeight / 2);

  return Offset(imgX, imgY);
}
