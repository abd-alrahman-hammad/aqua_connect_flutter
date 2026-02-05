import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_config.dart';

/// Exception thrown when Firebase initialization fails
class FirebaseInitException implements Exception {
  final String message;
  final dynamic originalError;

  const FirebaseInitException(this.message, [this.originalError]);

  @override
  String toString() => 'FirebaseInitException: $message';
}

/// Utilities for initializing Firebase in the Flutter application.
///
/// Handles platform-specific Firebase initialization and provides
/// status checking for initialization state.
class FirebaseInitializer {
  // Private constructor to prevent instantiation
  FirebaseInitializer._();

  /// Initializes Firebase with platform-specific configuration
  ///
  /// This method should be called in `main()` before `runApp()`:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await FirebaseInitializer.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Returns `true` if initialization was successful.
  ///
  /// Throws [FirebaseInitException] if initialization fails.
  static Future<bool> initialize() async {
    try {
      // Get platform-specific Firebase options
      final options = _getPlatformOptions();

      // Initialize Firebase with the appropriate options
      await Firebase.initializeApp(options: options);

      return true;
    } on FirebaseException catch (e) {
      throw FirebaseInitException(
        'Firebase initialization failed: ${e.message}',
        e,
      );
    } catch (e) {
      throw FirebaseInitException(
        'Unexpected error during Firebase initialization',
        e,
      );
    }
  }

  /// Gets the appropriate FirebaseOptions for the current platform
  ///
  /// Returns:
  /// - [FirebaseConfig.web] for web platforms
  /// - [FirebaseConfig.ios] for iOS platforms
  /// - [FirebaseConfig.android] for Android platforms
  ///
  /// Throws [FirebaseInitException] if platform is not supported.
  static FirebaseOptions _getPlatformOptions() {
    if (kIsWeb) {
      return FirebaseConfig.web;
    } else if (Platform.isIOS) {
      return FirebaseConfig.ios;
    } else if (Platform.isAndroid) {
      return FirebaseConfig.android;
    } else {
      throw const FirebaseInitException(
        'Unsupported platform for Firebase. '
        'Only Android, iOS, and Web are supported.',
      );
    }
  }

  /// Checks if Firebase has been initialized
  ///
  /// Returns `true` if Firebase.apps is not empty (i.e., Firebase is initialized).
  static bool get isInitialized => Firebase.apps.isNotEmpty;

  /// Gets the default Firebase app instance
  ///
  /// Throws [FirebaseInitException] if Firebase hasn't been initialized.
  static FirebaseApp get defaultApp {
    if (!isInitialized) {
      throw const FirebaseInitException(
        'Firebase has not been initialized. '
        'Call FirebaseInitializer.initialize() first.',
      );
    }
    return Firebase.app();
  }

  /// Performs health check on Firebase initialization
  ///
  /// Returns a map with initialization status and details:
  /// ```dart
  /// {
  ///   'initialized': true,
  ///   'appName': '[DEFAULT]',
  ///   'options': {
  ///     'projectId': '....',
  ///     'databaseURL': 'https://...'
  ///   }
  /// }
  /// ```
  static Map<String, dynamic> getStatus() {
    if (!isInitialized) {
      return {'initialized': false, 'error': 'Firebase not initialized'};
    }

    final app = defaultApp;
    return {
      'initialized': true,
      'appName': app.name,
      'options': {
        'projectId': app.options.projectId,
        'databaseURL': app.options.databaseURL,
        'apiKey':
            app.options.apiKey.substring(0, 10) + '...', // Obscure for security
      },
    };
  }
}
