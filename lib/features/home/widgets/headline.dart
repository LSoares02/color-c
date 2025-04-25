import 'dart:async';
import 'package:flutter/material.dart';

class ColorCHeadline extends StatefulWidget {
  const ColorCHeadline({super.key});

  @override
  State<ColorCHeadline> createState() => _ColorCHeadlineState();
}

class _ColorCHeadlineState extends State<ColorCHeadline>
    with SingleTickerProviderStateMixin {
  final List<String> phrases = [
    "See the color",
    "Explore the spectrum",
    "Feel the color",
    "Find your shade",
    "Sense the color",
    "Make colors speak",
    "Name the color",
    "Colors, now visible",
    "Catch the color",
    "Colors for all",
  ];

  int phraseIndex = 0;
  String displayedText = '';
  int charIndex = 0;

  Timer? typewriterTimer;
  Timer? phraseChangeTimer;

  late final AnimationController _cursorController;
  late final Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _cursorOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );

    startTyping();
  }

  void startTyping() {
    final currentPhrase = phrases[phraseIndex];
    typewriterTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (charIndex < currentPhrase.length) {
        setState(() {
          displayedText += currentPhrase[charIndex];
          charIndex++;
        });
      } else {
        timer.cancel();
        phraseChangeTimer = Timer(const Duration(seconds: 4), () {
          setState(() {
            phraseIndex = (phraseIndex + 1) % phrases.length;
            displayedText = '';
            charIndex = 0;
            startTyping();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    typewriterTimer?.cancel();
    phraseChangeTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(displayedText, style: theme.textTheme.bodyLarge),
        AnimatedBuilder(
          animation: _cursorOpacity,
          builder:
              (context, child) => Opacity(
                opacity: _cursorOpacity.value,
                child: Text('|', style: theme.textTheme.bodyLarge),
              ),
        ),
      ],
    );
  }
}
