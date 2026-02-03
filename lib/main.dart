import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app.dart';
import 'src/core/config/firebase_initializer.dart';

Future<void> main() async {
  // Ensure Flutter is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific configuration
  try {
    await FirebaseInitializer.initialize();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // Continue running the app even if Firebase fails
    // This allows the app to start and show error UI if needed
  }

  runApp(const ProviderScope(child: RayyanApp()));
}

/// Lightweight harness to use in widget tests.
class TestAppHarness extends StatelessWidget {
  const TestAppHarness({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: RayyanApp());
  }
}
