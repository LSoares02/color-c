import 'package:color_c/features/color_details/helpers/consequent_colors.dart';
import 'package:color_c/features/home/helpers/contrast_hadler.dart';
import 'package:color_c/features/home/widgets/ink_splash.dart';
import 'package:flutter/material.dart';

class ColorDetailsPage extends StatelessWidget {
  final Color color;
  final String colorApiName;
  final String colorDescripion;
  final Animation<double>? pageAnimation;

  const ColorDetailsPage({
    super.key,
    required this.color,
    required this.colorApiName,
    required this.colorDescripion,
    this.pageAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hex =
        color.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2)
            .toUpperCase();

    final Color complementaryColor = getComplementaryColor(color);
    final Color analogousColor = getAnalogousColor(color);
    final Color triadicColor = getTriadicColor(color);
    final Color tetradicColor = getTetradicColor(color);

    final List<dynamic> colors = [
      {'type': 'C', 'color': complementaryColor},
      {'type': 'A', 'color': analogousColor},
      {'type': 'Tri', 'color': triadicColor},
      {'type': 'Tet', 'color': tetradicColor},
    ];

    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'colorPreviewHero',
                child: Material(
                  color: color,
                  child: AnimatedBuilder(
                    animation: pageAnimation ?? kAlwaysCompleteAnimation,
                    builder: (context, child) {
                      // Inverte a opacidade do Hero conforme a página aparece
                      final heroOpacity = 1.0 - (pageAnimation?.value ?? 1.0);
                      return Opacity(
                        opacity: heroOpacity,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            InkSplashes(
              customColors: [
                complementaryColor,
                analogousColor,
                triadicColor,
                tetradicColor,
              ],
              splashOpacity: 1.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BackButton(color: getTextColor(color)),
                      const SizedBox(height: 24),
                      Text(
                        colorApiName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: getTextColor(color),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '#$hex',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: getTextColor(color),
                        ),
                      ),
                      Text(
                        '($colorDescripion)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: getTextColor(color),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(), // <- Isso empurra a legenda pro final
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Fundo semi-transparente
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          colors.map((color) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${color['type']} #${color['color'].value.toRadixString(16).substring(2).toUpperCase()}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: color['color'],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
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
