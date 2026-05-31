import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/firebase_config.dart';
import '../models/hydroponic/sensors_model.dart';
import '../models/db/live_monitoring_model.dart';
import 'realtime_database_provider.dart';

/// Repository for managing Firebase Realtime Database operations related to sensors.
class SensorsRepository {
  final DatabaseReference _database;

  SensorsRepository({DatabaseReference? database})
    : _database = database ?? FirebaseConfig.getDatabaseReference();

  // ============================================================================
  // Real-Time Streams (Repository Pattern)
  // ============================================================================

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

  Stream<LiveMonitoringModel> watchLiveMonitoring() {
    try {
      final ref = _database.child('LiveMonitoring/HYDRO_001');

      return ref.onValue
          .map((event) {
            try {
              final data = event.snapshot.value;

              if (data == null) {
                return const LiveMonitoringModel.initial();
              }

              if (data is! Map) {
                throw DatabaseException(
                  'Invalid data type for LiveMonitoring: expected Map, got ${data.runtimeType}',
                );
              }

              return LiveMonitoringModel.fromJson(data);
            } catch (e) {
              throw DatabaseException(
                'Error parsing LiveMonitoring data',
                null,
                e,
              );
            }
          })
          .handleError((error) {
            throw DatabaseException(
              'Error watching LiveMonitoring stream',
              null,
              error,
            );
          });
    } catch (e) {
      throw DatabaseException(
        'Failed to create LiveMonitoring stream',
        null,
        e,
      );
    }
  }

  // ============================================================================
  // One-Time Read Methods
  // ============================================================================

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

  Future<Map<int, double>> getSensorHistory(
    String sensorType,
    Duration duration,
  ) async {
    try {
      final now = DateTime.now();
      final startTimeSeconds =
          now.subtract(duration).millisecondsSinceEpoch ~/ 1000;

      final firestore = FirebaseFirestore.instance;
      final deviceId = 'HYDRO_001';

      final querySnapshot = await firestore
          .collection('devices')
          .doc(deviceId)
          .collection(FirebaseConfig.sensorHistoryCollectionPath)
          .where('timestamp', isGreaterThanOrEqualTo: startTimeSeconds)
          .orderBy('timestamp')
          .get();

      final result = <int, double>{};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'];

        if (timestamp == null) continue;

        final int timestampSec = timestamp is int
            ? timestamp
            : (int.tryParse(timestamp.toString()) ?? 0);

        if (timestampSec == 0) continue;

        double? val;
        switch (sensorType.toLowerCase()) {
          case 'ph':
          case 'ph level':
            val = data['ph'] != null
                ? double.tryParse(data['ph'].toString())
                : null;
            break;
          case 'ec':
          case 'ec level':
            val = data['ec'] != null
                ? double.tryParse(data['ec'].toString())
                : null;
            break;
          case 'temperature':
            val = data['temperature'] != null
                ? double.tryParse(data['temperature'].toString())
                : null;
            break;
          case 'water':
          case 'water level':
            val = data['water_level'] != null
                ? double.tryParse(data['water_level'].toString())
                : null;
            break;
          default:
            throw DatabaseException('Unknown sensor type: $sensorType');
        }

        if (val != null) {
          result[timestampSec * 1000] = val;
        }
      }

      return result;
    } catch (e) {
      throw DatabaseException(
        'Failed to get history for $sensorType: $e',
        null,
        e,
      );
    }
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

final sensorsRepositoryProvider = Provider<SensorsRepository>((ref) {
  return SensorsRepository();
});

final sensorsStreamProvider = StreamProvider<SensorsModel>((ref) {
  final repository = ref.watch(sensorsRepositoryProvider);
  return repository.watchSensors();
});

final waterLevelStreamProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(sensorsRepositoryProvider);
  return repository.watchWaterLevel();
});

final liveMonitoringStreamProvider = StreamProvider<LiveMonitoringModel>((ref) {
  final repository = ref.watch(sensorsRepositoryProvider);
  return repository.watchLiveMonitoring();
});

final systemStatusProvider = StateNotifierProvider<SystemStatusNotifier, bool>((
  ref,
) {
  return SystemStatusNotifier(ref);
});

class SystemStatusNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;
  static const _timeout = Duration(seconds: 30);

  SystemStatusNotifier(this._ref) : super(false) {
    // Listen to sensor updates
    _ref.listen<AsyncValue<SensorsModel>>(sensorsStreamProvider, (
      previous,
      next,
    ) {
      // If we get valid data, update heartbeat
      if (next.hasValue && !next.hasError) {
        _onDataReceived();
      }
    });
  }

  void _onDataReceived() {
    if (!state) state = true; // Mark as online
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      if (mounted) state = false; // Mark as offline after timeout
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
