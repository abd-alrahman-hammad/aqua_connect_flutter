/// Model representing sensor readings from the hydroponic system.
///
/// This model maps to the `/Sensors` node in Firebase Realtime Database.
/// Tracks water level, temperature, pH, and EC.
///
/// Schema:
/// - `/Sensors/water_level` (Int 0-100) -> int? waterLevel
/// - `/Sensors/temperature` (Float) -> double? temperature
/// - `/Sensors/ph_value` (Float) -> double? ph
/// - `/Sensors/ec_value` (Float) -> double? ec
class SensorsModel {
  /// Current water level as a percentage (0-100)
  /// - null: No data available (display as --)
  /// - 0: Tank is empty
  /// - 100: Tank is full
  final int? waterLevel;

  /// Current water temperature in Celsius
  final double? temperature;

  /// Current pH value (0-14)
  final double? ph;

  /// Electrical Conductivity in mS/cm
  final double? ec;

  /// Creates a new [SensorsModel] instance
  const SensorsModel({this.waterLevel, this.temperature, this.ph, this.ec});

  /// Creates a [SensorsModel] with default values (empty/zero)
  const SensorsModel.initial()
    : waterLevel = 0,
      temperature = 0.0,
      ph = 0.0,
      ec = 0.0;

  /// Whether water level data is available
  bool get hasWaterLevel => waterLevel != null;

  /// Whether temperature data is available
  bool get hasTemperature => temperature != null;

  /// Whether pH data is available
  bool get hasPh => ph != null;

  /// Whether EC data is available
  bool get hasEc => ec != null;

  /// Creates a [SensorsModel] from a JSON map
  ///
  /// Handles type conversion and ensures value is clamped to 0-100 range.
  /// Preserves null when the key is missing or value is null.
  ///
  /// Example JSON from Firebase:
  /// ```json
  /// {
  ///   "water_level": 75,
  ///   "temperature": 24.5,
  ///   "ph_value": 6.5,
  ///   "ec_value": 1.2
  /// }
  /// ```
  factory SensorsModel.fromJson(Map<dynamic, dynamic> json) {
    return SensorsModel(
      waterLevel: _parseInt(json['water_level']),
      temperature: _parseDouble(json['temperature']),
      ph: _parseDouble(json['ph_value']),
      ec: _parseDouble(json['ec_value']),
    );
  }

  /// Converts the model to a JSON map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'water_level': waterLevel,
      'temperature': temperature,
      'ph_value': ph,
      'ec_value': ec,
    };
  }

  /// Creates a copy of this model with updated values
  SensorsModel copyWith({
    int? waterLevel,
    double? temperature,
    double? ph,
    double? ec,
  }) {
    return SensorsModel(
      waterLevel: waterLevel ?? this.waterLevel,
      temperature: temperature ?? this.temperature,
      ph: ph ?? this.ph,
      ec: ec ?? this.ec,
    );
  }

  // ============================================================================
  // Helper Methods for Water Level Status
  // ============================================================================

  /// Returns true if water level is critically low (< 20%)
  ///
  /// At this level, immediate action is required to prevent damage
  /// to pumps and plants.
  bool get isCriticallyLow => (waterLevel ?? 0) < 20;

  /// Returns true if water level is low (< 40%)
  ///
  /// At this level, the system should alert the user to refill soon.
  bool get isLow => (waterLevel ?? 0) < 40;

  /// Returns true if water level is optimal (60-100%)
  ///
  /// This is the ideal operating range for the hydroponic system.
  bool get isOptimal => (waterLevel ?? 0) >= 60;

  /// Returns a user-friendly status message for the water level
  String get statusMessage {
    if (waterLevel == null) return 'No data available';
    if (isCriticallyLow) {
      return 'Critical: Water level very low ($waterLevel%)';
    } else if (isLow) {
      return 'Warning: Water level low ($waterLevel%)';
    } else if (isOptimal) {
      return 'Good: Water level optimal ($waterLevel%)';
    } else {
      return 'Moderate: Water level adequate ($waterLevel%)';
    }
  }

  /// Returns a color indicator for UI display
  ///
  /// - Critical (< 20%): Red
  /// - Low (< 40%): Orange
  /// - Moderate (40-60%): Yellow
  /// - Optimal (>= 60%): Green
  String get statusColor {
    if (isCriticallyLow) return 'red';
    if (isLow) return 'orange';
    if (isOptimal) return 'green';
    return 'yellow';
  }

  /// Helper method to parse integer values from Firebase
  ///
  /// Handles multiple input types and clamps value to 0-100 range:
  /// - `int`: direct mapping (clamped)
  /// - `double`: converts to int (clamped)
  /// - `String`: attempts to parse (clamped)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.toInt().clamp(0, 100);
    if (value is String) return (int.tryParse(value) ?? 0).clamp(0, 100);
    return null;
  }

  /// Helper method to parse double values from Firebase
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'SensorsModel(level: $waterLevel%, temp: $temperature°C, pH: $ph, EC: $ec)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SensorsModel &&
        other.waterLevel == waterLevel &&
        other.temperature == temperature &&
        other.ph == ph &&
        other.ec == ec;
  }

  @override
  int get hashCode => Object.hash(waterLevel, temperature, ph, ec);
}
