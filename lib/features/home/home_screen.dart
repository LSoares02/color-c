// ignore_for_file: use_build_context_synchronously

import 'package:color_c/features/home/helpers/image_selector.dart';
import 'package:color_c/features/home/widgets/headline.dart';
import 'package:color_c/features/home/widgets/ink_splash.dart';
import 'package:color_c/features/home/widgets/preview_container.dart';
import 'package:color_c/features/info_page/info_page.dart';
import 'package:color_c/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color? _detectedColor;
  bool _isPickingImage = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final color = await handleImageSelection(context, source);
      if (color != null) {
        setState(() => _detectedColor = color);
        context.read<ThemeNotifier>().updateColor(color);
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Widget _buildPickButton({
    required ImageSource source,
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: _isPickingImage ? null : () => _pickImage(source),
      icon: Icon(icon, color: theme.colorScheme.onPrimary),
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'Color-C',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 12),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const InfoPage()),
                );
              },
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const InkSplashes(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 32),
                const ColorCHeadline(key: ValueKey('headline')),
                const SizedBox(height: 24),
                ColorPreviewContainer(detectedColor: _detectedColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_detectedColor == null) ...[
                      _buildPickButton(
                        source: ImageSource.camera,
                        icon: Icons.camera_alt,
                        label: 'Camera',
                      ),
                      _buildPickButton(
                        source: ImageSource.gallery,
                        icon: Icons.photo,
                        label: 'Upload',
                      ),
                    ] else ...[
                      SizedBox(
                        width: 300,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _detectedColor = null);
                            context.read<ThemeNotifier>().updateColor(
                              Colors.blue,
                            );
                          },
                          icon: Icon(
                            Icons.clear,
                            color: theme.colorScheme.onPrimary,
                          ),
                          label: Text(
                            'Clear',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
