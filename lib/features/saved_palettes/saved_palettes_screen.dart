import 'package:color_c/features/color_details/color_details.dart';
import 'package:color_c/features/home/helpers/color_describer.dart'
    show guessColorName, colorProperties;
import 'package:color_c/features/saved_palettes/widgets/palette_card.dart';
import 'package:color_c/models/saved_palette.dart';
import 'package:color_c/providers/saved_palettes_notifier.dart';
import 'package:color_c/utils/share_palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedPalettesScreen extends StatelessWidget {
  const SavedPalettesScreen({super.key});

  void _share(BuildContext context, SavedPalette palette) {
    sharePalette(
      context,
      baseColor: palette.baseColor,
      colorApiName: palette.colorApiName,
      colorPhrase: guessColorName(palette.baseColor),
      colorProperties: colorProperties(palette.baseColor),
      schemeColors: palette.schemeColors,
      schemeName: palette.schemeName,
    );
  }

  Future<void> _openDetails(BuildContext context, SavedPalette palette) async {
    final color = await Navigator.of(context).push<Color?>(
      MaterialPageRoute(
        builder: (_) => ColorDetailsPage(
          color: palette.baseColor,
          colorApiName: palette.colorApiName,
          colorPhrase: guessColorName(palette.baseColor),
          colorProperties: colorProperties(palette.baseColor),
          initialScheme: palette.schemeName,
          initialSchemeColors: palette.schemeColors,
        ),
      ),
    );
    if (color != null && context.mounted) {
      Navigator.of(context).pop(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        centerTitle: true,
      ),
      body: Consumer<SavedPalettesNotifier>(
        builder: (context, notifier, _) {
          final palettes = notifier.palettes;

          if (palettes.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            itemCount: palettes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final palette = palettes[index];
              return Dismissible(
                key: ValueKey(palette.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => notifier.remove(palette.id),
                child: PaletteCard(
                  palette: palette,
                  onTap: () => _openDetails(context, palette),
                  onDelete: () => notifier.remove(palette.id),
                  onShare: () => _share(context, palette),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved palettes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a color\'s details, view its palette\nand tap the bookmark to save it.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
