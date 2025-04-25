import 'package:flutter/material.dart';
import 'package:color_c/api/color_api.dart';

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

    // Verifica se a cor foi alterada e se é não nula
    if (widget.detectedColor != oldWidget.detectedColor) {
      if (widget.detectedColor != null) {
        final hexColor =
            widget.detectedColor!.value
                .toRadixString(16)
                .padLeft(8, '0')
                .toUpperCase();
        fetchColorName(hexColor).then((name) {
          setState(() {
            _colorName = name;
          });
        });
      } else {
        setState(() {
          _colorName = null; // Se a cor for null, limpa o nome da cor
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Garantir que não estamos tentando acessar widget.detectedColor!.value se for null
    final hexColor =
        widget.detectedColor != null
            ? widget.detectedColor!.value
                .toRadixString(16)
                .padLeft(8, '0')
                .toUpperCase()
            : '-';

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: widget.detectedColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      alignment: Alignment.center,
      child: Text(
        _colorName != null
            ? '$_colorName\n#$hexColor'
            : 'Color will appear here',
        style: theme.textTheme.bodyMedium?.copyWith(
          color:
              widget.detectedColor != null
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
