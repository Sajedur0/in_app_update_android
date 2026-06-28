<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android" alt="Platform: Android">
  <img src="https://img.shields.io/pub/v/in_app_update_android?style=for-the-badge&logo=dart&label=pub.dev" alt="Pub Version">
  <br>
  <img src="https://img.shields.io/pub/points/in_app_update_android?style=for-the-badge&label=Pub%20Points" alt="Pub Points">
  <img src="https://img.shields.io/pub/likes/in_app_update_android?style=for-the-badge&label=Pub%20Likes" alt="Pub Likes">
  <img src="https://img.shields.io/pub/popularity/in_app_update_android?style=for-the-badge&label=Pub%20Popularity" alt="Pub Popularity">
  <br>
  <img src="https://img.shields.io/badge/Dart-%5E3.12.2-0175C2?style=for-the-badge&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Flutter-%5E3.3.0-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/minSdk-21-FF6D00?style=for-the-badge&logo=android" alt="minSdk 21">
  <br>
  <img src="https://img.shields.io/github/last-commit/Sajedur0/in_app_update_android?style=for-the-badge&logo=github" alt="Last Commit">
  <img src="https://img.shields.io/github/license/Sajedur0/in_app_update_android?style=for-the-badge" alt="License">
</p>

<h1 align="center">in_app_update_android</h1>

<p align="center">
  A Flutter plugin for Android in-app updates using Google Play's In-App Updates API.
  <br>
  Supports immediate (blocking) and flexible (background) update flows with real-time download progress tracking.
</p>

---

## Features

