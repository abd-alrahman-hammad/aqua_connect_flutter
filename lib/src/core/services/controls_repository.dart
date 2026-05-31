import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/firebase_config.dart';
import '../models/hydroponic/controls_model.dart';
import '../models/hydroponic/settings_model.dart';
import 'realtime_database_provider.dart';

/// Repository for managing Firebase Realtime Database operations related to controls and settings.
class ControlsRepository {
  final DatabaseReference _database;

  ControlsRepository({DatabaseReference? database})
    : _database = database ?? FirebaseConfig.getDatabaseReference();

  // ============================================================================
  // Real-Time Streams (Repository Pattern)
  // ============================================================================

  Stream<ControlsModel> watchControls() {
    try {
      final ref = _database.child(FirebaseConfig.controlsPath);

      return ref.onValue
          .map((event) {
            try {
              final data = event.snapshot.value;

              if (data == null) {
                return const ControlsModel.initial();
              }

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

  // ============================================================================
  // Update Methods for Controls
  // ============================================================================

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

  Future<void> updateSettings(SettingsModel settings) async {
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
  // One-Time Read Methods
  // ============================================================================

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
}

// ============================================================================
// Riverpod Providers
// ============================================================================

final controlsRepositoryProvider = Provider<ControlsRepository>((ref) {
  return ControlsRepository();
});

final controlsStreamProvider = StreamProvider<ControlsModel>((ref) {
  final repository = ref.watch(controlsRepositoryProvider);
  return repository.watchControls();
});

final settingsStreamProvider = StreamProvider<SettingsModel>((ref) {
  final repository = ref.watch(controlsRepositoryProvider);
  return repository.watchSettings();
});
