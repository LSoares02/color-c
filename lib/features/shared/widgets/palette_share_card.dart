import 'package:color_c/features/home/helpers/contrast_handler.dart';
import 'package:color_c/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A fixed 400×400 widget rendered off-screen and captured as a PNG for sharing.
class PaletteShareCard extends StatelessWidget {
  final Color baseColor;
  final String colorApiName;
  final String colorPhrase;
  final String? colorProperties;
  final List<Color> schemeColors;
  final String schemeName;

  const PaletteShareCard({
    super.key,
    required this.baseColor,
    required this.colorApiName,
    required this.colorPhrase,
    this.colorProperties,
    required this.schemeColors,
    required this.schemeName,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = getTextColor(baseColor);
    final hex = colorToHex(baseColor);

    return SizedBox(
      width: 400,
      height: 400,
      child: Stack(
        children: [
          // Solid background
          Positioned.fill(child: ColoredBox(color: baseColor)),

          // Decorative scheme-color bubbles
          if (schemeColors.isNotEmpty)
            ..._buildBubbles(schemeColors, textColor),

          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color name
                Text(
                  colorApiName,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Hex
                Text(
                  '#$hex',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 16),
                // Italic phrase
                Text(
                  colorPhrase,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: textColor.withValues(alpha: 0.9),
                  ),
                ),
                if (colorProperties != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '($colorProperties)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  schemeName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.5),
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                // Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Color C',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBubbles(List<Color> colors, Color textColor) {
    // Fixed positions for up to 4 bubbles — decorative, bottom-right quadrant
    const positions = [
      (right: 20.0, bottom: 60.0, size: 160.0),
      (right: 130.0, bottom: -30.0, size: 130.0),
      (right: -20.0, bottom: 160.0, size: 100.0),
      (right: 200.0, bottom: 40.0, size: 80.0),
    ];

    return List.generate(
      colors.length.clamp(0, positions.length),
      (i) => Positioned(
        right: positions[i].right,
        bottom: positions[i].bottom,
        child: Container(
          width: positions[i].size,
          height: positions[i].size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors[i].withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
