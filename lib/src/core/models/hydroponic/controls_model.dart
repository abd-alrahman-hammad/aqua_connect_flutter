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

  /// Whether the water pump is on
  final bool waterPump;

  /// Whether the ventilation fan is on
  final bool fan;

  /// Whether the heater is on
  final bool heater;

  /// Whether the pH Up pump is on
  final bool pumpPhUp;

  /// Whether the pH Down pump is on
  final bool pumpPhDown;

  /// Whether the EC Up pump is on
  final bool pumpEcUp;

  /// Whether the EC Down pump is on
  final bool pumpEcDown;

  /// Creates a new [ControlsModel] instance
  const ControlsModel({
    required this.autoMode,
    required this.ledLight,
    required this.waterPump,
    required this.fan,
    required this.heater,
    required this.pumpPhUp,
    required this.pumpPhDown,
    required this.pumpEcUp,
    required this.pumpEcDown,
  });

  /// Creates a [ControlsModel] with default values (all off/disabled)
  const ControlsModel.initial()
    : autoMode = false,
      ledLight = false,
      waterPump = false,
      fan = false,
      heater = false,
      pumpPhUp = false,
      pumpPhDown = false,
      pumpEcUp = false,
      pumpEcDown = false;

  /// Creates a [ControlsModel] from a JSON map
  factory ControlsModel.fromJson(Map<dynamic, dynamic> json) {
    return ControlsModel(
      autoMode: _parseBool(json['auto_mode']),
      ledLight: _parseBool(json['led_light']),
      waterPump: _parseBool(json['water_pump']),
      fan: _parseBool(json['fan']),
      heater: _parseBool(json['heater']),
      pumpPhUp: _parseBool(json['pump_ph_up']),
      pumpPhDown: _parseBool(json['pump_ph_down']),
      pumpEcUp: _parseBool(json['pump_ec_up']),
      pumpEcDown: _parseBool(json['pump_ec_down']),
    );
  }

  /// Converts the model to a JSON map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'auto_mode': autoMode ? 1 : 0,
      'led_light': ledLight ? 1 : 0,
      'water_pump': waterPump ? 1 : 0,
      'fan': fan ? 1 : 0,
      'heater': heater ? 1 : 0,
      'pump_ph_up': pumpPhUp ? 1 : 0,
      'pump_ph_down': pumpPhDown ? 1 : 0,
      'pump_ec_up': pumpEcUp ? 1 : 0,
      'pump_ec_down': pumpEcDown ? 1 : 0,
    };
  }

  /// Creates a copy of this model with updated values
  ControlsModel copyWith({
    bool? autoMode,
    bool? ledLight,
    bool? waterPump,
    bool? fan,
    bool? heater,
    bool? pumpPhUp,
    bool? pumpPhDown,
    bool? pumpEcUp,
    bool? pumpEcDown,
  }) {
    return ControlsModel(
      autoMode: autoMode ?? this.autoMode,
      ledLight: ledLight ?? this.ledLight,
      waterPump: waterPump ?? this.waterPump,
      fan: fan ?? this.fan,
      heater: heater ?? this.heater,
      pumpPhUp: pumpPhUp ?? this.pumpPhUp,
      pumpPhDown: pumpPhDown ?? this.pumpPhDown,
      pumpEcUp: pumpEcUp ?? this.pumpEcUp,
      pumpEcDown: pumpEcDown ?? this.pumpEcDown,
    );
  }

  // ... _parseBool helper remains the same ...

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
    return 'ControlsModel(autoMode: $autoMode, ledLight: $ledLight, waterPump: $waterPump, fan: $fan, heater: $heater, pumpPhUp: $pumpPhUp, pumpPhDown: $pumpPhDown, pumpEcUp: $pumpEcUp, pumpEcDown: $pumpEcDown)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ControlsModel &&
        other.autoMode == autoMode &&
        other.ledLight == ledLight &&
        other.waterPump == waterPump &&
        other.fan == fan &&
        other.heater == heater &&
        other.pumpPhUp == pumpPhUp &&
        other.pumpPhDown == pumpPhDown &&
        other.pumpEcUp == pumpEcUp &&
        other.pumpEcDown == pumpEcDown;
  }

  @override
  int get hashCode =>
      autoMode.hashCode ^
      ledLight.hashCode ^
      waterPump.hashCode ^
      fan.hashCode ^
      heater.hashCode ^
      pumpPhUp.hashCode ^
      pumpPhDown.hashCode ^
      pumpEcUp.hashCode ^
      pumpEcDown.hashCode;
}
