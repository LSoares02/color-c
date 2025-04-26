import 'package:color_c/features/home/helpers/contrast_hadler.dart';
import 'package:flutter/material.dart';

class ColorDetailsPage extends StatelessWidget {
  final Color color;
  final String colorApiName;
  final String colorDescripion;
  final Animation<double>? pageAnimation; // ⚡️ Nova propriedade!

  const ColorDetailsPage({
    super.key,
    required this.color,
    required this.colorApiName,
    required this.colorDescripion,
    this.pageAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final hex =
        color.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2)
            .toUpperCase();

    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BackButton(color: getTextColor(color)),
                  const SizedBox(height: 24),
                  Text(
                    colorApiName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: getTextColor(color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '#$hex',
                    style: TextStyle(fontSize: 24, color: getTextColor(color)),
                  ),
                  Text(
                    '($colorDescripion)',
                    style: TextStyle(fontSize: 24, color: getTextColor(color)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
