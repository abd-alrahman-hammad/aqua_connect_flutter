import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  final SharedPreferences? _prefs;

  NotificationPreferencesNotifier(this._prefs) : super(_loadFromPrefs(_prefs));

  static const _pushKey = 'pref_push_enabled';
  static const _criticalKey = 'pref_critical_enabled';
  static const _warningsKey = 'pref_warnings_enabled';
  static const _waterKey = 'pref_water_enabled';

  static NotificationPreferences _loadFromPrefs(SharedPreferences? prefs) {
    if (prefs == null) return const NotificationPreferences();
    return NotificationPreferences(
      pushEnabled: prefs.getBool(_pushKey) ?? true,
      criticalAlertsEnabled: prefs.getBool(_criticalKey) ?? true,
      parameterWarningsEnabled: prefs.getBool(_warningsKey) ?? true,
      waterLevelNotificationsEnabled: prefs.getBool(_waterKey) ?? true,
    );
  }

  Future<void> updatePrefs(NotificationPreferences newPrefs) async {
    state = newPrefs;
    if (_prefs != null) {
      await _prefs.setBool(_pushKey, newPrefs.pushEnabled);
      await _prefs.setBool(_criticalKey, newPrefs.criticalAlertsEnabled);
      await _prefs.setBool(_warningsKey, newPrefs.parameterWarningsEnabled);
      await _prefs.setBool(_waterKey, newPrefs.waterLevelNotificationsEnabled);
    }
  }
}

final notificationPreferencesProvider = StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier(null);
});

class NotificationPreferences {
  final bool pushEnabled;
  final bool criticalAlertsEnabled;
  final bool parameterWarningsEnabled;
  final bool waterLevelNotificationsEnabled;

  const NotificationPreferences({
    this.pushEnabled = true,
    this.criticalAlertsEnabled = true,
    this.parameterWarningsEnabled = true,
    this.waterLevelNotificationsEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? criticalAlertsEnabled,
    bool? parameterWarningsEnabled,
    bool? waterLevelNotificationsEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      criticalAlertsEnabled:
          criticalAlertsEnabled ?? this.criticalAlertsEnabled,
      parameterWarningsEnabled:
          parameterWarningsEnabled ?? this.parameterWarningsEnabled,
      waterLevelNotificationsEnabled:
          waterLevelNotificationsEnabled ?? this.waterLevelNotificationsEnabled,
    );
  }
}
