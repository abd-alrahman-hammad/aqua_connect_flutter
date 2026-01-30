import 'dart:ui';

import 'package:flutter/material.dart';

class BlurCircle extends StatelessWidget {
  const BlurCircle({
    super.key,
    required this.diameter,
    required this.color,
    this.opacity = 0.10,
  });

  final double diameter;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
