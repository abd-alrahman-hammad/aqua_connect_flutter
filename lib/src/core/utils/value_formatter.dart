/// Shared utility for consistent null handling across the app.
///
/// Use these functions to display `--` when values are null,
/// ensuring a unified UX for missing or unavailable data.
class ValueFormatter {
  ValueFormatter._();

  /// Placeholder string shown when a value is null or unavailable.
  static const String nullPlaceholder = '--';

  /// Formats a nullable value, returning [nullPlaceholder] when null.
  static String formatValue<T>(T? value, String Function(T) formatter) {
    if (value == null) return nullPlaceholder;
    return formatter(value);
  }

  /// Formats a nullable int.
  static String formatInt(int? value) =>
      formatValue(value, (v) => v.toString());

  /// Formats a nullable double with optional decimal places.
  static String formatDouble(double? value, {int decimalPlaces = 1}) =>
      formatValue(value, (v) => v.toStringAsFixed(decimalPlaces));

  /// Formats a nullable int as a percentage (0-100).
  static String formatPercent(int? value) => formatValue(value, (v) => '$v%');

  /// Formats a nullable value with a suffix (e.g. '°C', 'pH').
  static String formatWithSuffix<T>(T? value, String suffix) =>
      formatValue(value, (v) => '$v$suffix');
}
