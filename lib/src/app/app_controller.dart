import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'screens.dart';

final appControllerProvider = StateNotifierProvider<AppController, AppState>((
  ref,
) {
  return AppController(
    const AppState(screen: AppScreen.splash, isDark: true, languageCode: 'EN'),
  );
});

class AppController extends StateNotifier<AppState> {
  AppController(super.state);

  void navigate(AppScreen screen) {
    state = state.copyWith(screen: screen);
  }

  void toggleTheme() {
    state = state.copyWith(isDark: !state.isDark);
  }

  void toggleLanguage() {
    state = state.copyWith(
      languageCode: state.languageCode == 'EN' ? 'AR' : 'EN',
    );
  }
}
