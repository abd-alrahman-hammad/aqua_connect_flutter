import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Firebase configuration for the Rayyan hydroponic system.
///
/// This class centralizes all Firebase configuration including:
/// - Platform-specific Firebase options (Android, iOS, Web)
/// - Firebase Realtime Database URL
/// - Database path constants for consistent data access
class FirebaseConfig {
  // Private constructor to prevent instantiation
  FirebaseConfig._();

  /// Firebase API Key from the credentials
  static const String _apiKey = 'AIzaSyCYRXU04F7yUdSmGNrJ-mTvIlSjA4MN2PA';

  /// Firebase Realtime Database URL
  static const String _databaseUrl =
      'https://rayyan-cf0b7-default-rtdb.asia-southeast1.firebasedatabase.app';

  /// Firebase project ID
  static const String _projectId = 'rayyan-cf0b7';

  /// Firebase Android app ID
  static const String _androidAppId = '1:YOUR_APP_ID:android:YOUR_ANDROID_ID';

  /// Firebase iOS app ID
  static const String _iosAppId = '1:YOUR_APP_ID:ios:YOUR_IOS_ID';

  /// Firebase Web app ID
  static const String _webAppId = '1:YOUR_APP_ID:web:YOUR_WEB_ID';

  /// Firebase options for Android platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _apiKey,
    appId: _androidAppId,
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: _projectId,
    databaseURL: _databaseUrl,
  );

  /// Firebase options for iOS platform
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: _iosAppId,
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: _projectId,
    databaseURL: _databaseUrl,
    iosBundleId: 'com.rayyan.app',
  );

  /// Firebase options for Web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _webAppId,
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: _projectId,
    databaseURL: _databaseUrl,
    authDomain: '$_projectId.firebaseapp.com',
    storageBucket: '$_projectId.appspot.com',
  );

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Gets a reference to the Firebase Realtime Database
  ///
  /// Returns the main database instance configured with the database URL.
  /// This should be used for all database operations.
  static DatabaseReference getDatabaseReference() {
    return FirebaseDatabase.instance.ref();
  }

  /// Gets a reference to a specific path in the database
  ///
  /// Example:
  /// ```dart
  /// final controlsRef = FirebaseConfig.getPathReference(FirebasePaths.controlsPath);
  /// ```
  static DatabaseReference getPathReference(String path) {
    return FirebaseDatabase.instance.ref(path);
  }
}
