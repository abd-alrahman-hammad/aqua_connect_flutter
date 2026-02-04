/// Model representing the threshold settings for the hydroponic system.
///
/// This model maps to the `/Settings` node in Firebase Realtime Database.
/// It stores the high and low thresholds for temperature, pH, and EC monitoring.
///
/// Schema:
/// - `/Settings/temp_high` (Float) -> double tempHigh
/// - `/Settings/temp_low` (Float) -> double tempLow
/// - `/Settings/ph_high` (Float) -> double phHigh
/// - `/Settings/ph_low` (Float) -> double phLow
/// - `/Settings/ec_high` (Float) -> double ecHigh
/// - `/Settings/ec_low` (Float) -> double ecLow
class SettingsModel {
  /// High temperature threshold in Celsius (Fan operating limit)
  /// When sensor reading exceeds this, alerts may trigger
  /// null: No data available (display as --)
  final double? tempHigh;

  /// Low temperature threshold in Celsius (Heater operating limit)
  /// When sensor reading falls below this, alerts may trigger
  /// null: No data available (display as --)
  final double? tempLow;

  /// High pH threshold (pH Down pump trigger)
  // Ideal: 6.5
  /// null: No data available (display as --)
  final double? phHigh;

  /// Low pH threshold (pH Up pump trigger)
  // Ideal: 5.5
  /// null: No data available (display as --)
  final double? phLow;

  /// High EC threshold (Nutrient pump OFF trigger - preventing burn)
  // Ideal: 2.5
  /// null: No data available (display as --)
  final double? ecHigh;

  /// Low EC threshold (Nutrient pump ON trigger - feeding)
  // Ideal: 1.2
  /// null: No data available (display as --)
  final double? ecLow;

  /// Creates a new [SettingsModel] instance
  const SettingsModel({
    this.tempHigh,
    this.tempLow,
    this.phHigh,
    this.phLow,
    this.ecHigh,
    this.ecLow,
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
      phLow = 5.5,
      ecHigh = 2.5,
      ecLow = 1.2;

  /// Creates a [SettingsModel] from a JSON map
  ///
  /// Handles type conversion from various numeric types (int, double)
  /// and preserves null for missing keys.
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
      tempHigh: _parseDoubleOrNull(json['temp_high']),
      tempLow: _parseDoubleOrNull(json['temp_low']),
      phHigh: _parseDoubleOrNull(json['ph_high']),
      phLow: _parseDoubleOrNull(json['ph_low']),
      ecHigh: _parseDoubleOrNull(json['ec_high']),
      ecLow: _parseDoubleOrNull(json['ec_low']),
    );
  }

  /// Converts the model to a JSON map for Firebase
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (tempHigh != null) map['temp_high'] = tempHigh!;
    if (tempLow != null) map['temp_low'] = tempLow!;
    if (phHigh != null) map['ph_high'] = phHigh!;
    if (phLow != null) map['ph_low'] = phLow!;
    if (ecHigh != null) map['ec_high'] = ecHigh!;
    if (ecLow != null) map['ec_low'] = ecLow!;
    return map;
  }

  /// Creates a copy of this model with updated values
  SettingsModel copyWith({
    double? tempHigh,
    double? tempLow,
    double? phHigh,
    double? phLow,
    double? ecHigh,
    double? ecLow,
  }) {
    return SettingsModel(
      tempHigh: tempHigh ?? this.tempHigh,
      tempLow: tempLow ?? this.tempLow,
      phHigh: phHigh ?? this.phHigh,
      phLow: phLow ?? this.phLow,
      ecHigh: ecHigh ?? this.ecHigh,
      ecLow: ecLow ?? this.ecLow,
    );
  }

  /// Validates that all thresholds are within acceptable ranges
  ///
  /// Returns a list of validation error messages.
  /// Empty list means all values are valid.
  /// Null values are skipped (allowed for optional fields).
  List<String> validate() {
    final errors = <String>[];

    // Temperature validation (0-50°C is reasonable for hydroponics)
    if (tempHigh != null && tempLow != null) {
      if (tempHigh! < tempLow!) {
        errors.add('High temperature must be greater than low temperature');
      }
    }
    if (tempHigh != null && (tempHigh! < 0 || tempHigh! > 50)) {
      errors.add('High temperature must be between 0°C and 50°C');
    }
    if (tempLow != null && (tempLow! < 0 || tempLow! > 50)) {
      errors.add('Low temperature must be between 0°C and 50°C');
    }

    // pH validation (0-14 is the pH scale)
    if (phHigh != null && phLow != null) {
      if (phHigh! < phLow!) {
        errors.add('High pH must be greater than low pH');
      }
    }
    if (phHigh != null && (phHigh! < 0 || phHigh! > 14)) {
      errors.add('High pH must be between 0 and 14');
    }
    if (phLow != null && (phLow! < 0 || phLow! > 14)) {
      errors.add('Low pH must be between 0 and 14');
    }

    // EC validation (0-10 mS/cm is typical range)
    if (ecHigh != null && ecLow != null) {
      if (ecHigh! < ecLow!) {
        errors.add('High EC must be greater than low EC');
      }
    }
    if (ecHigh != null && (ecHigh! < 0 || ecHigh! > 10)) {
      errors.add('High EC must be between 0 and 10 mS/cm');
    }
    if (ecLow != null && (ecLow! < 0 || ecLow! > 10)) {
      errors.add('Low EC must be between 0 and 10 mS/cm');
    }

    return errors;
  }

  /// Returns true if all settings are valid
  bool get isValid => validate().isEmpty;

  /// Helper method to parse double values from Firebase, preserving null.
  static double? _parseDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'SettingsModel(temp: $tempLow-$tempHigh, pH: $phLow-$phHigh, EC: $ecLow-$ecHigh)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsModel &&
        other.tempHigh == tempHigh &&
        other.tempLow == tempLow &&
        other.phHigh == phHigh &&
        other.phLow == phLow &&
        other.ecHigh == ecHigh &&
        other.ecLow == ecLow;
  }

  @override
  int get hashCode =>
      Object.hash(tempHigh, tempLow, phHigh, phLow, ecHigh, ecLow);
}
