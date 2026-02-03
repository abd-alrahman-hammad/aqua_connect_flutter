/// Model representing the control settings for the hydroponic system.
///
/// This model maps to the `/Controls` node in Firebase Realtime Database.
/// It handles the conversion between Firebase's integer representation (0/1)
/// and Dart's boolean type for better type safety.
///
/// Schema:
/// - `/Controls/auto_mode` (Int 0/1) → bool autoMode
/// - `/Controls/led_light` (Int 0/1) → bool ledLight
class ControlsModel {
  /// Whether the system is in automatic mode
  /// - `true` (1): System controls pumps/lights automatically
  /// - `false` (0): Manual control mode
  final bool autoMode;

  /// Whether the LED grow light is currently on
  /// - `true` (1): LED light is on
  /// - `false` (0): LED light is off
  final bool ledLight;

  /// Creates a new [ControlsModel] instance
  const ControlsModel({required this.autoMode, required this.ledLight});

  /// Creates a [ControlsModel] with default values (all off/disabled)
  const ControlsModel.initial() : autoMode = false, ledLight = false;

  /// Creates a [ControlsModel] from a JSON map
  ///
  /// Handles three cases for boolean conversion:
  /// 1. Integer values: 0 = false, 1 = true
  /// 2. Boolean values: direct mapping
  /// 3. Null values: defaults to false
  ///
  /// Example JSON from Firebase:
  /// ```json
  /// {
  ///   "auto_mode": 1,
  ///   "led_light": 0
  /// }
  /// ```
  factory ControlsModel.fromJson(Map<dynamic, dynamic> json) {
    return ControlsModel(
      autoMode: _parseBool(json['auto_mode']),
      ledLight: _parseBool(json['led_light']),
    );
  }

  /// Converts the model to a JSON map for Firebase
  ///
  /// Converts boolean values to integers for Firebase compatibility:
  /// - `true` → 1
  /// - `false` → 0
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "auto_mode": 1,
  ///   "led_light": 0
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return {'auto_mode': autoMode ? 1 : 0, 'led_light': ledLight ? 1 : 0};
  }

  /// Creates a copy of this model with updated values
  ///
  /// Useful for updating individual control settings without
  /// mutating the original instance.
  ControlsModel copyWith({bool? autoMode, bool? ledLight}) {
    return ControlsModel(
      autoMode: autoMode ?? this.autoMode,
      ledLight: ledLight ?? this.ledLight,
    );
  }

  /// Helper method to parse boolean values from Firebase
  ///
  /// Handles multiple input types:
  /// - `int`: 0 = false, any other value = true
  /// - `bool`: direct mapping
  /// - `String`: "0" or "false" = false, otherwise true
  /// - `null`: defaults to false
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower != '0' && lower != 'false';
    }
    return false;
  }

  @override
  String toString() {
    return 'ControlsModel(autoMode: $autoMode, ledLight: $ledLight)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ControlsModel &&
        other.autoMode == autoMode &&
        other.ledLight == ledLight;
  }

  @override
  int get hashCode => autoMode.hashCode ^ ledLight.hashCode;
}
