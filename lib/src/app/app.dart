import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/aqua_theme.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/controls/presentation/controls_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/monitoring/presentation/monitoring_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/sub_settings_screens.dart';
import '../features/support/presentation/support_screens.dart';
import '../features/vision/presentation/vision_screen.dart';
import '../features/wifi/presentation/wifi_wizard_screen.dart';
import 'app_controller.dart';
import 'screens.dart';

class AquaConnectApp extends ConsumerWidget {
  const AquaConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aqua Connect',
      theme: AquaTheme.light(),
      darkTheme: AquaTheme.dark(),
      themeMode: state.isDark ? ThemeMode.dark : ThemeMode.light,
      home: _AppRoot(screen: state.screen),
    );
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot({required this.screen});

  final AppScreen screen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appControllerProvider.notifier);

    Widget page;
    switch (screen) {
      case AppScreen.login:
        page = LoginScreen(onNavigate: controller.navigate);
      case AppScreen.signup:
        page = SignupScreen(onNavigate: controller.navigate);
      case AppScreen.forgotPassword:
        page = ForgotPasswordScreen(onNavigate: controller.navigate);
      case AppScreen.dashboard:
        page = DashboardScreen(
          current: screen,
          onNavigate: controller.navigate,
        );
      case AppScreen.alerts:
        page = AlertsScreen(current: screen, onNavigate: controller.navigate);
      case AppScreen.monitoring:
        page = MonitoringScreen(
          current: screen,
          onNavigate: controller.navigate,
        );
      case AppScreen.controls:
        page = ControlsScreen(current: screen, onNavigate: controller.navigate);
      case AppScreen.analytics:
        page = AnalyticsScreen(
          current: screen,
          onNavigate: controller.navigate,
        );
      case AppScreen.insights:
        page = InsightsScreen(current: screen, onNavigate: controller.navigate);
      case AppScreen.vision:
        page = VisionScreen(current: screen, onNavigate: controller.navigate);
      case AppScreen.wifi:
        page = WiFiWizardScreen(onNavigate: controller.navigate);
      case AppScreen.profile:
        page = ProfileScreen(current: screen, onNavigate: controller.navigate);
      case AppScreen.support:
        page = SupportScreen(onNavigate: controller.navigate);
      case AppScreen.settings:
        page = SettingsScreen(
          current: screen,
          onNavigate: controller.navigate,
          onToggleTheme: controller.toggleTheme,
          onToggleLanguage: controller.toggleLanguage,
        );
      case AppScreen.accountSecurity:
        page = AccountSecurityScreen(onNavigate: controller.navigate);
      case AppScreen.sensorCalibration:
        page = SensorCalibrationScreen(onNavigate: controller.navigate);
      case AppScreen.calibrationPh:
        page = PhCalibrationScreen(onNavigate: controller.navigate);
      case AppScreen.calibrationEc:
        page = EcCalibrationScreen(onNavigate: controller.navigate);
      case AppScreen.calibrationTemp:
        page = TempCalibrationScreen(onNavigate: controller.navigate);
      case AppScreen.firmwareUpdate:
        page = FirmwareUpdateScreen(onNavigate: controller.navigate);
      case AppScreen.notificationSettings:
        page = NotificationSettingsScreen(onNavigate: controller.navigate);
      case AppScreen.reports:
        // Web aliases REPORTS -> Analytics
        page = AnalyticsScreen(
          current: AppScreen.analytics,
          onNavigate: controller.navigate,
        );
      case AppScreen.more:
        page = MoreScreen(current: screen, onNavigate: controller.navigate);
    }

    return page;
  }
}
