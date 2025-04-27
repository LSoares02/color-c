import 'package:color_c/features/home/helpers/color_describer.dart';
import 'package:color_c/features/home/helpers/contrast_hadler.dart';
import 'package:flutter/material.dart';
import 'package:color_c/api/color_api.dart';
import 'package:color_c/features/color_details/color_details.dart'; // Importa a nova tela

class ColorPreviewContainer extends StatefulWidget {
  final Color? detectedColor;

  const ColorPreviewContainer({super.key, this.detectedColor});

  @override
  ColorPreviewContainerState createState() => ColorPreviewContainerState();
}

class ColorPreviewContainerState extends State<ColorPreviewContainer> {
  String? _colorName;

  @override
  void didUpdateWidget(covariant ColorPreviewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.detectedColor != oldWidget.detectedColor) {
      if (widget.detectedColor != null) {
        final hexColor =
            widget.detectedColor!.value
                .toRadixString(16)
                .substring(2)
                .toUpperCase();
        fetchColorName(hexColor).then((name) {
          if (mounted) {
            setState(() {
              _colorName = name;
            });
          }
        });
      } else {
        setState(() {
          _colorName = null;
        });
      }
    }
  }

  void _navigateToColorDetails() {
    if (widget.detectedColor == null || _colorName == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ColorDetailsPage(
            color: widget.detectedColor!,
            colorApiName: _colorName ?? 'Unknown',
            colorDescripion:
                widget.detectedColor != null
                    ? (describeColor(widget.detectedColor) ?? 'Unknown')
                    : 'Unknown',
            pageAnimation: animation, // ⚡️ Passa a animation pra página!
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.linear;

          // Animação da opacidade começando em 30%
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.8, 1.0, curve: curve),
          );

          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hexColor =
        widget.detectedColor != null
            ? widget.detectedColor!.value
                .toRadixString(16)
                .substring(2)
                .toUpperCase()
            : '-';

    return GestureDetector(
      onTap: _navigateToColorDetails,
      child: Hero(
        tag: 'colorPreviewHero',
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: widget.detectedColor ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _colorName != null
                    ? '$_colorName\n#$hexColor\n(${describeColor(widget.detectedColor)})'
                    : 'Color will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      widget.detectedColor != null
                          ? getTextColor(widget.detectedColor!)
                          : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                _colorName != null ? 'Click for details' : '(Select an image)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      widget.detectedColor != null
                          ? getTextColor(widget.detectedColor!)
                          : theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
