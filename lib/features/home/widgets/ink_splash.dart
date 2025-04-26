import 'dart:math';
import 'package:flutter/material.dart';

class InkSplashes extends StatefulWidget {
  const InkSplashes({super.key});

  @override
  State<InkSplashes> createState() => _InkSplashesState();
}

class _InkSplashesState extends State<InkSplashes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<_Splash> _splashes = [];
  final Random _random = Random();

  bool _isFadingOut = false;
  bool _floatingActive = true; // <- Controle do floating

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateBlots();
      _controller.forward();
      _startFloating();
    });
  }

  void _startFloating() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));

      if (mounted && !_isFadingOut && _floatingActive) {
        setState(() {
          _splashes =
              _splashes.map((splash) {
                final dx = (_random.nextDouble() - 0.5) * 10;
                final dy = (_random.nextDouble() - 0.5) * 10;
                return splash.copyWith(
                  top: splash.top + dy,
                  left: splash.left + dx,
                );
              }).toList();
        });
      }

      return mounted;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshBlots();
  }

  Future<void> _refreshBlots() async {
    _isFadingOut = true;
    _floatingActive = false; // <- Pausa floating enquanto faz fade

    await _controller.reverse(); // Fade-out

    if (mounted) {
      setState(() {
        _generateBlots(); // Gera novos splashes
      });
    }

    _isFadingOut = false;
    await _controller.forward(); // Fade-in

    _floatingActive = true; // <- Retoma floating só depois do fade-in
  }

  void _generateBlots() {
    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
    ];

    final size = MediaQuery.of(context).size;

    const int maxAttempts = 30;
    const int numberOfSplashes = 4;
    List<_Splash> generated = [];

    for (int i = 0; i < numberOfSplashes; i++) {
      int attempts = 0;
      bool placed = false;

      while (!placed && attempts < maxAttempts) {
        final diameter = _random.nextDouble() * 150 + 100;
        final top = _random.nextDouble() * (size.height - diameter);
        final left = _random.nextDouble() * (size.width - diameter);
        final color = colors[i % colors.length].withValues(alpha: 0.3);

        final newSplash = _Splash(
          color: color,
          top: top,
          left: left,
          diameter: diameter,
        );

        bool overlaps = generated.any((s) => _overlaps(s, newSplash));

        if (!overlaps) {
          generated.add(newSplash);
          placed = true;
        }

        attempts++;
      }
    }

    _splashes =
        generated; // <- só atualiza a lista (sem precisar novo setState aqui)
  }

  bool _overlaps(_Splash a, _Splash b) {
    final centerA = Offset(a.left + a.diameter / 2, a.top + a.diameter / 2);
    final centerB = Offset(b.left + b.diameter / 2, b.top + b.diameter / 2);
    final distance = (centerA - centerB).distance;
    return distance < (a.diameter + b.diameter) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children:
            _splashes.map((blot) {
              return AnimatedPositioned(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                top: blot.top,
                left: blot.left,
                child: Container(
                  width: blot.diameter,
                  height: blot.diameter,
                  decoration: BoxDecoration(
                    color: blot.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Splash {
  final Color color;
  final double top;
  final double left;
  final double diameter;

  _Splash({
    required this.color,
    required this.top,
    required this.left,
    required this.diameter,
  });

  _Splash copyWith({double? top, double? left}) {
    return _Splash(
      color: color,
      top: top ?? this.top,
      left: left ?? this.left,
      diameter: diameter,
    );
  }
}
