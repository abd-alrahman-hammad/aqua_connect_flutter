import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rayyan/src/features/alerts/presentation/alerts_screen.dart';

import '../../l10n/generated/app_localizations.dart';
import '../core/theme/rayyan_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/localization/locale_provider.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/controls/presentation/controls_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/insights/presentation/insights_screen.dart';

import '../features/more/presentation/more_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/sub_settings_screens.dart';
import '../features/support/presentation/support_screens.dart';
import '../features/vision/presentation/vision_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/onboarding/presentation/add_device_screen.dart';
import '../features/onboarding/presentation/device_list_screen.dart';
import '../features/onboarding/presentation/wifi_instructions_screen.dart';
import '../features/onboarding/presentation/qr_instructions_screen.dart';
import '../features/onboarding/presentation/device_scan_qr_screen.dart';
import '../features/onboarding/presentation/device_manual_entry_screen.dart';
import '../features/onboarding/presentation/device_scan_error_screen.dart';
import '../features/onboarding/presentation/user_devices_screen.dart';
import 'app_controller.dart';
import 'screens.dart';

class RayyanApp extends ConsumerWidget {
  const RayyanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final themeMode = ref.watch(themeProvider);

    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rayyan',
      theme: RayyanTheme.light(),
      darkTheme: RayyanTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
      case AppScreen.splash:
        page = SplashScreen(onNavigate: controller.navigate);
      case AppScreen.welcome:
        page = WelcomeScreen(onNavigate: controller.navigate);
      case AppScreen.addDevice:
        page = AddDeviceScreen(onNavigate: controller.navigate);
      case AppScreen.deviceList:
        page = DeviceListScreen(onNavigate: controller.navigate);
      case AppScreen.wifiInstructions:
        page = WifiInstructionsScreen(onNavigate: controller.navigate);
      case AppScreen.qrInstructions:
        page = QrInstructionsScreen(onNavigate: controller.navigate);
      case AppScreen.deviceScanQr:
        page = DeviceScanQrScreen(onNavigate: controller.navigate);
      case AppScreen.deviceManualEntry:
        page = DeviceManualEntryScreen(onNavigate: controller.navigate);
      case AppScreen.deviceScanError:
        page = DeviceScanErrorScreen(onNavigate: controller.navigate);
      case AppScreen.login:
        page = LoginScreen(onNavigate: controller.navigate);
      case AppScreen.signup:
        page = const SignupScreen();
      case AppScreen.forgotPassword:
        page = const ForgotPasswordScreen();
      case AppScreen.dashboard:
        page = DashboardScreen(
          current: screen,
          onNavigate: controller.navigate,
        );
      case AppScreen.alerts:
        page = AlertsScreen(current: screen, onNavigate: controller.navigate);

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
      case AppScreen.profile:
        page = ProfileScreen(current: screen, onNavigate: controller.navigate);
      case AppScreen.support:
        page = SupportScreen(onNavigate: controller.navigate);
      case AppScreen.settings:
        page = SettingsScreen(
          current: screen,
          onNavigate: controller.navigate,
          onToggleTheme: () {
            final isDark = ref.read(themeProvider) == ThemeMode.dark;
            ref
                .read(themeProvider.notifier)
                .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
          onToggleLanguage: controller.toggleLanguage,
        );
      case AppScreen.accountSecurity:
        page = AccountSecurityScreen(onNavigate: controller.navigate);
      case AppScreen.thresholds:
        page = ThresholdsScreen(onNavigate: controller.navigate);
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
      case AppScreen.userDevices:
        page = UserDevicesScreen(onNavigate: controller.navigate);
    }

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<AppScreen>(screen),
            child: page,
          ),
        ),
      ),
    );
  }
}
