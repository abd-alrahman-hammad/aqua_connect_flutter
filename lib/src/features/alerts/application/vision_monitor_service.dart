import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/services/sensors_repository.dart';
import '../../../core/models/db/live_monitoring_model.dart';
import '../data/notification_service.dart';
import 'sensor_monitor_service.dart';
import 'vision_watcher.dart';

final visionMonitorServiceProvider = Provider<VisionWatcher>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  final alertsNotifier = ref.read(alertsProvider.notifier);

  final watcher = VisionWatcher(notificationService, alertsNotifier, ref);

  ref.listen<AsyncValue<LiveMonitoringModel>>(liveMonitoringStreamProvider, (prev, next) {
    next.whenData((model) {
      final languageCode = ref.read(localeProvider).languageCode;
      final loc = lookupAppLocalizations(Locale(languageCode.toLowerCase()));
      watcher.checkVision(model, loc);
    });
  });

  return watcher;
});
