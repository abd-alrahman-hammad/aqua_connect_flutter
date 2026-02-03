# Firebase Realtime Database Integration - Usage Guide

## Overview

This module provides a production-ready Firebase Realtime Database integration for the Rayyan hydroponic IoT system. It includes type-safe data models, real-time streams, and comprehensive error handling.

## Quick Start

### 1. Authentication

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rayyan/src/core/services/firebase_auth_service.dart';

// In your widget or controller
class LoginExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(firebaseAuthServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          // Sign in with test credentials
          final user = await authService.signInWithTestCredentials();
          print('Signed in as: ${user.email}');
        } on AuthException catch (e) {
          print('Login failed: $e');
        }
      },
      child: Text('Sign In'),
    );
  }
}
```

### 2. Watch Real-Time Data (Recommended)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rayyan/src/core/services/hydroponic_database_service.dart';

// Watch water level in real-time
class WaterLevelWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterLevelAsync = ref.watch(waterLevelStreamProvider);

    return waterLevelAsync.when(
      data: (level) => Text('Water Level: $level%'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// Watch all sensor data
class SensorDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsAsync = ref.watch(sensorsStreamProvider);

    return sensorsAsync.when(
      data: (sensors) {
        return Column(
          children: [
            Text('Water Level: ${sensors.waterLevel}%'),
            if (sensors.isCriticallyLow)
              Text('⚠️ CRITICAL: Refill immediately!'),
            Text('Status: ${sensors.statusMessage}'),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// Watch controls
class ControlPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlsAsync = ref.watch(controlsStreamProvider);

    return controlsAsync.when(
      data: (controls) {
        return Column(
          children: [
            SwitchListTile(
              title: Text('Auto Mode'),
              value: controls.autoMode,
              onChanged: (value) async {
                final dbService = ref.read(hydroponicDatabaseServiceProvider);
                await dbService.toggleAutoMode(value);
              },
            ),
            SwitchListTile(
              title: Text('LED Light'),
              value: controls.ledLight,
              onChanged: (value) async {
                final dbService = ref.read(hydroponicDatabaseServiceProvider);
                await dbService.toggleLedLight(value);
              },
            ),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 3. Update Controls

```dart
import 'package:rayyan/src/core/services/hydroponic_database_service.dart';

class ControlsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbService = ref.watch(hydroponicDatabaseServiceProvider);

    return Column(
      children: [
        // Toggle auto mode
        ElevatedButton(
          onPressed: () async {
            try {
              await dbService.toggleAutoMode(true);
              print('Auto mode enabled');
            } on DatabaseException catch (e) {
              print('Failed to update: $e');
            }
          },
          child: Text('Enable Auto Mode'),
        ),

        // Toggle LED light
        ElevatedButton(
          onPressed: () async {
            try {
              await dbService.toggleLedLight(true);
              print('LED light turned on');
            } on DatabaseException catch (e) {
              print('Failed to update: $e');
            }
          },
          child: Text('Turn On LED'),
        ),
      ],
    );
  }
}
```

### 4. Update Settings

```dart
import 'package:rayyan/src/core/models/hydroponic/settings_model.dart';
import 'package:rayyan/src/core/services/hydroponic_database_service.dart';

class SettingsExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbService = ref.watch(hydroponicDatabaseServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          // Update all settings at once
          final newSettings = SettingsModel(
            tempHigh: 26.0,
            tempLow: 18.0,
            phHigh: 6.5,
            ecLow: 1.2,
          );

          await dbService.updateSettings(newSettings);
          print('Settings updated');
        } on DatabaseException catch (e) {
          print('Failed to update settings: $e');
        }
      },
      child: Text('Update Settings'),
    );
  }
}

