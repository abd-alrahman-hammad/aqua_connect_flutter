import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../core/models/hydroponic/sensors_model.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/utils/vitality_utils.dart';
import '../../settings/domain/notification_preferences.dart';
import '../domain/alert_model.dart';
import '../data/notification_service.dart';
import 'sensor_monitor_service.dart'; // For AlertsNotifier access if needed, or just import Provider

/// Service responsible for monitoring sensor data and dispatching notifications
/// based on user preferences and throttling rules.
class SensorWatcher {
  final NotificationService _notificationService;
  final AlertsNotifier _alertsNotifier;
  final Ref _ref;

  // Throttling: Map of SensorType -> DateTime of last notification
  final Map<String, DateTime> _lastNotificationTimes = {};

  // Cooldown period for notifications of the same type/sensor (30 minutes)
  static const Duration _notificationCooldown = Duration(minutes: 30);

  SensorWatcher(this._notificationService, this._alertsNotifier, this._ref);

  /// Main entry point to check sensors and trigger alerts
  void checkSensors(
    SensorsModel sensors,
    SettingsModel settings,
    AppLocalizations loc,
  ) {
    // 1. Get current User Preferences
    final prefs = _ref.read(notificationPreferencesProvider);

    // 2. Evaluate Sensors
    _evaluateSensor(
      label: loc.phLevel,
      value: sensors.ph,
      status: VitalityUtils.getPhStatus(sensors.ph, settings),
      prefs: prefs,
      icon: 'water_drop',
      loc: loc,
      sensorKey: 'ph',
    );

    _evaluateSensor(
      label: loc.ecLevel,
      value: sensors.ec,
      status: VitalityUtils.getEcStatus(sensors.ec, settings),
      prefs: prefs,
      icon: 'bolt',
      loc: loc,
      sensorKey: 'ec',
    );

    _evaluateSensor(
      label: loc.temperature,
      value: sensors.temperature,
      status: VitalityUtils.getTemperatureStatus(sensors.temperature, settings),
      prefs: prefs,
      icon: 'device_thermostat',
      unit: '°C',
      loc: loc,
      sensorKey: 'temp',
    );

    _evaluateSensor(
      label: loc.waterLevel,
      value: sensors.waterLevel,
      status: VitalityUtils.getWaterLevelStatus(sensors.waterLevel),
      prefs: prefs,
      icon: 'waves',
      unit: '%',
      loc: loc,
      sensorKey: 'water_level',
    );
  }

  void _evaluateSensor({
    required String label,
    required dynamic value,
    required SensorStatus status,
    required NotificationPreferences prefs,
    required String icon,
    required AppLocalizations loc,
    required String sensorKey,
    String unit = '',
  }) {
    // If status is OK or Unknown, we do nothing.
    if (status == SensorStatus.ok || status == SensorStatus.unknown) return;

    // 3. Notification Decision Logic (The "Gatekeeper")
    bool shouldSendPush = true;

    // Case 1: If masterToggle == false -> No notification should be sent.
    if (!prefs.pushEnabled) {
      shouldSendPush = false;
    }

    // Case 2 & 3: Filter based on specific toggles
    if (sensorKey == 'water_level') {
      if (!prefs.waterLevelNotificationsEnabled) shouldSendPush = false;
    } else if (status == SensorStatus.critical) {
      if (!prefs.criticalAlertsEnabled) shouldSendPush = false;
    } else if (status == SensorStatus.warning) {
      if (!prefs.parameterWarningsEnabled) shouldSendPush = false;
    }

    // 4. Spam Prevention (Debounce / Throttling)
    // specific key for this sensor issue
    final throttleKey = '$sensorKey-${status.name}';
    final lastTime = _lastNotificationTimes[throttleKey];
    final isThrottled =
        lastTime != null &&
        DateTime.now().difference(lastTime) < _notificationCooldown;

    if (isThrottled) {
      shouldSendPush = false;
    }

    // Construct the Alert
    final alert = _createAlertModel(label, value, status, icon, unit, loc);

    // Logic:
    // We ALWAYS add to the in-app history (AlertsNotifier) so the "Alerts" screen
    // reflects the current state history, UNLESS throttled?
    // If we spam the in-app list every 5 seconds, that's bad too.
    // So throttling should apply to the *Creation* of the alert entity itself.

    if (!isThrottled) {
      // Add to internal list
      _alertsNotifier.addAlert(alert);

      // Update throttling timestamp
      _lastNotificationTimes[throttleKey] = DateTime.now();

      // Send Push Notification if allowed
      if (shouldSendPush) {
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
          title: alert.title,
          body: alert.message,
          isCritical: alert.type == AlertType.critical,
        );
      }
    }
  }

  AlertModel _createAlertModel(
    String label,
    dynamic value,
    SensorStatus status,
    String icon,
    String unit,
    AppLocalizations loc,
  ) {
    final bool isCritical = status == SensorStatus.critical;
    final String title = isCritical
        ? loc.alertCriticalTitle(label)
        : loc.alertWarningTitle(label);

    final String valStr = value is double
        ? value.toStringAsFixed(1)
        : value.toString();
    final String message = loc.alertBody(label, valStr, unit);

    return AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: isCritical ? AlertType.critical : AlertType.warning,
      icon: icon,
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}
