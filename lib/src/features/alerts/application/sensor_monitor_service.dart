import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/models/hydroponic/sensors_model.dart';
import '../domain/alert_model.dart';
import '../data/notification_service.dart';

enum _SystemState { optimal, warning, critical }

/// Provider to access the list of active alerts
final alertsProvider = StateNotifierProvider<AlertsNotifier, List<AlertModel>>((
  ref,
) {
  final notificationService = ref.watch(notificationServiceProvider);
  return AlertsNotifier(notificationService);
});

/// Service that monitors sensors and triggers alerts
final sensorMonitorServiceProvider = Provider<SensorMonitorService>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final alertsNotifier = ref.read(alertsProvider.notifier);

  final service = SensorMonitorService(notificationService, alertsNotifier);

  // Check initial state if available
  ref.read(sensorsStreamProvider).whenData((sensors) {
    service.checkSensors(sensors);
  });

  // Watch sensor data changes
  ref.listen<AsyncValue<SensorsModel>>(sensorsStreamProvider, (previous, next) {
    next.whenData((sensors) {
      service.checkSensors(sensors);
    });
  });

  return service;
});

class AlertsNotifier extends StateNotifier<List<AlertModel>> {
  AlertsNotifier(NotificationService notificationService) : super([]);

  void addAlert(AlertModel alert) {
    // Avoid duplicate alerts for the same issue within a short time window could be handled here
    // For now, we just add it to the top
    state = [alert, ...state];
  }

  void removeAlert(String id) {
    state = state.where((alert) => alert.id != id).toList();
  }

  void clearAll() {
    state = [];
  }
}

class SensorMonitorService {
  final NotificationService _notificationService;
  final AlertsNotifier _alertsNotifier;

  // Keep track of last alert times to avoid spamming
  DateTime? _lastPhAlert;
  DateTime? _lastWaterAlert;
  DateTime? _lastTempAlert;
  DateTime? _lastEcAlert;
  DateTime? _lastSystemOptimalAlert;

  // Track system state for transitions
  _SystemState _lastSystemState = _SystemState.optimal;

  static const _alertCooldown = Duration(minutes: 30);
  static const _optimalCooldown = Duration(hours: 24);

  SensorMonitorService(this._notificationService, this._alertsNotifier);

  void checkSensors(SensorsModel sensors) {
    bool hasCritical = false;
    bool hasWarning = false;

    // 1. Check pH
    if (sensors.ph != null) {
      final phStatus = _getPhStatus(sensors.ph!);
      if (phStatus == _SystemState.critical) {
        hasCritical = true;
        _checkPh(sensors.ph!);
      } else if (phStatus == _SystemState.warning) {
        hasWarning = true;
        _checkPh(sensors.ph!);
      }
    }

    // 2. Check Water Level
    if (sensors.waterLevel != null) {
      final waterStatus = _getWaterLevelStatus(sensors.waterLevel!);
      if (waterStatus == _SystemState.critical) {
        hasCritical = true;
        _checkWaterLevel(sensors.waterLevel!);
      } else if (waterStatus == _SystemState.warning) {
        hasWarning = true;
        _checkWaterLevel(sensors.waterLevel!);
      }
    }

    // 3. Check Temperature
    if (sensors.temperature != null) {
      final tempStatus = _getTemperatureStatus(sensors.temperature!);
      if (tempStatus == _SystemState.critical) {
        hasCritical = true;
        _checkTemperature(sensors.temperature!);
      } else if (tempStatus == _SystemState.warning) {
        hasWarning = true;
        _checkTemperature(sensors.temperature!);
      }
    }

    // 4. Check EC
    if (sensors.ec != null) {
      final ecStatus = _getEcStatus(sensors.ec!);
      if (ecStatus == _SystemState.critical) {
        hasCritical = true;
        _checkEc(sensors.ec!);
      } else if (ecStatus == _SystemState.warning) {
        hasWarning = true;
        _checkEc(sensors.ec!);
      }
    }

    // Determine Global State & Check for Optimal Transition
    _SystemState currentState;
    if (hasCritical) {
      currentState = _SystemState.critical;
    } else if (hasWarning) {
      currentState = _SystemState.warning;
    } else {
      currentState = _SystemState.optimal;
    }

    // Trigger "All Systems Optimal" only on transition from bad state to optimal
    if (currentState == _SystemState.optimal &&
        _lastSystemState != _SystemState.optimal) {
      _triggerOptimalNotification();
    }

    _lastSystemState = currentState;
  }

  // --- Status Helpers (Defining thresholds) ---

  _SystemState _getPhStatus(double ph) {
    if (ph < 5.0 || ph > 7.0) return _SystemState.critical;
    if (ph < 5.5 || ph > 6.5) return _SystemState.warning;
    return _SystemState.optimal;
  }

  _SystemState _getWaterLevelStatus(int level) {
    if (level < 20) return _SystemState.critical;
    if (level < 40) return _SystemState.warning;
    return _SystemState.optimal;
  }

