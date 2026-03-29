import 'package:color_c/api/color_api.dart';
import 'package:color_c/features/color_details/color_details.dart';
import 'package:color_c/features/home/helpers/color_describer.dart';
import 'package:color_c/features/home/helpers/contrast_handler.dart';
import 'package:color_c/utils/color_utils.dart';
import 'package:color_c/utils/toast.dart';
import 'package:flutter/material.dart';

class ColorPreviewContainer extends StatefulWidget {
  final Color? detectedColor;
  final VoidCallback? onEmptyTap;
  final ValueChanged<Color>? onColorSelected;

  const ColorPreviewContainer({
    super.key,
    this.detectedColor,
    this.onEmptyTap,
    this.onColorSelected,
  });

  @override
  ColorPreviewContainerState createState() => ColorPreviewContainerState();
}

class ColorPreviewContainerState extends State<ColorPreviewContainer> {
  String? _colorName;
  bool _isLoadingName = false;
  bool _nameFetchFailed = false;

  @override
  void didUpdateWidget(covariant ColorPreviewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.detectedColor != oldWidget.detectedColor) {
      if (widget.detectedColor != null) {
        _fetchColorName(widget.detectedColor!);
      } else {
        setState(() {
          _colorName = null;
          _isLoadingName = false;
          _nameFetchFailed = false;
        });
      }
    }
  }

  Future<void> _fetchColorName(Color color) async {
    if (!mounted) return;
    clearToast(context);
    setState(() {
      _isLoadingName = true;
      _nameFetchFailed = false;
      _colorName = null;
    });

    final name = await fetchColorName(colorToHex(color));

    if (!mounted) return;
    if (name != null) {
      setState(() {
        _colorName = name;
        _isLoadingName = false;
      });
    } else {
      setState(() {
        _isLoadingName = false;
        _nameFetchFailed = true;
      });
      showToast(
        context,
        message: 'Could not fetch color name',
        actionLabel: 'Retry',
        onAction: () => _fetchColorName(color),
      );
    }
  }

  Future<void> _navigateToColorDetails() async {
    if (widget.detectedColor == null) {
      widget.onEmptyTap?.call();
      return;
    }
    if (_isLoadingName) return;

    clearToast(context);
    final result = await Navigator.of(context).push<Color?>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ColorDetailsPage(
            color: widget.detectedColor!,
            colorApiName: _colorName ?? colorToHex(widget.detectedColor!),
            colorDescripion: describeColor(widget.detectedColor) ?? 'Unknown',
            pageAnimation: animation,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.8, 1.0, curve: Curves.linear),
          );
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      ),
    );
    if (result != null && mounted) {
      widget.onColorSelected?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hexColor =
        widget.detectedColor != null ? colorToHex(widget.detectedColor!) : '-';

    final textColor =
        widget.detectedColor != null
            ? getTextColor(widget.detectedColor!)
            : theme.colorScheme.onSurfaceVariant;

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
          child: _buildContent(theme, hexColor, textColor),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, String hexColor, Color textColor) {
    if (widget.detectedColor == null) {
      return _buildPlaceholder(theme);
    }

    if (_isLoadingName) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (_nameFetchFailed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '#$hexColor',
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap for details',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$_colorName\n#$hexColor\n(${describeColor(widget.detectedColor)})',
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Tap for details',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Color will appear here',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          '(Select an image)',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
