import 'package:color_c/api/color_api.dart';
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
  String selectedScheme = 'default';
  List<Color> schemeColors = [];
  bool isLoadingScheme = false;

  @override
  void initState() {
    super.initState();
    // Inicializa com as cores locais
    schemeColors = [
      getComplementaryColor(widget.color),
      getAnalogousColor(widget.color),
      getTriadicColor(widget.color),
      getTetradicColor(widget.color),
    ];
  }

  void _changeScheme() async {
    final modes = [
      'default',
      'monochrome',
      'analogic',
      'complement',
      'triad',
      'quad',
    ];
    final currentIndex = modes.indexOf(selectedScheme);
    final nextIndex = (currentIndex + 1) % modes.length;
    final nextMode = modes[nextIndex];

    setState(() {
      isLoadingScheme = true;
    });

    if (nextMode == 'default') {
      setState(() {
        selectedScheme = nextMode;
        schemeColors = [
          getComplementaryColor(widget.color),
          getAnalogousColor(widget.color),
          getTriadicColor(widget.color),
          getTetradicColor(widget.color),
        ];
        isLoadingScheme = false;
      });
    } else {
      final schemeData = await fetchColorScheme(
        widget.color.value.toRadixString(16).substring(2, 8),
        nextMode,
      );

      if (schemeData != null) {
        final colorsFromApi =
            (schemeData['colors'] as List)
                .map(
                  (item) => Color(
                    int.parse(item['hex']['clean'], radix: 16) + 0xFF000000,
                  ),
                )
                .toList();

        setState(() {
          selectedScheme = nextMode;
          schemeColors = colorsFromApi;
          isLoadingScheme = false;
        });
      } else {
        // Se a API falhar, use as cores locais
        setState(() {
          selectedScheme = 'default';
          schemeColors = [
            getComplementaryColor(widget.color),
            getAnalogousColor(widget.color),
            getTriadicColor(widget.color),
            getTetradicColor(widget.color),
          ];
          isLoadingScheme = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hex =
        widget.color.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2)
            .toUpperCase();

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
                key: ValueKey(schemeColors.map((e) => e.value).join('-')),
                customColors: schemeColors,
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
                                ? Column(
                                  key: const ValueKey('legend'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            schemeColors.map((color) {
                                              final hexCode =
                                                  color.value
                                                      .toRadixString(16)
                                                      .substring(2)
                                                      .toUpperCase();
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                    ),
                                                child: Text(
                                                  '#$hexCode',
                                                  style: theme
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: color,
                                                      ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      selectedScheme.toUpperCase(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: getTextColor(widget.color),
                                          ),
                                    ),
                                  ],
                                )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            key: const ValueKey('button'),
                            onPressed:
                                isLoadingScheme
                                    ? null
                                    : () {
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child:
                                showDetails
                                    ? ElevatedButton(
                                      key: const ValueKey('seeSuggestions'),
                                      onPressed:
                                          isLoadingScheme
                                              ? null
                                              : _changeScheme,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                      ),
                                      child:
                                          isLoadingScheme
                                              ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        theme
                                                            .colorScheme
                                                            .onPrimary,
                                                      ),
                                                ),
                                              )
                                              : Text(
                                                'Schemes',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onPrimary,
                                                    ),
                                              ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
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
