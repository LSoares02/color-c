import 'package:color_c/features/color_details/helpers/consequent_colors.dart';
import 'package:color_c/features/home/helpers/contrast_hadler.dart';
import 'package:color_c/features/home/widgets/ink_splash.dart';
import 'package:flutter/material.dart';

class ColorDetailsPage extends StatefulWidget {
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
  State<ColorDetailsPage> createState() => _ColorDetailsPageState();
}

class _ColorDetailsPageState extends State<ColorDetailsPage> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hex =
        widget.color.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2)
            .toUpperCase();

    final Color complementaryColor = getComplementaryColor(widget.color);
    final Color analogousColor = getAnalogousColor(widget.color);
    final Color triadicColor = getTriadicColor(widget.color);
    final Color tetradicColor = getTetradicColor(widget.color);

    final List<dynamic> colors = [
      {'type': 'C', 'color': complementaryColor},
      {'type': 'A', 'color': analogousColor},
      {'type': 'Tri', 'color': triadicColor},
      {'type': 'Tet', 'color': tetradicColor},
    ];

    return Scaffold(
      backgroundColor: widget.color,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'colorPreviewHero',
                child: Material(
                  color: widget.color,
                  child: AnimatedBuilder(
                    animation: widget.pageAnimation ?? kAlwaysCompleteAnimation,
                    builder: (context, child) {
                      final heroOpacity =
                          1.0 - (widget.pageAnimation?.value ?? 1.0);
                      return Opacity(
                        opacity: heroOpacity,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (showDetails)
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
                      const SizedBox(height: 24),
                      Text(
                        widget.colorApiName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: getTextColor(widget.color),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '#$hex',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: getTextColor(widget.color),
                        ),
                      ),
                      Text(
                        '(${widget.colorDescripion})',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: getTextColor(widget.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            showDetails
                                ? Container(
                                  width: double.infinity,
                                  key: const ValueKey('legend'),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        colors.map((color) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              '${color['type']} #${color['color'].value.toRadixString(16).substring(2).toUpperCase()}',
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: color['color'],
                                                  ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 10),
                      ElevatedButton(
                        key: const ValueKey('button'),
                        onPressed: () {
                          setState(() {
                            showDetails = !showDetails;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          '${showDetails ? 'Hide' : 'View'} Palette',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            BackButton(color: getTextColor(widget.color)),
          ],
        ),
      ),
    );
  }
}
