import 'package:flutter/material.dart';

class RayyanColors {
  // Tailwind config from `index.html`
  static const primary = Color(0xFF38A254); // Nature Green
  static const rayyan = Color(0xFF00AEEF); // Rayyan Blue
  static const primaryDark = Color(0xFF26703A);

  static const backgroundLight = Color(0xFFF7F8F6);
  static const backgroundDark = Color(0xFF182012);
  static const cardDark = Color(0xFF1E291D);
  static const surfaceDark = Color(0xFF2A3628);

  static const critical = Color(0xFFFF4D4D);
  static const error = critical; // Alias
  static const warning = Color(0xFFFFA500);
  static const info = rayyan;
  static const nature = primary;
  static const success = nature; // Alias

  static const slate900 = Color(0xFF0F172A);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);

  // Vision screen specific AI analysis colors
  static const visionGradientTop = Color(0xFF4C6B2A);
  static const visionGradientMid = Color(0xFF2A3D16);
  static const visionGradientBottom = Color(0xFF131C0A);

  static const visionHistoryHealthy1 = Color(0xFF386821);
  static const visionHistoryUnderwatered = Color(0xFF141A14);
  static const visionHistoryHealthy2 = Color(0xFF4A3824);
}
