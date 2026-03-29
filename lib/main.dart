import 'package:color_c/providers/saved_palettes_notifier.dart';
import 'package:color_c/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SavedPalettesNotifier()),
      ],
      child: const ColorCApp(),
    ),
  );
}
