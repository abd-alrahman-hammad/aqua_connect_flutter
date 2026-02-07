import 'package:flutter/material.dart';
import '../models/hydroponic/sensors_model.dart';
import '../models/hydroponic/settings_model.dart';
import '../theme/aqua_colors.dart';

/// Enum representing the status of a single sensor
enum SensorStatus { ok, warning, critical, unknown }

/// Utility class for calculating system vitality and sensor status.
class VitalityUtils {
  VitalityUtils._();

  /// Calculates the overall vitality score (0.0 to 1.0) of the system.
  ///
  /// The score is determined by the percentage of sensors that are in the 'OK' state.
  /// - Water Level
  /// - Temperature
  /// - pH
  /// - EC
  static double calculateVitality(
    SensorsModel sensors,
    SettingsModel settings,
  ) {
    int totalSensors = 0;
    int okSensors = 0;

    // Check Water Level
    if (sensors.hasWaterLevel) {
      totalSensors++;
      if (sensors.isOptimal) {
        okSensors++;
      } else if (sensors.isLow) {
        // Give partial credit for "Low" but not "Critical" if needed,
        // but for now let's keep it strict: Optimal = 1 point.
        // Or maybe weighted? Let's stick to simple "isOptimal" check for now.
        // Actually, let's use the status logic:
        if (getWaterLevelStatus(sensors.waterLevel) == SensorStatus.ok) {
          okSensors++;
        }
      }
    }

    // Check Temperature
    if (sensors.hasTemperature &&
        settings.tempHigh != null &&
        settings.tempLow != null) {
      totalSensors++;
      if (getTemperatureStatus(sensors.temperature, settings) ==
          SensorStatus.ok) {
        okSensors++;
      }
    }

    // Check pH
    if (sensors.hasPh && settings.phHigh != null && settings.phLow != null) {
      totalSensors++;
      if (getPhStatus(sensors.ph, settings) == SensorStatus.ok) {
        okSensors++;
      }
    }

    // Check EC
    if (sensors.hasEc && settings.ecHigh != null && settings.ecLow != null) {
      totalSensors++;
      if (getEcStatus(sensors.ec, settings) == SensorStatus.ok) {
        okSensors++;
      }
    }

    if (totalSensors == 0) return 0.0;
    return okSensors / totalSensors;
  }

  /// Determines the status of the water level.
  static SensorStatus getWaterLevelStatus(int? level) {
    if (level == null) return SensorStatus.unknown;
    if (level < 20) return SensorStatus.critical;
    if (level < 40) return SensorStatus.warning;
    return SensorStatus.ok;
  }

  /// Determines the status of the temperature reading.
  static SensorStatus getTemperatureStatus(
    double? temp,
    SettingsModel settings,
  ) {
    if (temp == null || settings.tempHigh == null || settings.tempLow == null) {
      return SensorStatus.unknown;
    }

    if (temp > settings.tempHigh! || temp < settings.tempLow!) {
      // If outside the range (heater or fan limits)
      // Depending on how far out, we could say critical.
      // For now, let's say if it deviates significantly (e.g. +/- 2 degrees) it's critical, else warning.
      // But strictly following the request: "correct ratios".
      // Simple logic: Out of range = Warning/Critical.
      return SensorStatus.warning;
    }
    return SensorStatus.ok;
  }

  /// Determines the status of the pH reading.
  static SensorStatus getPhStatus(double? ph, SettingsModel settings) {
    if (ph == null || settings.phHigh == null || settings.phLow == null) {
      return SensorStatus.unknown;
    }

    if (ph > settings.phHigh! || ph < settings.phLow!) {
      return SensorStatus.warning;
    }
    return SensorStatus.ok;
  }

  /// Determines the status of the EC reading.
  static SensorStatus getEcStatus(double? ec, SettingsModel settings) {
    if (ec == null || settings.ecHigh == null || settings.ecLow == null) {
      return SensorStatus.unknown;
    }

    if (ec > settings.ecHigh! || ec < settings.ecLow!) {
      return SensorStatus.warning;
    }
    return SensorStatus.ok;
  }

  /// Returns the display text for a given status.
  static String getStatusLabel(SensorStatus status) {
    switch (status) {
      case SensorStatus.ok:
        return 'OK';
      case SensorStatus.warning:
        return 'WARNING';
      case SensorStatus.critical:
        return 'CRITICAL';
      case SensorStatus.unknown:
        return '--';
    }
  }

  /// Returns the color for a given status.
  static Color getStatusColor(SensorStatus status) {
    switch (status) {
      case SensorStatus.ok:
        return AquaColors.success; // Green
      case SensorStatus.warning:
        return AquaColors.warning; // Orange
      case SensorStatus.critical:
        return AquaColors.error; // Red
      case SensorStatus.unknown:
        return AquaColors.slate400; // Grey
    }
  }

  /// Generates a descriptive message based on the system's current vitality.
  static String getVitalityMessage(
    SensorsModel? sensors,
    SettingsModel? settings, {
    bool isSystemOnline = true,
  }) {
    if (!isSystemOnline) {
      return 'System Offline';
    }

    if (sensors == null || settings == null) {
      return 'Waiting for data...';
    }

    final issues = <String>[];

    // Check Water Level
    final waterStatus = getWaterLevelStatus(sensors.waterLevel);
    if (waterStatus == SensorStatus.critical) {
      issues.add('Critical: Low Water');
    } else if (waterStatus == SensorStatus.warning) {
      issues.add('Low Water');
    }

    // Check Temperature
    final tempStatus = getTemperatureStatus(sensors.temperature, settings);
    if (tempStatus != SensorStatus.ok && tempStatus != SensorStatus.unknown) {
      issues.add('Temp Unstable');
    }

    // Check pH
    final phStatus = getPhStatus(sensors.ph, settings);
    if (phStatus != SensorStatus.ok && phStatus != SensorStatus.unknown) {
      issues.add('pH Unstable');
    }

    // Check EC
    final ecStatus = getEcStatus(sensors.ec, settings);
    if (ecStatus != SensorStatus.ok && ecStatus != SensorStatus.unknown) {
      issues.add('Ec Unstable');
    }

    if (issues.isEmpty) {
      return 'System Nominal';
    } else {
      return issues.join(" • ");
    }
  }
}