// Update individual settings
Future<void> updateTemperatureThresholds() async {
  final dbService = ref.read(hydroponicDatabaseServiceProvider);

  try {
    await dbService.updateTempThresholds(high: 28.0, low: 16.0);
  } on DatabaseException catch (e) {
    print('Failed: $e');
  }
}
```

### 5. One-Time Reads (when you don't need real-time updates)

```dart
Future<void> getCurrentValues() async {
  final dbService = ref.read(hydroponicDatabaseServiceProvider);

  try {
    // Get current controls
    final controls = await dbService.getControls();
    print('Auto mode: ${controls.autoMode}');

    // Get current settings
    final settings = await dbService.getSettings();
    print('Temp range: ${settings.tempLow}°C - ${settings.tempHigh}°C');

    // Get current sensors
    final sensors = await dbService.getSensors();
    print('Water level: ${sensors.waterLevel}%');
  } on DatabaseException catch (e) {
    print('Failed to fetch data: $e');
  }
}
```

## Data Models

### ControlsModel
- `autoMode` (bool) - System is in automatic mode
- `ledLight` (bool) - LED grow light is on

### SettingsModel
- `tempHigh` (double) - High temperature threshold (°C)
- `tempLow` (double) - Low temperature threshold (°C)
- `phHigh` (double) - High pH threshold
- `ecLow` (double) - Low EC threshold (mS/cm)

### SensorsModel
- `waterLevel` (int) - Water level percentage (0-100)
- Helper methods: `isCriticallyLow`, `isLow`, `isOptimal`
- `statusMessage` - User-friendly status text

## Error Handling

All methods include comprehensive error handling:

```dart
try {
  await dbService.toggleLedLight(true);
} on DatabaseException catch (e) {
  // Handle database errors (network, permissions, etc.)
  print('Database error: ${e.message}');
  if (e.code != null) {
    print('Error code: ${e.code}');
  }
} on AuthException catch (e) {
  // Handle authentication errors
  print('Auth error: ${e.message}');
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

## Firebase Console Setup

### 1. Create Test User

In Firebase Console → Authentication → Users:
- Add user: `test@test.com`
- Password: `123456`

### 2. Database Rules

Set up appropriate security rules in Firebase Realtime Database:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "Controls": {
      ".validate": "newData.hasChildren(['auto_mode', 'led_light'])"
    },
    "Settings": {
      ".validate": "newData.hasChildren(['temp_high', 'temp_low', 'ph_high', 'ec_low'])"
    },
    "Sensors": {
      ".validate": "newData.hasChildren(['water_level'])"
    }
  }
}
```

## Testing

### Manual Testing Steps

1. **Test Authentication**
   ```dart
   final authService = ref.read(firebaseAuthServiceProvider);
   await authService.signInWithTestCredentials();
   ```

2. **Test Control Updates**
   ```dart
   final dbService = ref.read(hydroponicDatabaseServiceProvider);
   await dbService.toggleLedLight(true);
   ```

3. **Verify in Firebase Console**
   - Navigate to Realtime Database
   - Confirm values are updating

4. **Test Real-Time Streams**
   - Manually change values in Firebase Console
   - Confirm UI updates automatically

## Troubleshooting

### Firebase Not Initialized
```
Error: Firebase has not been initialized
```
**Solution:** Ensure `FirebaseInitializer.initialize()` is called in `main()` before `runApp()`

### Authentication Failed
```
AuthException: No user found with email: test@test.com
```
**Solution:** Create the test user in Firebase Console → Authentication

### Database Permission Denied
```
DatabaseException: Permission denied
```
**Solution:** 
1. Ensure user is authenticated
2. Check Firebase Database Rules allow authenticated access

### Network Error
```
AuthException: Network error
```
**Solution:** Check internet connection and Firebase configuration

## Best Practices

1. **Always use Riverpod providers** - Don't create service instances manually
2. **Prefer streams over one-time reads** - For real-time data
3. **Handle errors gracefully** - Show user-friendly messages
4. **Validate settings** - Use `SettingsModel.validate()` before updates
5. **Monitor Firebase Console** - During development and testing

## Next Steps

- Add more sensors to `SensorsModel` (temperature, pH, EC)
- Implement alert system based on sensor readings
- Add data logging/history
- Implement offline support with local caching
