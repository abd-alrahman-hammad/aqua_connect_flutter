import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_auth_service.dart';
import '../models/db/app_user_model.dart';
import '../models/db/device_model.dart';


import '../models/db/sensor_history_model.dart';
import '../models/db/live_monitoring_model.dart';

enum DeviceRegistrationStatus {
  success,
  notFound,
  alreadyRegistered,
  error,
}

class FirestoreDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _devicesRef => _firestore.collection('devices');





  CollectionReference _sensorHistoryRef(String deviceId) =>
      _devicesRef.doc(deviceId).collection('sensorHistory');

  CollectionReference get _liveMonitoringRef =>
      _firestore.collection('LiveMonitoring');

  // --- Users CRUD ---

  Future<void> createUser(AppUserModel user) async {
    try {
      await _usersRef.doc(user.userId).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<AppUserModel?> getUser(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        return AppUserModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // --- Devices CRUD ---

  Future<void> createDevice(DeviceModel device) async {
    try {
      await _devicesRef.doc(device.deviceId).set(device.toJson());
    } catch (e) {
      throw Exception('Failed to create device: $e');
    }
  }

  Future<DeviceModel?> getDevice(String deviceId) async {
    try {
      final doc = await _devicesRef.doc(deviceId).get();
      if (doc.exists) {
        return DeviceModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get device: $e');
    }
  }

  Future<List<DeviceModel>> getUserDevices(String userId) async {
    try {
      final querySnapshot = await _devicesRef
          .where('userid', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map(
            (doc) {
              final data = doc.data() as Map<String, dynamic>;
              if (data.containsKey('userid') && !data.containsKey('userId')) {
                data['userId'] = data['userid'];
              }
              return DeviceModel.fromJson(data, doc.id);
            }
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get user devices: $e');
    }
  }

  Stream<List<DeviceModel>> streamUserDevices(String userId) {
    return _devicesRef
        .where('userid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('userid') && !data.containsKey('userId')) {
          data['userId'] = data['userid'];
        }
        return DeviceModel.fromJson(data, doc.id);
      }).toList();
    });
  }

  /// Registers a device to the current user using its serial number.
  Future<DeviceRegistrationStatus> registerDevice(String serialNumber, String currentUserId) async {
    try {
      final querySnapshot = await _devicesRef
          .where('serial_number', isEqualTo: serialNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return DeviceRegistrationStatus.notFound;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final existingUserId = data['userid']; // Based on the user's Firestore structure 'userid'

      bool isAvailable = false;
      if (existingUserId == null) {
        isAvailable = true;
      } else if (existingUserId is String && (existingUserId.trim().isEmpty || existingUserId.trim().toLowerCase() == 'null')) {
        isAvailable = true;
      }

      if (isAvailable) {
        // Device is available, register it to the current user
        await doc.reference.update({'userid': currentUserId});
        return DeviceRegistrationStatus.success;
      } else {
        // Device already registered
        return DeviceRegistrationStatus.alreadyRegistered;
      }
    } catch (e) {
      return DeviceRegistrationStatus.error;
    }
  }





  // --- SensorHistory Collection (Device Sub-collection) ---

  Future<String> addSensorHistory(
    String deviceId,
    SensorHistoryModel data,
  ) async {
    try {
      // Auto-Generated-ID
      final docRef = await _sensorHistoryRef(deviceId).add(data.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add sensor history: $e');
    }
  }

  Future<List<SensorHistoryModel>> getSensorHistory(
    String deviceId, {
    int limit = 50,
  }) async {
    try {
      final querySnapshot = await _sensorHistoryRef(
        deviceId,
      ).orderBy('timestamp', descending: true).limit(limit).get();

      return querySnapshot.docs
          .map(
            (doc) => SensorHistoryModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get sensor history: $e');
    }
  }

  // --- Live Monitoring Methods ---

  /// Streams the live monitoring data for a specific plant document
  /// Path: LiveMonitoring/{documentId} (e.g. LiveMonitoring/Plant_Master)

  /// Gets all live monitoring documents (for history view)
  Future<List<LiveMonitoringModel>> getMonitoringHistory({
    int limit = 20,
  }) async {
    final querySnapshot = await _liveMonitoringRef
        .orderBy('last_update', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return const LiveMonitoringModel.initial();
          return LiveMonitoringModel.fromJson(data, doc.id);
        })
        .where((model) => model.documentId.isNotEmpty)
        .toList();
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

final firestoreServiceProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});

final userDevicesProvider = StreamProvider<List<DeviceModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }
      final firestoreService = ref.watch(firestoreServiceProvider);
      return firestoreService.streamUserDevices(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});
