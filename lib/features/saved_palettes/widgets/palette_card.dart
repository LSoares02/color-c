import 'package:color_c/features/home/helpers/contrast_handler.dart';
import 'package:color_c/models/saved_palette.dart';
import 'package:color_c/utils/color_utils.dart';
import 'package:flutter/material.dart';

class PaletteCard extends StatelessWidget {
  final SavedPalette palette;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaletteCard({
    super.key,
    required this.palette,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = getTextColor(palette.baseColor);
    final hex = colorToHex(palette.baseColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: palette.baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        palette.colorApiName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#$hex',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.bookmark, color: textColor),
                  tooltip: 'Remove',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Scheme color swatches
            Row(
              children: [
                ...palette.schemeColors.map(
                  (c) => Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(color: c),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  palette.schemeName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Tap to use',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
