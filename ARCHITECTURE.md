# Project Architecture Documentation

Welcome to the Rayyan Flutter App architecture documentation. This document serves as a comprehensive overview of the design patterns, system architecture, file structure, and core decisions that power this application.

## 1. High-Level Architecture Overview

This project follows a **Feature-Driven (or Domain-Driven) Architecture**. The entire codebase is modularized by feature, where each feature encapsulates its own presentation (UI), application logic (State Management / Controllers), domain (Models / Interfaces), and data (Repositories / APIs) layers.

Our architectural stack relies heavily on the following:
* **Flutter** - The core SDK.
* **Riverpod** (`flutter_riverpod`) - Used extensively for state management, dependency injection, and reactive UI recompositions. 
* **Firebase Ecosystem** - Used across the app for:
  * **Firebase Auth**: User authentication.
  * **Firebase Realtime Database (RTDB)** / **Firestore**: Real-time sync of settings and hydroponic sensor data.
  * **Firebase Storage**: For user media (e.g., profile pictures).
* **Groq SDK** - For generative AI integrations (`insights` and `chat`), specifically handling natural language crop consulting and real-time sensor anomaly analysis.

## 2. Global State Management & Routing

Instead of an external package like `go_router`, the app employs a centralized **state-based routing mechanism** utilizing Riverpod.
* `AppController` (`lib/src/app/app_controller.dart`): Controls the global global screen state (`AppScreen`).
* `RayyanApp` (`lib/src/app/app.dart`): The root widget listens to `appControllerProvider`. When the current `AppScreen` changes, the `switch` statement dynamically swaps the root widget without destroying the Flutter `MaterialApp` context.

## 3. Detailed Directory Structure

All application source code resides in the `lib/src/` directory.

### `lib/src/app/`
Contains the application's global roots and initialization.
- `app.dart`: The main `MaterialApp` that defines theme, localization delegates, and dynamically routes via a switch statement based on the active `AppScreen`.
- `app_controller.dart`: The Riverpod logic for the global UI state (routing, toggling language).
- `app_state.dart`: Simple data class holding the current application state (e.g., current screen).
- `screens.dart`: Defines the `AppScreen` enum (e.g., dashboard, login, settings, alerts).

### `lib/src/core/`
This directory holds everything shared across multiple features. If logic or a widget is utilized by *more than one feature*, it lives here.
- `config/`: Configuration files and environment setups.
- `locale/` & `localization/`: Custom logic for language management and integrating `AppLocalizations` (Arabic/English support).
- `models/`: Global or cross-feature models (e.g., `SensorsModel`, `SettingsModel`).
- `services/`: Low-level infrastructural services that features consume.
  - `firebase_auth_service.dart`: Maps Firebase Auth actions to the app.
  - `firestore_service.dart`: Base firestore operations.
  - `hydroponic_database_service.dart`: Dedicated service for reading/writing realtime sensor data and controller thresholds.
  - `user_database_service.dart`: Management of User profiles and metadata.
  - `storage_service.dart`: Handling Firebase Storage uploads (profile pictures).
  - `groq_service.dart`: The underlying networking layer connecting to Groq AI inference.
- `theme/`: Defines global theming colors (`rayyan_colors.dart`), text styles, and light/dark mode implementations (`rayyan_theme.dart`).
- `utils/`: Reusable formatter functions and mathematical utilities (e.g., `vitality_utils.dart` for calculating warning parameters).
- `widgets/`: Universal widgets such as `RayyanHeader`, custom text fields, page scaffolds (`RayyanPageScaffold`), dynamic bottom navigation, and symbols.

### `lib/src/features/`
This is where the bulk of the application resides. Each folder is a distinct vertical slice of functionality. Depending on the complexity of the feature, they follow the Clean Architecture sub-layering:
* **`presentation/`**: Contains the Screens and specific UI widgets.
* **`application/`**: Contains Riverpod `StateNotifier`s, `Provider`s, and Use Cases that manipulate data.
* **`domain/`**: Contains Entities, specific feature models, and abstract repository definitions.
* **`data/`**: Contains DTOs, API networking specific to the feature, and Repository implementations.

#### Featured Modules:
- **`alerts`**: Monitors sensor thresholds and handles dispatching critical warnings. Uses a `SensorWatcher` that connects to the local notification service.
- **`analytics`**: Visualizes historic sensor data using charts (fl_chart).
- **`auth`**: Login, Signup, Forgot Password flows, and related widgets.
- **`chat`**: The UI and logic for an internal AI chat consultant using the `groq_service.dart`.
- **`controls`**: A UI module allowing manual and automatic toggle of system hardware (e.g., pumps, fans, lights).
- **`dashboard`**: The main overview screen showing live sensor readings and immediate device statuses.
- **`insights`**: Groq-powered AI summaries evaluating current hydroponic conditions.
- **`profile`**: Manages the currently logged-in user profile, avatar uploading, and sign-out logic.
- **`settings`**: Manages app-wide configurations natively, including Language toggles, Dark/Light modes, Notification preferences, and firmware info.
- **`splash`**: App initialization, offline loading checks, and splash branding.
- **`support`**: FAQ, contact, and support center forms.
- **`vision`**: Machine-vision or camera-integration features (assessed for future monitoring).
- **`wifi`**: A setup wizard for provisioning the IoT device firmware to local WiFi.

## 4. Key Developer Workflows

### 4.1. Adding a New Screen
1. Create your feature folder inside `lib/src/features/my_feature/presentation/my_screen.dart`.
2. Open `lib/src/app/screens.dart` and add `myFeatureScreen` to the `AppScreen` ENUM.
3. Open `lib/src/app/app.dart` and add a layout case in `switch(screen)`.
4. Navigate to it within any widget by utilizing Riverpod `ref.read(appControllerProvider.notifier).navigate(AppScreen.myFeatureScreen)`.

### 4.2. Dependency Injection and Async Data
All application dependencies are lazily loaded and cached via Riverpod.
If a feature requires sensor data, it should `ref.watch(sensorsStreamProvider)` which utilizes the `hydroponic_database_service` to provide an `AsyncValue` representing `Loading`, `Error`, or `Data` inherently. UI dynamically reacts without needing explicit `setState()`.

## 5. Third-Party Integrations
- **fl_chart**: Powers custom telemetry charts.
- **cached_network_image**: Efficient caching for external imagery (User profile pictures).
- **flutter_local_notifications**: For system-level alerts defined inside the `Alerts` feature module.
- **ConnectivityPlus / SharedPreferences**: Utilized for state persistence and offline state determination.
