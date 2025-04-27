// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:color_c/features/image_previewer/helpers/color_extractor.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewer extends StatefulWidget {
  final File imageFile;
  const ImagePreviewer({super.key, required this.imageFile});

  @override
  State<ImagePreviewer> createState() => _ImagePreviewerState();
}

class _ImagePreviewerState extends State<ImagePreviewer> {
  final PhotoViewController _photoController = PhotoViewController();
  final PhotoViewScaleStateController _scaleStateCtrl =
      PhotoViewScaleStateController();

  Offset? _tapOnViewer;
  Offset? _tapOnImagePixels;

  double? _imageW;
  double? _imageH;
  ui.Image? _uiImage; // armazena a imagem em memória para ler pixels

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
    _photoController.addIgnorableListener(_clearTapMarker);
  }

  void _clearTapMarker() {
    if (_tapOnViewer != null) {
      setState(() {
        _tapOnViewer = null;
        _tapOnImagePixels = null;
      });
    }
  }

  @override
  void dispose() {
    _photoController.removeIgnorableListener(_clearTapMarker);
    _photoController.dispose();
    _scaleStateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadImageDimensions() async {
    final provider = FileImage(widget.imageFile);
    final completer = Completer<ImageInfo>();
    final stream = provider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((info, _) => completer.complete(info));
    stream.addListener(listener);
    final info = await completer.future;
    stream.removeListener(listener);

    setState(() {
      _imageW = info.image.width.toDouble();
      _imageH = info.image.height.toDouble();
      _uiImage = info.image;
    });
  }

  Future<void> _extractColor() async {
    if (_uiImage == null || _tapOnImagePixels == null) return;
    final result = await extractColorFromImage(_uiImage!, _tapOnImagePixels!);
    if (result == null) return;

    // retorna apenas a cor para quem chamou Navigator.push
    Navigator.pop(context, result['color'] as Color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_imageW == null || _imageH == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Preview'), centerTitle: true),
      body: LayoutBuilder(
        builder: (ctx, bc) {
          final totalH = bc.maxHeight;
          const verticalPadding = 24.0 * 2;
          const buttonArea = 56.0 + 50.0;
          final availableH = totalH - verticalPadding - buttonArea;

          final containerW = bc.maxWidth - 24.0 * 2;
          final idealH = containerW * (_imageH! / _imageW!);
          final containerH = min(idealH, availableH);

          return Column(
            children: [
              const Spacer(),
              const Text('Tap to extract color'),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  height: containerH,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        PhotoView(
                          controller: _photoController,
                          scaleStateController: _scaleStateCtrl,
                          imageProvider: FileImage(widget.imageFile),
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black12,
                          ),
                          initialScale: PhotoViewComputedScale.contained,
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 4.0,
                          gestureDetectorBehavior: HitTestBehavior.translucent,
                          onTapUp: (context, details, controllerValue) {
                            final localTap = details.localPosition;
                            final imageCoords = convertTapToImageCoordinates(
                              context: context,
                              details: details,
                              controllerValue: controllerValue,
                              imageWidth: _imageW!,
                              imageHeight: _imageH!,
                            );

                            if (imageCoords == null) return;

                            setState(() {
                              _tapOnViewer = localTap;
                              _tapOnImagePixels = imageCoords;
                            });
                          },
                        ),
                        if (_tapOnViewer != null)
                          Positioned(
                            left: _tapOnViewer!.dx - 15,
                            top: _tapOnViewer!.dy - 15,
                            child: const Icon(
                              Icons.circle_outlined,
                              size: 30,
                              color: Colors.lightBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: ElevatedButton.icon(
                  onPressed: _tapOnImagePixels != null ? _extractColor : null,
                  icon: const Icon(Icons.remove_red_eye),
                  label: Text(
                    'See Color',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          _tapOnImagePixels != null
                              ? theme.colorScheme.onPrimary
                              : null,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
