import 'package:color_c/api/color_api.dart';
import 'package:color_c/features/color_details/helpers/consequent_colors.dart';
import 'package:color_c/features/home/helpers/contrast_handler.dart';
import 'package:color_c/features/home/widgets/ink_splash.dart';
import 'package:color_c/models/saved_palette.dart';
import 'package:color_c/providers/saved_palettes_notifier.dart';
import 'package:color_c/utils/color_utils.dart';
import 'package:color_c/utils/share_palette.dart';
import 'package:color_c/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ColorDetailsPage extends StatefulWidget {
  final Color color;
  final String colorApiName;
  final String colorPhrase;
  final String? colorProperties;
  final Animation<double>? pageAnimation;
  final String? initialScheme;
  final List<Color>? initialSchemeColors;

  const ColorDetailsPage({
    super.key,
    required this.color,
    required this.colorApiName,
    required this.colorPhrase,
    this.colorProperties,
    this.pageAnimation,
    this.initialScheme,
    this.initialSchemeColors,
  });

  @override
  State<ColorDetailsPage> createState() => _ColorDetailsPageState();
}

class _ColorDetailsPageState extends State<ColorDetailsPage> {
  bool showDetails = false;
  String selectedScheme = 'default';
  List<Color> schemeColors = [];
  bool isLoadingScheme = false;

  String get _paletteId => '${colorToHex(widget.color)}_$selectedScheme';

  void _copyHex(String hex) {
    Clipboard.setData(ClipboardData(text: '#$hex'));
    showToast(context, message: 'Copied #$hex');
  }

  void _toggleSave() {
    final notifier = context.read<SavedPalettesNotifier>();
    final id = _paletteId;
    if (notifier.isSaved(id)) {
      notifier.remove(id);
      showToast(context, message: 'Palette removed');
    } else {
      final argb = widget.color.toARGB32();
      final opaqueBase = Color.fromARGB(
        255,
        (argb >> 16) & 0xFF,
        (argb >> 8) & 0xFF,
        argb & 0xFF,
      );
      notifier.add(
        SavedPalette(
          id: id,
          baseColor: opaqueBase,
          colorApiName: widget.colorApiName,
          schemeName: selectedScheme,
          schemeColors: List.of(schemeColors),
          savedAt: DateTime.now(),
        ),
      );
      showToast(context, message: 'Palette saved');
    }
  }

  @override
  void initState() {
    super.initState();
    _initScheme();
  }

  Future<void> _initScheme() async {
    if (widget.initialScheme != null && widget.initialSchemeColors != null) {
      setState(() {
        selectedScheme = widget.initialScheme!;
        schemeColors = widget.initialSchemeColors!;
        isLoadingScheme = false;
        showDetails = true;
      });
      return;
    }

    setState(() => isLoadingScheme = true);

    final schemeData = await fetchColorScheme(colorToHex(widget.color), 'monochrome');

    if (!mounted) return;

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
        selectedScheme = 'monochrome';
        schemeColors = colorsFromApi;
        isLoadingScheme = false;
      });
    } else {
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

  void _changeScheme() async {
    final modes = [
      'monochrome',
      'analogic',
      'complement',
      'triad',
      'quad',
      'default',
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
        colorToHex(widget.color),
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
        if (mounted) {
          showToast(context, message: 'Could not load scheme — showing local palette');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hex = colorToHex(widget.color);

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
                key: ValueKey(schemeColors.map((e) => e.toARGB32()).join('-')),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: isLoadingScheme
                                ? null
                                : () => sharePalette(
                                  context,
                                  baseColor: widget.color,
                                  colorApiName: widget.colorApiName,
                                  colorPhrase: widget.colorPhrase,
                                  colorProperties: widget.colorProperties,
                                  schemeColors: schemeColors,
                                  schemeName: selectedScheme,
                                ),
                            icon: Icon(
                              Icons.share,
                              color: getTextColor(widget.color),
                            ),
                            tooltip: 'Share palette',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Consumer<SavedPalettesNotifier>(
                            builder: (context, notifier, _) {
                              final saved = notifier.isSaved(_paletteId);
                              return IconButton(
                                onPressed: _toggleSave,
                                icon: Icon(
                                  saved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: getTextColor(widget.color),
                                ),
                                tooltip: saved
                                    ? 'Remove saved palette'
                                    : 'Save palette',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _CopyableHex(
                        hex: hex,
                        onCopy: () => _copyHex(hex),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: getTextColor(widget.color),
                        ),
                        iconColor: getTextColor(widget.color),
                      ),
                      Text(
                        widget.colorPhrase,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: getTextColor(widget.color),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (widget.colorProperties != null)
                        Text(
                          '(${widget.colorProperties})',
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
                                        color: Colors.black.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            schemeColors.map((color) {
                                              final hexCode = colorToHex(color);
                                              return GestureDetector(
                                                onTap: () => Navigator.of(context).pop(color),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                                  child: Text(
                                                    '#$hexCode',
                                                    style: theme.textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      selectedScheme.toUpperCase(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: getTextColor(widget.color),
                                      ),
                                    ),
                                    Text(
                                      'Tap a hex to select',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: getTextColor(widget.color).withValues(alpha: 0.5),
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

class _CopyableHex extends StatelessWidget {
  final String hex;
  final VoidCallback onCopy;
  final TextStyle? style;
  final Color iconColor;

  const _CopyableHex({
    required this.hex,
    required this.onCopy,
    required this.iconColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCopy,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('#$hex', style: style),
          const SizedBox(width: 6),
          Icon(
            Icons.content_copy,
            size: 14,
            color: iconColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
