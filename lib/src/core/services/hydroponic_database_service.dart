import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/firebase_config.dart';
import '../models/hydroponic/controls_model.dart';
import '../models/hydroponic/sensors_model.dart';
import '../models/hydroponic/settings_model.dart';

/// Custom exception for database errors
class DatabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DatabaseException(this.message, [this.code, this.originalError]);

  @override
  String toString() =>
      'DatabaseException: $message${code != null ? ' ($code)' : ''}';
}

/// Service for managing Firebase Realtime Database operations.
///
/// This service provides a repository pattern implementation for the
/// hydroponic system's IoT data, including:
/// - Real-time streams for sensor data
/// - Methods for updating control settings
/// - Methods for updating threshold settings
///
/// Usage with Riverpod:
/// ```dart
/// final dbService = ref.watch(hydroponicDatabaseServiceProvider);
/// final controlsStream = dbService.watchControls();
/// ```
class HydroponicDatabaseService {
  final DatabaseReference _database;

  /// Creates a new [HydroponicDatabaseService] instance
  ///
  /// [database] - Optional DatabaseReference for testing/dependency injection
  HydroponicDatabaseService({DatabaseReference? database})
    : _database = database ?? FirebaseConfig.getDatabaseReference();

  // ============================================================================
  // Real-Time Streams (Repository Pattern)
  // ============================================================================

  /// Watches the `/Controls` node for real-time updates
  ///
  /// Returns a stream of [ControlsModel] that emits whenever:
  /// - auto_mode changes
  /// - led_light changes
  /// - Initial data is loaded
  ///
  /// Handles null values gracefully by returning default values.
  ///
  /// Example:
  /// ```dart
  /// dbService.watchControls().listen((controls) {
  ///   print('Auto mode: ${controls.autoMode}');
  ///   print('LED light: ${controls.ledLight}');
  /// });
  /// ```
  Stream<ControlsModel> watchControls() {
    try {
      final ref = _database.child(FirebaseConfig.controlsPath);

      return ref.onValue
          .map((event) {
            try {
              final data = event.snapshot.value;

              // Handle null or invalid data
              if (data == null) {
                return const ControlsModel.initial();
              }

              // Convert data to Map if it's not already
              if (data is! Map) {
                throw DatabaseException(
                  'Invalid data type for Controls: expected Map, got ${data.runtimeType}',
                );
              }

              return ControlsModel.fromJson(data);
            } catch (e) {
              throw DatabaseException('Error parsing Controls data', null, e);
            }
          })
          .handleError((error) {
            throw DatabaseException(
              'Error watching Controls stream',
              null,
              error,
            );
          });
    } catch (e) {
      throw DatabaseException('Failed to create Controls stream', null, e);
    }
  }

  /// Watches the `/Settings` node for real-time updates
  ///
  /// Returns a stream of [SettingsModel] that emits whenever any
  /// threshold value changes (temp_high, temp_low, ph_high, ec_low).
  ///
  /// Example:
  /// ```dart
  /// dbService.watchSettings().listen((settings) {
  ///   print('Temp range: ${settings.tempLow}°C - ${settings.tempHigh}°C');
  ///   print('pH max: ${settings.phHigh}');
  ///   print('EC min: ${settings.ecLow} mS/cm');
  /// });
  /// ```
  Stream<SettingsModel> watchSettings() {
    try {
      final ref = _database.child(FirebaseConfig.settingsPath);

      return ref.onValue
          .map((event) {
            try {
              final data = event.snapshot.value;

              if (data == null) {
                return const SettingsModel();
              }

              if (data is! Map) {
                throw DatabaseException(
                  'Invalid data type for Settings: expected Map, got ${data.runtimeType}',
                );
              }

              return SettingsModel.fromJson(data);
            } catch (e) {
              throw DatabaseException('Error parsing Settings data', null, e);
            }
          })
          .handleError((error) {
            throw DatabaseException(
              'Error watching Settings stream',
              null,
              error,
            );
          });
    } catch (e) {
      throw DatabaseException('Failed to create Settings stream', null, e);
    }
  }

  /// Watches the `/Sensors` node for real-time updates
  ///
  /// Returns a stream of [SensorsModel] that emits whenever
  /// sensor readings change (currently water_level).
  ///
  /// Example:
  /// ```dart
  /// dbService.watchSensors().listen((sensors) {
  ///   if (sensors.isCriticallyLow) {
  ///     showAlert('Water level critical!');
  ///   }
  /// });
  /// ```
  Stream<SensorsModel> watchSensors() {
    try {
      final ref = _database.child(FirebaseConfig.sensorsPath);

      return ref.onValue
          .map((event) {
            try {
              final data = event.snapshot.value;

              if (data == null) {
                return const SensorsModel(waterLevel: null);
              }

              if (data is! Map) {
                throw DatabaseException(
                  'Invalid data type for Sensors: expected Map, got ${data.runtimeType}',
                );
              }

              return SensorsModel.fromJson(data);
            } catch (e) {
              throw DatabaseException('Error parsing Sensors data', null, e);
            }
          })
          .handleError((error) {
            throw DatabaseException(
              'Error watching Sensors stream',
              null,
              error,
            );
          });
    } catch (e) {
      throw DatabaseException('Failed to create Sensors stream', null, e);
    }
  }

