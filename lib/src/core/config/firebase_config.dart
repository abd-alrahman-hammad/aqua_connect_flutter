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
  static const String _apiKey = 'AIzaSyAIdSNHK6fMdIQ2ED_YB1RJng1fLiKxMXE';

  /// Firebase Realtime Database URL
  static const String _databaseUrl =
      'https://test1-3abbc-default-rtdb.asia-southeast1.firebasedatabase.app/';

  /// Firebase project ID
  static const String _projectId = 'test1-3abbc';

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
  // Database Path Constants
  // ============================================================================
  // These paths must match exactly with the Firebase Realtime Database schema

  /// Root path for control settings
  /// Contains: auto_mode, led_light
  static const String controlsPath = '/Controls';

  /// Path for auto mode control (0 = manual, 1 = auto)
  static const String autoModePath = '$controlsPath/auto_mode';

  /// Path for LED light control (0 = off, 1 = on)
  static const String ledLightPath = '$controlsPath/led_light';

  /// Root path for threshold settings
  /// Contains: temp_high, temp_low, ph_high, ec_low
  static const String settingsPath = '/Settings';

  /// Path for high temperature threshold (Float)
  static const String tempHighPath = '$settingsPath/temp_high';

  /// Path for low temperature threshold (Float)
  static const String tempLowPath = '$settingsPath/temp_low';

  /// Path for high pH threshold (Float)
  static const String phHighPath = '$settingsPath/ph_high';

  /// Path for low EC threshold (Float)
  static const String ecLowPath = '$settingsPath/ec_low';

  /// Root path for sensor readings
  /// Contains: water_level
  static const String sensorsPath = '/Sensors';

  /// Path for water level sensor (Int 0-100%)
  static const String waterLevelPath = '$sensorsPath/water_level';

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
  /// final controlsRef = FirebaseConfig.getPathReference(FirebaseConfig.controlsPath);
  /// ```
  static DatabaseReference getPathReference(String path) {
    return FirebaseDatabase.instance.ref(path);
  }
}
