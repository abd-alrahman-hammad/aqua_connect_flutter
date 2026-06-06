import 'package:firebase_core/firebase_core.dart';

// import 'firebase_config.dart';
import '../../../../firebase_options.dart';

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

  /// Throws [FirebaseInitException] if initialization fails.
  static Future<bool> initialize() async {
    try {
      if (isInitialized) {
        return true;
      }

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

  /// Throws [FirebaseInitException] if platform is not supported.
  static FirebaseOptions _getPlatformOptions() {
    return DefaultFirebaseOptions.currentPlatform;
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

  // Performs health check on Firebase initialization
  // Returns a map with initialization status and details:

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
            '${app.options.apiKey.substring(0, 10)}...', // Obscure for security
      },
    };
  }
}
