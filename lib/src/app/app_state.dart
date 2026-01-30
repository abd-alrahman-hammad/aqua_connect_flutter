import 'package:flutter/foundation.dart';

import 'screens.dart';

@immutable
class AppState {
  const AppState({
    required this.screen,
    required this.isDark,
    required this.languageCode,
  });

  final AppScreen screen;
  final bool isDark;
  final String languageCode; // "EN" / "AR" (mirrors web toggle)

  AppState copyWith({AppScreen? screen, bool? isDark, String? languageCode}) {
    return AppState(
      screen: screen ?? this.screen,
      isDark: isDark ?? this.isDark,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
