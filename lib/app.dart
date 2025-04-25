import 'package:color_c/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'features/home/home_screen.dart';

class ColorCApp extends StatelessWidget {
  const ColorCApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'Color-C',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(themeNotifier.seedColor),
      darkTheme: AppTheme.darkTheme(themeNotifier.seedColor),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
