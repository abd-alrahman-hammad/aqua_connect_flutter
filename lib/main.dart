import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/theme/theme_provider.dart';
import 'src/core/localization/locale_provider.dart';

import 'src/app/app.dart';
import 'src/core/config/firebase_initializer.dart';

import 'src/features/alerts/data/notification_service.dart';

Future<void> main() async {
  // Ensure Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final loadedTheme = ThemeNotifier.loadTheme(prefs);

  // Request permissions immediately for this local-only implementation
  // In a real user flow, you might want to ask this on a specific screen,
  // but for "consistent delivery", ensuring we have permissions early is good.
  await notificationService.requestPermissions();

  // Initialize Firebase with platform-specific configuration
  try {
    await FirebaseInitializer.initialize();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue running the app even if Firebase fails
    // This allows the app to start and show error UI if needed
  }

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(loadedTheme, prefs)),
        localeProvider.overrideWith((ref) => LocaleNotifier(prefs)),
      ],
      child: const RayyanApp(),
    ),
  );
}

/// Lightweight harness to use in widget tests.
class TestAppHarness extends StatelessWidget {
  const TestAppHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: RayyanApp());
  }
}
