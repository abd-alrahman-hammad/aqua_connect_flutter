/// Model representing sensor readings from the hydroponic system.
///
/// This model maps to the `/Sensors` node in Firebase Realtime Database.
/// Currently tracks water level, but can be extended for additional sensors
/// like temperature, pH, EC, etc.
///
/// Schema:
/// - `/Sensors/water_level` (Int 0-100) → int waterLevel
class SensorsModel {
  /// Current water level as a percentage (0-100)
  /// - 0: Tank is empty
  /// - 100: Tank is full
  final int waterLevel;

  /// Creates a new [SensorsModel] instance
  const SensorsModel({required this.waterLevel});

  /// Creates a [SensorsModel] with default values (empty tank)
  const SensorsModel.initial() : waterLevel = 0;

  /// Creates a [SensorsModel] with full tank
  const SensorsModel.full() : waterLevel = 100;

  /// Creates a [SensorsModel] from a JSON map
  ///
  /// Handles type conversion and ensures value is clamped to 0-100 range.
  ///
  /// Example JSON from Firebase:
  /// ```json
  /// {
  ///   "water_level": 75
  /// }
  /// ```
  factory SensorsModel.fromJson(Map<dynamic, dynamic> json) {
    return SensorsModel(waterLevel: _parseInt(json['water_level'], 0));
  }

  /// Converts the model to a JSON map for Firebase
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "water_level": 75
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return {'water_level': waterLevel};
  }

  /// Creates a copy of this model with updated values
  SensorsModel copyWith({int? waterLevel}) {
    return SensorsModel(waterLevel: waterLevel ?? this.waterLevel);
  }

  // ============================================================================
  // Helper Methods for Water Level Status
  // ============================================================================

  /// Returns true if water level is critically low (< 20%)
  ///
  /// At this level, immediate action is required to prevent damage
  /// to pumps and plants.
  bool get isCriticallyLow => waterLevel < 20;

  /// Returns true if water level is low (< 40%)
  ///
  /// At this level, the system should alert the user to refill soon.
  bool get isLow => waterLevel < 40;

  /// Returns true if water level is optimal (60-100%)
  ///
  /// This is the ideal operating range for the hydroponic system.
  bool get isOptimal => waterLevel >= 60;

  /// Returns a user-friendly status message for the water level
  String get statusMessage {
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
  /// - `null`: returns default value
  static int _parseInt(dynamic value, int defaultValue) {
    int result = defaultValue;

    if (value == null) {
      result = defaultValue;
    } else if (value is int) {
      result = value;
    } else if (value is double) {
      result = value.toInt();
    } else if (value is String) {
      result = int.tryParse(value) ?? defaultValue;
    }

    // Clamp to 0-100 range
    return result.clamp(0, 100);
  }

  @override
  String toString() {
    return 'SensorsModel(waterLevel: $waterLevel%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SensorsModel && other.waterLevel == waterLevel;
  }

  @override
  int get hashCode => waterLevel.hashCode;
}
