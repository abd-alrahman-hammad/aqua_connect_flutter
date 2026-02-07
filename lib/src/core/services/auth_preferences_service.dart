import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing authentication-related preferences
///
/// Handles persisting the "Remember Me" state and other auth settings locally.
class AuthPreferencesService {
  static const String _keyRememberMe = 'auth_remember_me';

  /// Saves the user's "Remember Me" preference
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, value);
  }

  /// Retrieves the user's "Remember Me" preference
  ///
  /// Returns `false` if not set. Auto-login only when user explicitly enabled Remember Me.
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Clears all auth-related preferences
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
  }
}

/// Provider for [AuthPreferencesService]
final authPreferencesServiceProvider = Provider<AuthPreferencesService>((ref) {
  return AuthPreferencesService();
});
