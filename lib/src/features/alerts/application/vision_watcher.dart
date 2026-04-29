import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../core/models/db/live_monitoring_model.dart';
import '../../settings/domain/notification_preferences.dart';
import '../domain/alert_model.dart';
import '../data/notification_service.dart';
import 'sensor_monitor_service.dart';

class VisionWatcher {
  final NotificationService _notificationService;
  final AlertsNotifier _alertsNotifier;
  final Ref _ref;

  final Map<String, DateTime> _lastNotificationTimes = {};

  // Cooldown period for vision notifications (30 minutes)
  static const Duration _notificationCooldown = Duration(minutes: 30);

  VisionWatcher(this._notificationService, this._alertsNotifier, this._ref);

  void checkVision(LiveMonitoringModel model, AppLocalizations loc) {
    if (!model.isCritical && !model.isWarning) return;

    final prefs = _ref.read(notificationPreferencesProvider);

    bool shouldSendPush = true;

    if (!prefs.pushEnabled) {
      shouldSendPush = false;
    }

    if (model.isCritical) {
      if (!prefs.criticalAlertsEnabled) shouldSendPush = false;
    } else if (model.isWarning) {
      if (!prefs.parameterWarningsEnabled) shouldSendPush = false;
    }

    final statusString = model.isCritical ? 'critical' : 'warning';
    final throttleKey = 'vision-$statusString';
    
    final lastTime = _lastNotificationTimes[throttleKey];
    final isThrottled =
        lastTime != null &&
        DateTime.now().difference(lastTime) < _notificationCooldown;

    if (isThrottled) {
      shouldSendPush = false;
    }

    final alert = _createAlertModel(model, loc);

    if (!isThrottled) {
      _alertsNotifier.addAlert(alert);
      _lastNotificationTimes[throttleKey] = DateTime.now();

      if (shouldSendPush) {
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch % 100000,
          title: alert.title,
          body: alert.message,
          isCritical: alert.type == AlertType.critical,
        );
      }
    }
  }

  AlertModel _createAlertModel(LiveMonitoringModel model, AppLocalizations loc) {
    final bool isCritical = model.isCritical;
    final String label = loc.visionTitle;
    
    final String title = isCritical
        ? loc.alertCriticalTitle(label)
        : loc.alertWarningTitle(label);

    final String statusStr = isCritical ? loc.visionCritical : loc.visionWarning;
    final String message = loc.alertBody(label, statusStr, '');

    return AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: isCritical ? AlertType.critical : AlertType.warning,
      icon: 'coronavirus',
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}
