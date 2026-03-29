import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// ---------------------------------------------------------------------------
// Tap-to-pick helpers (unchanged)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Dominant color extraction — runs heavy work in a background isolate
// ---------------------------------------------------------------------------

// Top-level so compute() can send it to an isolate.
List<int> _bucketExtractColors(List<Object> args) {
  final bytes = args[0] as Uint8List;
  final width = args[1] as int;
  final height = args[2] as int;
  final count = args[3] as int;

  // Quantise each channel into 8 buckets (step = 32).
  // Key encodes the three bucket indices as a 9-bit integer.
  const step = 32;
  final freq = <int, int>{};

  // Sample every 3rd pixel — plenty of data, much less work.
  for (int y = 0; y < height; y += 3) {
    for (int x = 0; x < width; x += 3) {
      final i = (y * width + x) * 4;
      if (i + 3 >= bytes.length) continue;
      if (bytes[i + 3] < 200) continue; // skip near-transparent pixels

      final ri = bytes[i] ~/ step;
      final gi = bytes[i + 1] ~/ step;
      final bi = bytes[i + 2] ~/ step;
      final key = (ri << 6) | (gi << 3) | bi;
      freq[key] = (freq[key] ?? 0) + 1;
    }
  }

  final sorted = freq.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(count).map((e) {
    // Convert bucket index back to a representative mid-point colour.
    final ri = (e.key >> 6) & 0x7;
    final gi = (e.key >> 3) & 0x7;
    final bi = e.key & 0x7;
    final r = ri * step + step ~/ 2;
    final g = gi * step + step ~/ 2;
    final b = bi * step + step ~/ 2;
    return 0xFF000000 | (r << 16) | (g << 8) | b;
  }).toList();
}

/// Extracts up to [count] dominant colours from an already-decoded [ui.Image].
/// The CPU-intensive bucketing runs in a background isolate so the UI stays
/// responsive and the spinner animation keeps playing.
Future<List<Color>> extractDominantColors(
  ui.Image image, {
  int count = 8,
}) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return [];

  final bytes = byteData.buffer.asUint8List();
  final colorInts = await compute(
    _bucketExtractColors,
    [bytes, image.width, image.height, count],
  );

  return colorInts.map((v) => Color(v)).toList();
}
