// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:color_c/features/home/helpers/contrast_handler.dart';
import 'package:color_c/features/image_previewer/helpers/color_extractor.dart';
import 'package:color_c/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewer extends StatefulWidget {
  final File imageFile;
  const ImagePreviewer({super.key, required this.imageFile});

  @override
  State<ImagePreviewer> createState() => _ImagePreviewerState();
}

class _ImagePreviewerState extends State<ImagePreviewer>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Tab 0 — tap-to-pick
  final PhotoViewController _photoController = PhotoViewController();
  final PhotoViewScaleStateController _scaleStateCtrl =
      PhotoViewScaleStateController();
  Offset? _tapOnViewer;
  Offset? _tapOnImagePixels;
  double? _imageW;
  double? _imageH;
  ui.Image? _uiImage;

  // Tab 1 — dominant colors (extracted lazily on first tab switch)
  List<Color>? _dominantColors;
  bool _extractionTriggered = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
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

  void _onTabChanged() {
    // indexIsChanging is true during the slide animation; we wait until it
    // settles so the spinner frame renders before extraction starts.
    if (_tabController.index == 1 &&
        !_tabController.indexIsChanging &&
        !_extractionTriggered) {
      _extractionTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDominantColors());
    }
  }

  Future<void> _loadDominantColors() async {
    // Wait for the image to finish loading if it hasn't yet.
    while (_uiImage == null && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;

    final colors = await extractDominantColors(_uiImage!, count: 8);
    if (mounted) {
      setState(() {
        _dominantColors = colors;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
    Navigator.pop(context, result['color'] as Color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = _imageW != null && _imageH != null && _uiImage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.touch_app), text: 'Pick'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'Auto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPickTab(theme, ready),
          _buildAutoTab(theme),
        ],
      ),
    );
  }

  Widget _buildPickTab(ThemeData theme, bool ready) {
    return Column(
      children: [
        const Spacer(),
        const Text('Tap anywhere on the image to extract color'),
        const Spacer(),
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    onTapUp:
                        ready
                            ? (context, details, controllerValue) {
                              final localTap = details.localPosition;
                              final imageCoords =
                                  convertTapToImageCoordinates(
                                    context: context,
                                    details: details,
                                    controllerValue: controllerValue,
                                    imageWidth: _imageW!,
                                    imageHeight: _imageH!,
                                  );
                              if (imageCoords == null) return;
                              HapticFeedback.mediumImpact();
                              setState(() {
                                _tapOnViewer = localTap;
                                _tapOnImagePixels = imageCoords;
                              });
                            }
                            : null,
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
            onPressed:
                ready && _tapOnImagePixels != null ? _extractColor : null,
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoTab(ThemeData theme) {
    // Show spinner both before extraction starts and while it's running.
    if (_dominantColors == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final colors = _dominantColors!;

    if (colors.isEmpty) {
      return const Center(child: Text('Could not extract colors.'));
    }

    const crossAxisCount = 4;
    const spacing = 6.0;
    final rowCount = (colors.length / crossAxisCount).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
        final cellHeight =
            (constraints.maxHeight - spacing * (rowCount - 1)) / rowCount;
        final childAspectRatio = cellWidth / cellHeight;

        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            final hex = colorToHex(color);
            final textColor = getTextColor(color);
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, color);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#$hex',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