- **Update Availability Check** – Query Google Play to see if an update is available for your app.
- **Immediate Updates** – Full-screen, blocking update flow that users must accept to continue.
- **Flexible Updates** – Background download with progress tracking; install when ready.
- **Download Progress Stream** – Real-time `InstallStateAndroid` events via a Dart stream.
- **Install Status Tracking** – Monitor pending, downloading, downloaded, installing, installed, failed, and canceled states.

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Package Layout](#package-layout)
- [Usage](#usage)
  - [Check for Updates](#check-for-updates)
  - [Immediate Update](#immediate-update)
  - [Flexible Update](#flexible-update)
- [API Reference](#api-reference)
- [Models](#models)
- [Requirements](#requirements)
- [Compatibility](#compatibility)
- [Changelog](#changelog)
- [License](#license)

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_update_android: ^1.0.3
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:in_app_update_android/in_app_update_android.dart';

final inAppUpdate = InAppUpdateAndroid();
```

---

## Package Layout

```
lib/
├── in_app_update_android.dart          # Public API – main entry point
└── src/
    ├── method_channel/
    │   └── in_app_update_android_method_channel.dart  # Method/event channel bridge
    ├── models/
    │   ├── app_update_info_android.dart               # Update metadata model
    │   ├── install_state_android.dart                 # Install progress model
    │   ├── install_status_android.dart                # Install status enum
    │   ├── models.dart                                # Barrel export
    │   ├── update_availability_android.dart           # Availability enum
    │   └── update_result_android.dart                 # Result enum
    └── platform_interface/
        └── in_app_update_android_platform_interface.dart  # Abstract platform API

android/src/main/kotlin/sajedur0/in_app_update_android/
└── InAppUpdateAndroidPlugin.kt  # Native Android (Kotlin) implementation
```

The plugin follows Flutter's **Platform Interface** pattern:
- `InAppUpdateAndroidPlatform` – abstract interface defining all methods
- `MethodChannelInAppUpdateAndroid` – default implementation using `MethodChannel` / `EventChannel`
- `InAppUpdateAndroidPlugin` (Kotlin) – Android-side handler via Play Core API

---

## Usage

### Check for Updates

```dart
final info = await inAppUpdate.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable) {
  print('Version code: ${info.availableVersionCode}');
  print('Update priority: ${info.updatePriority}');
  print('Staleness days: ${info.clientVersionStalenessDays}');
}
```

### Immediate Update

#### With Google Play Core's native popup (recommended)

```dart
// Shows Google Play Core's native update popup directly
// Call this on every app launch to always prompt the user
final result = await inAppUpdate.showImmediateUpdatePrompt();

if (result == UpdateResultAndroid.success) {
  // App is updating
}
```

#### Direct trigger (no prompt)

```dart
final result = await inAppUpdate.startImmediateUpdateAndroid();

switch (result) {
  case UpdateResultAndroid.success:
    // App is updating
    break;
  case UpdateResultAndroid.userCanceled:
    // User dismissed the update
    break;
  case UpdateResultAndroid.inAppUpdateFailed:
    // An error occurred
    break;
}
```

### Flexible Update

```dart
// 1. Listen for download progress
final subscription = inAppUpdate.installStateStreamAndroid.listen((state) {
  final progress = state.bytesDownloaded / state.totalBytesToDownload * 100;
  print('Download progress: ${progress.toStringAsFixed(1)}%');
});

// 2. Start the flexible update
final result = await inAppUpdate.startFlexibleUpdateAndroid();

if (result == UpdateResultAndroid.success) {
  // 3. Complete the installation (triggers app restart)
  await inAppUpdate.completeUpdateAndroid();
}
```

---

## API Reference

### InAppUpdateAndroid

| Method / Property | Returns | Description |
|---|---|---|---|
| `checkUpdateAndroid()` | `Future<AppUpdateInfoAndroid>` | Checks for an available update via Play Core. |
| `showImmediateUpdatePrompt({bool allowAssetPackDeletion})` | `Future<UpdateResultAndroid?>` | Shows Google Play Core's native update popup directly. Also triggers when `developerTriggeredUpdateInProgress` is detected. Returns `null` if no update is available. |
| `startImmediateUpdateAndroid({bool allowAssetPackDeletion})` | `Future<UpdateResultAndroid>` | Starts a full-screen blocking update flow. |
| `startFlexibleUpdateAndroid({bool allowAssetPackDeletion})` | `Future<UpdateResultAndroid>` | Starts a background download update flow. |
| `completeUpdateAndroid()` | `Future<void>` | Installs a downloaded flexible update (triggers app restart). |
| `installStateStreamAndroid` | `Stream<InstallStateAndroid>` | Stream of download progress and status events for both immediate and flexible updates. |

---

## Models

### AppUpdateInfoAndroid

| Field | Type | Description |
|---|---|---|
| `updateAvailability` | `UpdateAvailabilityAndroid` | Whether an update is available. |
| `availableVersionCode` | `int?` | Version code of the available update. |
| `updatePriority` | `int` | Priority (0–5) set via Play Developer API. |
| `clientVersionStalenessDays` | `int?` | Days since the update became available. |
| `isImmediateUpdateAllowed` | `bool` | Whether immediate update is permitted. |
| `isFlexibleUpdateAllowed` | `bool` | Whether flexible update is permitted. |
| `installStatus` | `InstallStatusAndroid` | Current install status. |

### InstallStateAndroid

| Field | Type | Description |
|---|---|---|
| `status` | `InstallStatusAndroid` | Current install state. |
| `bytesDownloaded` | `int` | Bytes downloaded so far. |
| `totalBytesToDownload` | `int` | Total bytes to download. |

### Enums

| Enum | Values |
|---|---|
| `UpdateAvailabilityAndroid` | `unknown`, `updateNotAvailable`, `updateAvailable`, `developerTriggeredUpdateInProgress` |
| `InstallStatusAndroid` | `unknown`, `pending`, `downloading`, `downloaded`, `installing`, `installed`, `failed`, `canceled` |
| `UpdateResultAndroid` | `success`, `userCanceled`, `inAppUpdateFailed` |

---

## Requirements

| Requirement | Minimum |
|---|---|
| Android SDK | `minSdk = 21` (Android 5.0) |
| Dart SDK | `^3.12.2` |
| Flutter SDK | `>=3.3.0` |

---

## Compatibility

| Version | Dart SDK | Flutter SDK | Android |
|---|---|---|---|
| `1.0.x` | `^3.12.2` | `>=3.3.0` | `minSdk 21` |

The badges at the top of this README automatically reflect the latest version published on [pub.dev](https://pub.dev/packages/in_app_update_android).

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Developed by <a href="https://github.com/Sajedur0">Sajedur0</a>
  <br>
  <a href="https://github.com/Sajedur0/in_app_update_android/issues">Report a bug</a> ·
  <a href="https://github.com/Sajedur0/in_app_update_android/issues">Request a feature</a>
</p>
