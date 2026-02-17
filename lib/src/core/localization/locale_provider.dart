import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(const Locale('en')) {
    _loadLocale();
  }

  final SharedPreferences _prefs;
  static const _localeKey = 'selected_locale';

  void _loadLocale() {
    final languageCode = _prefs.getString(_localeKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  // We need to access SharedPreferences.
  // Since we don't have a direct provider for it in this scope typically,
  // we might need to pass it in or rely on a main.dart override.
  // However, for now, we will assume it is passed via override in main.dart
  // OR we can fetch it if we had a provider.
  // Given main.dart initialized SharedPreferences, we should probably
  // allow this to be overridden or injected.
  throw UnimplementedError('localeProvider must be overridden in main.dart');
});
