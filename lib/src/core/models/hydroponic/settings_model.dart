/// Model representing the threshold settings for the hydroponic system.
///
/// This model maps to the `/Settings` node in Firebase Realtime Database.
/// It stores the high and low thresholds for temperature, pH, and EC monitoring.
///
/// Schema:
/// - `/Settings/temp_high` (Float) → double tempHigh
/// - `/Settings/temp_low` (Float) → double tempLow
/// - `/Settings/ph_high` (Float) → double phHigh
/// - `/Settings/ec_low` (Float) → double ecLow
class SettingsModel {
  /// High temperature threshold in Celsius
  /// When sensor reading exceeds this, alerts may trigger
  final double tempHigh;

  /// Low temperature threshold in Celsius
  /// When sensor reading falls below this, alerts may trigger
  final double tempLow;

  /// High pH threshold
  /// Ideal pH for most hydroponic systems is 5.5-6.5
  /// When pH exceeds this, alerts may trigger
  final double phHigh;

  /// Low EC (Electrical Conductivity) threshold in mS/cm
  /// EC measures nutrient concentration in the water
  /// When EC falls below this, alerts may trigger
  final double ecLow;

  /// Creates a new [SettingsModel] instance
  const SettingsModel({
    required this.tempHigh,
    required this.tempLow,
    required this.phHigh,
    required this.ecLow,
  });

  /// Creates a [SettingsModel] with sensible default values for hydroponics
  ///
  /// Default thresholds:
  /// - Temperature: 18°C - 26°C (ideal range for most crops)
  /// - pH: 6.5 max (ideal is 5.5-6.5)
  /// - EC: 1.2 mS/cm minimum (sufficient nutrient concentration)
  const SettingsModel.defaults()
    : tempHigh = 26.0,
      tempLow = 18.0,
      phHigh = 6.5,
      ecLow = 1.2;

  /// Creates a [SettingsModel] from a JSON map
  ///
  /// Handles type conversion from various numeric types (int, double)
  /// and provides default values if data is missing.
  ///
  /// Example JSON from Firebase:
  /// ```json
  /// {
  ///   "temp_high": 26.5,
  ///   "temp_low": 18.0,
  ///   "ph_high": 6.5,
  ///   "ec_low": 1.2
  /// }
  /// ```
  factory SettingsModel.fromJson(Map<dynamic, dynamic> json) {
    return SettingsModel(
      tempHigh: _parseDouble(json['temp_high'], 26.0),
      tempLow: _parseDouble(json['temp_low'], 18.0),
      phHigh: _parseDouble(json['ph_high'], 6.5),
      ecLow: _parseDouble(json['ec_low'], 1.2),
    );
  }

  /// Converts the model to a JSON map for Firebase
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "temp_high": 26.5,
  ///   "temp_low": 18.0,
  ///   "ph_high": 6.5,
  ///   "ec_low": 1.2
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'temp_high': tempHigh,
      'temp_low': tempLow,
      'ph_high': phHigh,
      'ec_low': ecLow,
    };
  }

  /// Creates a copy of this model with updated values
  SettingsModel copyWith({
    double? tempHigh,
    double? tempLow,
    double? phHigh,
    double? ecLow,
  }) {
    return SettingsModel(
      tempHigh: tempHigh ?? this.tempHigh,
      tempLow: tempLow ?? this.tempLow,
      phHigh: phHigh ?? this.phHigh,
      ecLow: ecLow ?? this.ecLow,
    );
  }

  /// Validates that all thresholds are within acceptable ranges
  ///
  /// Returns a list of validation error messages.
  /// Empty list means all values are valid.
  List<String> validate() {
    final errors = <String>[];

    // Temperature validation (0-50°C is reasonable for hydroponics)
    if (tempHigh < tempLow) {
      errors.add('High temperature must be greater than low temperature');
    }
    if (tempHigh < 0 || tempHigh > 50) {
      errors.add('High temperature must be between 0°C and 50°C');
    }
    if (tempLow < 0 || tempLow > 50) {
      errors.add('Low temperature must be between 0°C and 50°C');
    }

    // pH validation (0-14 is the pH scale)
    if (phHigh < 0 || phHigh > 14) {
      errors.add('pH must be between 0 and 14');
    }

    // EC validation (0-10 mS/cm is typical range)
    if (ecLow < 0 || ecLow > 10) {
      errors.add('EC must be between 0 and 10 mS/cm');
    }

    return errors;
  }

  /// Returns true if all settings are valid
  bool get isValid => validate().isEmpty;

  /// Helper method to parse double values from Firebase
  ///
  /// Handles multiple input types:
  /// - `double`: direct mapping
  /// - `int`: converts to double
  /// - `String`: attempts to parse
  /// - `null`: returns default value
  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  String toString() {
    return 'SettingsModel(tempHigh: $tempHigh, tempLow: $tempLow, '
        'phHigh: $phHigh, ecLow: $ecLow)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsModel &&
        other.tempHigh == tempHigh &&
        other.tempLow == tempLow &&
        other.phHigh == phHigh &&
        other.ecLow == ecLow;
  }

  @override
  int get hashCode {
    return tempHigh.hashCode ^
        tempLow.hashCode ^
        phHigh.hashCode ^
        ecLow.hashCode;
  }
}
