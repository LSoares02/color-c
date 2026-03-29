import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:color_c/features/shared/widgets/palette_share_card.dart';
import 'package:color_c/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';


Future<void> sharePalette(
  BuildContext context, {
  required Color baseColor,
  required String colorApiName,
  required String colorPhrase,
  String? colorProperties,
  required List<Color> schemeColors,
  required String schemeName,
}) async {
  final hex = colorToHex(baseColor);
  final boundaryKey = GlobalKey();

  // Use Positioned off-screen (not Offstage) so Flutter actually paints the widget.
  // Offstage skips painting, which causes toImage() to fail with debugNeedsPaint.
  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      left: -10000,
      top: -10000,
      width: 400,
      height: 400,
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(
          key: boundaryKey,
          child: PaletteShareCard(
            baseColor: baseColor,
            colorApiName: colorApiName,
            colorPhrase: colorPhrase,
            colorProperties: colorProperties,
            schemeColors: schemeColors,
            schemeName: schemeName,
          ),
        ),
      ),
    ),
  );

  final overlay = Navigator.of(context, rootNavigator: true).overlay!;
  overlay.insert(overlayEntry);

  // Wait for the full build → layout → paint cycle to complete
  await WidgetsBinding.instance.endOfFrame;

  Uint8List? pngBytes;
  try {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    pngBytes = byteData?.buffer.asUint8List();
  } finally {
    overlayEntry.remove();
  }

  if (pngBytes == null) return;

  final tmpDir = Directory.systemTemp;
  final file = File(
    '${tmpDir.path}/color_c_${hex}_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(pngBytes);

  final shareText =
      '🎨 $colorApiName — #$hex\n\n'
      'https://www.thecolorapi.com/id?hex=$hex&format=html\n\n'
      'Color C on Google Play\n'
      'https://play.google.com/store/apps/details?id=com.lsoares02.color_c';

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: shareText,
    ),
  );
}
