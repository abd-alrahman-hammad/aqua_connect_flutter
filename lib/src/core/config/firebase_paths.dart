class FirebasePaths {
  FirebasePaths._();

  // ============================================================================
  // Database Path Constants
  // ============================================================================
  // These paths must match exactly with the Firebase Realtime Database schema

  /// Root path for control settings
  /// Contains: auto_mode, led_light
  static const String controlsPath = '/controls/HYDRO_001';

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

  /// Root path for Dosing Control
  static const String dosingControlPath = '/DosingControl/HYDRO_001';
  
  /// Path for EC Up steps
  static const String ecUpStepsPath = '$dosingControlPath/ec_up_steps';
  
  /// Path for pH Down steps
  static const String phDownStepsPath = '$dosingControlPath/ph_down_steps';

  /// Root path for users
  static const String usersPath = '/Users';

  /// Root path for threshold settings
  /// Contains: temp_high, temp_low, ph_high, ec_low
  static const String settingsPath = '/Settings/HYDRO_001';

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
  static const String sensorsPath = '/sensors/HYDRO_001';

  /// Path for water level sensor (Int 0-100%)
  static const String waterLevelPath = '$sensorsPath/water_level';

  /// Firestore History Paths
  /// History is now stored in Cloud Firestore under:
  /// devices -> [deviceId] -> sensorHistory -> [autoId]
  static const String devicesCollectionPath = 'devices';
  static const String sensorHistoryCollectionPath = 'sensorHistory';
}
