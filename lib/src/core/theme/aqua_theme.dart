import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'aqua_colors.dart';

class AquaTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AquaColors.primary,
        secondary: AquaColors.aqua,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AquaColors.backgroundLight,
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: AquaColors.slate900,
        displayColor: AquaColors.slate900,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AquaColors.primary,
        secondary: AquaColors.aqua,
        surface: AquaColors.cardDark,
      ),
      scaffoldBackgroundColor: AquaColors.backgroundDark,
    );

    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(
        base.textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
    );
  }
}