  _SystemState _getTemperatureStatus(double temp) {
    if (temp < 15 || temp > 30) return _SystemState.critical;
    if (temp < 18 || temp > 26) return _SystemState.warning;
    return _SystemState.optimal;
  }

  _SystemState _getEcStatus(double ec) {
    // Assuming generic Hydroponic ranges (e.g. Lettuce: 1.2-1.8)
    // Critical: < 0.5 or > 2.5
    // Warning: < 1.0 or > 2.0
    if (ec < 0.5 || ec > 2.5) return _SystemState.critical;
    if (ec < 1.0 || ec > 2.0) return _SystemState.warning;
    return _SystemState.optimal;
  }

  // --- Alert Triggers ---

  void _checkPh(double ph) {
    if (_shouldTriggerAlert(_lastPhAlert)) {
      final status = _getPhStatus(ph);
      final isLow = ph < 5.5; // Simple direction check
      final type = status == _SystemState.critical
          ? AlertType.critical
          : AlertType.warning;
      final title = status == _SystemState.critical
          ? 'Critical: pH ${isLow ? 'Too Low' : 'Too High'}'
          : 'Warning: pH ${isLow ? 'Low' : 'High'}';
      final message = 'Current pH: ${ph.toStringAsFixed(1)}. Target: 5.5-6.5';

      _createAlert(
        type: type,
        icon: 'water_drop',
        title: title,
        message: message,
      );
      _lastPhAlert = DateTime.now();
    }
  }

  void _checkWaterLevel(int level) {
    if (_shouldTriggerAlert(_lastWaterAlert)) {
      final status = _getWaterLevelStatus(level);
      final type = status == _SystemState.critical
          ? AlertType.critical
          : AlertType.warning;
      final title = status == _SystemState.critical
          ? 'Critical: Water Level Very Low'
          : 'Warning: Water Level Low';
      final message = 'Tank level is at $level%. Minimum safe level: 20%.';

      _createAlert(type: type, icon: 'waves', title: title, message: message);
      _lastWaterAlert = DateTime.now();
    }
  }

  void _checkTemperature(double temp) {
    if (_shouldTriggerAlert(_lastTempAlert)) {
      final status = _getTemperatureStatus(temp);
      final isLow = temp < 18;
      final type = status == _SystemState.critical
          ? AlertType.critical
          : AlertType.warning;
      final title = status == _SystemState.critical
          ? 'Critical: Temp ${isLow ? 'Too Low' : 'Too High'}'
          : 'Warning: Temp ${isLow ? 'Low' : 'High'}';
      final message =
          'Water temp is ${temp.toStringAsFixed(1)}°C. Optimal: 18-26°C';

      _createAlert(
        type: type,
        icon: 'thermostat',
        title: title,
        message: message,
      );
      _lastTempAlert = DateTime.now();
    }
  }

  void _checkEc(double ec) {
    if (_shouldTriggerAlert(_lastEcAlert)) {
      final status = _getEcStatus(ec);
      final isLow = ec < 1.0;
      final type = status == _SystemState.critical
          ? AlertType.critical
          : AlertType.warning;
      final title = status == _SystemState.critical
          ? 'Critical: EC ${isLow ? 'Too Low' : 'Too High'}'
          : 'Warning: EC ${isLow ? 'Low' : 'High'}';

      final message =
          'Nutrient concentration (EC) is ${ec.toStringAsFixed(1)} mS/cm. Optimal: 1.0-2.0';

      _createAlert(type: type, icon: 'bolt', title: title, message: message);
      _lastEcAlert = DateTime.now();
    }
  }

  Future<void> _triggerOptimalNotification() async {
    // Only trigger if we haven't sent one recently (or just always on transition?
    // Let's stick to cooldown to be safe, though transition check usually handles it)
    if (_lastSystemOptimalAlert != null &&
        DateTime.now().difference(_lastSystemOptimalAlert!) <
            _optimalCooldown) {
      return;
    }

    _createAlert(
      type: AlertType.optimal,
      icon: 'check_circle',
      title: 'System Optimal',
      message: 'All sensors are reading within optimal ranges.',
    );

    _lastSystemOptimalAlert = DateTime.now();
  }

  bool _shouldTriggerAlert(DateTime? lastAlertTime) {
    if (lastAlertTime == null) return true;
    return DateTime.now().difference(lastAlertTime) > _alertCooldown;
  }

  Future<void> _createAlert({
    required AlertType type,
    required String icon,
    required String title,
    required String message,
  }) async {
    final alert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      icon: icon,
      title: title,
      timestamp: DateTime.now(),
      message: message,
    );

    _alertsNotifier.addAlert(alert);

    // Trigger push notification
    await _notificationService.showNotification(
      id: int.parse(alert.id.substring(alert.id.length - 9)),
      title: title,
      body: message,
    );
  }
}
