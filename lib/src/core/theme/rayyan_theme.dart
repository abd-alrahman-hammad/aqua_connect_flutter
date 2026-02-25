import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'rayyan_colors.dart';

class RayyanTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: RayyanColors.primary,
        secondary: RayyanColors.rayyan,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: RayyanColors.backgroundLight,
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: RayyanColors.slate900,
        displayColor: RayyanColors.slate900,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: RayyanColors.primary,
        secondary: RayyanColors.rayyan,
        surface: RayyanColors.cardDark,
      ),
      scaffoldBackgroundColor: RayyanColors.backgroundDark,
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(
        base.textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    );
  }
}
