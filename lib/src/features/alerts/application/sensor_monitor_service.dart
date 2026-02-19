import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/models/hydroponic/sensors_model.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../domain/alert_model.dart';
import '../data/notification_service.dart';
import 'sensor_watcher.dart';

/// Provider to access the list of active alerts
final alertsProvider = StateNotifierProvider<AlertsNotifier, List<AlertModel>>((
  ref,
) {
  final notificationService = ref.watch(notificationServiceProvider);
  return AlertsNotifier(notificationService);
});

/// Provider that efficiently watches sensors and settings to trigger alerts
final sensorMonitorServiceProvider = Provider<SensorWatcher>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final alertsNotifier = ref.read(alertsProvider.notifier);

  // Instantiate the logic layer
  final watcher = SensorWatcher(notificationService, alertsNotifier, ref);

  // 1. Listen to Sensor Changes
  // Reacts when new sensor data arrives. Uses the *latest* settings.
  ref.listen<AsyncValue<SensorsModel>>(sensorsStreamProvider, (prev, next) {
    next.whenData((sensors) {
      final settings = ref.read(settingsStreamProvider).valueOrNull;
      if (settings != null) {
        final languageCode = ref.read(localeProvider).languageCode;
        final loc = lookupAppLocalizations(Locale(languageCode.toLowerCase()));
        watcher.checkSensors(sensors, settings, loc);
      }
    });
  });

  // 2. Listen to Settings Changes (FIX for Real-Time Sync)
  // Reacts when thresholds are updated. Uses the *latest* sensor data.
  ref.listen<AsyncValue<SettingsModel>>(settingsStreamProvider, (prev, next) {
    next.whenData((settings) {
      final sensors = ref.read(sensorsStreamProvider).valueOrNull;
      if (sensors != null) {
        final languageCode = ref.read(localeProvider).languageCode;
        final loc = lookupAppLocalizations(Locale(languageCode.toLowerCase()));
        watcher.checkSensors(sensors, settings, loc);
      }
    });
  });

  return watcher;
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
