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
  // Database Path Constants
  // ============================================================================
  // These paths must match exactly with the Firebase Realtime Database schema

  /// Root path for control settings
  /// Contains: auto_mode, led_light
  static const String controlsPath = '/Controls';

  /// Path for auto mode control (0 = manual, 1 = auto)
  static const String autoModePath = '$controlsPath/auto_mode';

  /// Path for LED light control (0 = off, 1 = on)
  /// Note: Maps to "UV Purifier" in UI
  static const String ledLightPath = '$controlsPath/led_light';

  /// Path for Water Pump (0=off, 1=on)
  static const String waterPumpPath = '$controlsPath/water_pump';

  /// Path for Ventilation Fan (0=off, 1=on)
  static const String fanPath = '$controlsPath/fan';

  /// Path for Heater (0=off, 1=on)
  static const String heaterPath = '$controlsPath/heater';

  /// Path for pH Up Pump (0=off, 1=on)
  static const String pumpPhUpPath = '$controlsPath/pump_ph_up';

  /// Path for pH Down Pump (0=off, 1=on)
  static const String pumpPhDownPath = '$controlsPath/pump_ph_down';

  /// Path for EC Up Pump (0=off, 1=on)
  static const String pumpEcUpPath = '$controlsPath/pump_ec_up';

  /// Path for EC Down Pump (0=off, 1=on)
  static const String pumpEcDownPath = '$controlsPath/pump_ec_down';

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