  /// Watches only the water level sensor for real-time updates
  ///
  /// More efficient than watching the entire Sensors node if you
  /// only need water level data.
  ///
  /// Example:
  /// ```dart
  /// dbService.watchWaterLevel().listen((level) {
  ///   updateWaterLevelGauge(level);
  /// });
  /// ```
  Stream<int> watchWaterLevel() {
    try {
      final ref = _database.child(FirebaseConfig.waterLevelPath);

      return ref.onValue
          .map((event) {
            try {
              final data = event.snapshot.value;

              if (data == null) return 0;

              if (data is int) {
                return data.clamp(0, 100);
              } else if (data is double) {
                return data.toInt().clamp(0, 100);
              } else if (data is String) {
                return (int.tryParse(data) ?? 0).clamp(0, 100);
              }

              return 0;
            } catch (e) {
              throw DatabaseException(
                'Error parsing water level data',
                null,
                e,
              );
            }
          })
          .handleError((error) {
            throw DatabaseException(
              'Error watching water level stream',
              null,
              error,
            );
          });
    } catch (e) {
      throw DatabaseException('Failed to create water level stream', null, e);
    }
  }

  // ============================================================================
  // Update Methods for Controls
  // ============================================================================

  /// Toggles the auto mode control
  ///
  /// Updates `/Controls/auto_mode` with:
  /// - 1 if [enabled] is true (auto mode on)
  /// - 0 if [enabled] is false (manual mode)
  ///
  /// Example:
  /// ```dart
  /// await dbService.toggleAutoMode(true); // Enable auto mode
  /// ```
  Future<void> toggleAutoMode(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.autoModePath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update auto mode: $e', null, e);
    }
  }

  Future<void> toggleLedLight(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.ledLightPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update LED light: $e', null, e);
    }
  }

  Future<void> toggleWaterPump(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.waterPumpPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update Water Pump: $e', null, e);
    }
  }

  Future<void> toggleFan(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.fanPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update Fan: $e', null, e);
    }
  }

  Future<void> toggleHeater(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.heaterPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update Heater: $e', null, e);
    }
  }

  Future<void> togglePumpPhUp(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.pumpPhUpPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update pH Up Pump: $e', null, e);
    }
  }

  Future<void> togglePumpPhDown(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.pumpPhDownPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update pH Down Pump: $e', null, e);
    }
  }

  Future<void> togglePumpEcUp(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.pumpEcUpPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update EC Up Pump: $e', null, e);
    }
  }

  Future<void> togglePumpEcDown(bool enabled) async {
    try {
      final ref = _database.child(FirebaseConfig.pumpEcDownPath);
      await ref.set(enabled ? 1 : 0);
    } catch (e) {
      throw DatabaseException('Failed to update EC Down Pump: $e', null, e);
    }
  }

  /// Updates both control settings at once
  ///
  /// More efficient than calling toggleAutoMode and toggleLedLight separately.
  ///
  /// Example:
  /// ```dart
  /// final controls = ControlsModel(autoMode: true, ledLight: false);
  /// await dbService.updateControls(controls);
  /// ```
  Future<void> updateControls(ControlsModel controls) async {
    try {
      final ref = _database.child(FirebaseConfig.controlsPath);
      await ref.update(controls.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update controls: $e', null, e);
    }
  }

  // ============================================================================
  // Update Methods for Settings
  // ============================================================================

  /// Updates all threshold settings at once
  ///
  /// Updates `/Settings` with all four threshold values.
  /// Validates settings before updating (throws if invalid).
  ///
  /// Example:
  /// ```dart
  /// final settings = SettingsModel(
  ///   tempHigh: 26.0,
  ///   tempLow: 18.0,
  ///   phHigh: 6.5,
  ///   ecLow: 1.2,
  /// );
  /// await dbService.updateSettings(settings);
  /// ```
  Future<void> updateSettings(SettingsModel settings) async {
    // Validate settings before updating
    final errors = settings.validate();
    if (errors.isNotEmpty) {
      throw DatabaseException(
        'Invalid settings: ${errors.join(', ')}',
        'validation-error',
      );
    }

    try {
      final ref = _database.child(FirebaseConfig.settingsPath);
      await ref.update(settings.toJson());
    } catch (e) {
      throw DatabaseException('Failed to update settings: $e', null, e);
    }
  }

  /// Updates only temperature thresholds
  ///
  /// More efficient when you only need to update temperature values.
  ///
  /// Example:
  /// ```dart
  /// await dbService.updateTempThresholds(high: 28.0, low: 16.0);
  /// ```
  Future<void> updateTempThresholds({
    required double high,
    required double low,
  }) async {
    if (high <= low) {
      throw const DatabaseException(
        'High temperature must be greater than low temperature',
        'validation-error',
      );
    }

    try {
      final ref = _database.child(FirebaseConfig.settingsPath);
      await ref.update({'temp_high': high, 'temp_low': low});
    } catch (e) {
      throw DatabaseException(
        'Failed to update temperature thresholds: $e',
        null,
        e,
      );
    }
  }

  /// Updates only the pH threshold
  ///
  /// Example:
  /// ```dart
  /// await dbService.updatePhThreshold(6.8);
  /// ```
  Future<void> updatePhThreshold(double phHigh) async {
    if (phHigh < 0 || phHigh > 14) {
      throw const DatabaseException(
        'pH must be between 0 and 14',
        'validation-error',
      );
    }

    try {
      final ref = _database.child(FirebaseConfig.phHighPath);
      await ref.set(phHigh);
    } catch (e) {
      throw DatabaseException('Failed to update pH threshold: $e', null, e);
    }
  }

  /// Updates only the EC threshold
  ///
  /// Example:
  /// ```dart
  /// await dbService.updateEcThreshold(1.5);
  /// ```
  Future<void> updateEcThreshold(double ecLow) async {
    if (ecLow < 0 || ecLow > 10) {
      throw const DatabaseException(
        'EC must be between 0 and 10 mS/cm',
        'validation-error',
      );
    }

    try {
      final ref = _database.child(FirebaseConfig.ecLowPath);
      await ref.set(ecLow);
    } catch (e) {
      throw DatabaseException('Failed to update EC threshold: $e', null, e);
    }
  }

  // ============================================================================
  // One-Time Read Methods (for when you don't need real-time updates)
  // ============================================================================

  /// Gets current control settings (one-time read)
  ///
  /// Use this instead of watchControls() when you only need
  /// the current value without real-time updates.
  Future<ControlsModel> getControls() async {
    try {
      final ref = _database.child(FirebaseConfig.controlsPath);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) {
        return const ControlsModel.initial();
      }

      final data = snapshot.value;
      if (data is! Map) {
        throw DatabaseException('Invalid data type for Controls');
      }

      return ControlsModel.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to get controls: $e', null, e);
    }
  }

  /// Gets current settings (one-time read)
  Future<SettingsModel> getSettings() async {
    try {
      final ref = _database.child(FirebaseConfig.settingsPath);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) {
        return const SettingsModel();
      }

      final data = snapshot.value;
      if (data is! Map) {
        throw DatabaseException('Invalid data type for Settings');
      }

      return SettingsModel.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to get settings: $e', null, e);
    }
  }

  /// Gets current sensor readings (one-time read)
  Future<SensorsModel> getSensors() async {
    try {
      final ref = _database.child(FirebaseConfig.sensorsPath);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) {
        return const SensorsModel(waterLevel: null);
      }

      final data = snapshot.value;
      if (data is! Map) {
        throw DatabaseException('Invalid data type for Sensors');
      }

      return SensorsModel.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to get sensors: $e', null, e);
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

/// Provider for [HydroponicDatabaseService]
///
/// Usage:
/// ```dart
/// final dbService = ref.watch(hydroponicDatabaseServiceProvider);
/// ```
final hydroponicDatabaseServiceProvider = Provider<HydroponicDatabaseService>((
  ref,
) {
  return HydroponicDatabaseService();
});

/// Stream provider for real-time Controls data
///
/// Usage:
/// ```dart
/// final controlsAsync = ref.watch(controlsStreamProvider);
/// controlsAsync.when(
///   data: (controls) => Text('Auto: ${controls.autoMode}'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
final controlsStreamProvider = StreamProvider<ControlsModel>((ref) {
  final dbService = ref.watch(hydroponicDatabaseServiceProvider);
  return dbService.watchControls();
});

/// Stream provider for real-time Settings data
final settingsStreamProvider = StreamProvider<SettingsModel>((ref) {
  final dbService = ref.watch(hydroponicDatabaseServiceProvider);
  return dbService.watchSettings();
});

/// Stream provider for real-time Sensors data
final sensorsStreamProvider = StreamProvider<SensorsModel>((ref) {
  final dbService = ref.watch(hydroponicDatabaseServiceProvider);
  return dbService.watchSensors();
});

/// Stream provider for real-time water level data
final waterLevelStreamProvider = StreamProvider<int>((ref) {
  final dbService = ref.watch(hydroponicDatabaseServiceProvider);
  return dbService.watchWaterLevel();
});
