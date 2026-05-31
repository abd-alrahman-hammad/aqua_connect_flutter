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

  /// Maps each screen to its logical parent, mirroring the onBack callbacks
  /// used by the in-app AppBar back arrows.
  static const Map<AppScreen, AppScreen> _backRoutes = {
    // Main sections → Dashboard
    AppScreen.controls: AppScreen.dashboard,
    AppScreen.vision: AppScreen.dashboard,
    AppScreen.alerts: AppScreen.dashboard,
    AppScreen.more: AppScreen.dashboard,

    // More sub-screens → More
    AppScreen.analytics: AppScreen.more,
    AppScreen.insights: AppScreen.more,
    AppScreen.support: AppScreen.more,
    AppScreen.reports: AppScreen.more,
    
    // Settings sub-screens → Settings
    AppScreen.profile: AppScreen.settings,
    AppScreen.accountSecurity: AppScreen.settings,
    AppScreen.thresholds: AppScreen.settings,
    AppScreen.notificationSettings: AppScreen.settings,

    // Onboarding flow
    AppScreen.deviceList: AppScreen.addDevice,
    AppScreen.wifiInstructions: AppScreen.deviceList,
    AppScreen.qrInstructions: AppScreen.wifiInstructions,
    AppScreen.deviceScanQr: AppScreen.qrInstructions,
    AppScreen.deviceManualEntry: AppScreen.deviceScanQr,
    AppScreen.deviceScanError: AppScreen.deviceScanQr,
    AppScreen.userDevices: AppScreen.addDevice,
    AppScreen.contactUs: AppScreen.more,

    // Auth flow
    AppScreen.signup: AppScreen.login,
    AppScreen.forgotPassword: AppScreen.login,
  };

  /// Returns true if the current screen has a back route defined.
  bool get canGoBack => _backRoutes.containsKey(state.screen);

  /// Navigate back to the parent screen (same behaviour as the in-app back arrow).
  void goBack() {
    final parent = _backRoutes[state.screen];
    if (parent != null) {
      state = state.copyWith(screen: parent);
    }
  }

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
