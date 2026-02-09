import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for notification preferences (Currently Mock/Default)
/// In a real app, this would be a StateNotifier or StreamProvider linked to local storage/backend
final notificationPreferencesProvider = StateProvider<NotificationPreferences>((
  ref,
) {
  return const NotificationPreferences();
});

class NotificationPreferences {
  final bool pushEnabled;
  final bool criticalAlertsEnabled;
  final bool parameterWarningsEnabled;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.criticalAlertsEnabled = true,
    this.parameterWarningsEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? criticalAlertsEnabled,
    bool? parameterWarningsEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      criticalAlertsEnabled:
          criticalAlertsEnabled ?? this.criticalAlertsEnabled,
      parameterWarningsEnabled:
          parameterWarningsEnabled ?? this.parameterWarningsEnabled,
    );
  }
}
