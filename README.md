

<h1 align="center">in_app_update_android</h1>

<p align="center">
  <em>A Flutter plugin for Android in-app updates using the Google Play Core In-App Update API.</em>
</p>

<p align="center">
  <a href="https://pub.dev/packages/in_app_update_android">
    <img src="https://img.shields.io/pub/v/in_app_update_android?label=pub.dev&logo=dart" alt="pub.dev">
  </a>
  <a href="https://github.com/sajedur0/in_app_update_android/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/sajedur0/in_app_update_android?logo=github" alt="License">
  </a>
  <img src="https://img.shields.io/badge/platform-android-green?logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.44.0-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.12.0-blue?logo=dart" alt="Dart">
</p>

---

## Features

- Check Google Play for update availability
- Immediate full-screen update flows
- Flexible background update flows with reliable progress tracking
- Install state and download progress listeners
- Flexible update completion handling
- Optional `allowAssetPackDeletion` for low-storage devices
- Typed Dart exceptions for unsupported platforms

## Requirements

| Requirement | Details |
|-------------|---------|
| Flutter | `>=3.44.0` |
| Dart | `>=3.12.0` |
| Android API | 21+ |
| Installation | Google Play, Internal App Sharing, or any Play testing track |

> **Note:** In-app updates do **not** work with locally sideloaded debug APKs. Use Play internal app sharing or a testing track when developing.

## How In-App Updates Work

In-app updates is a Google Play Core libraries feature that prompts your **active** users to install a new version of your app without sending them to the Play Store listing. Because users can update in place, they experience fewer interruptions and are more likely to run the latest build.

The feature is supported on **Android 5.0 (API level 21) and higher** for Android phones, tablets, and ChromeOS devices. In-app updates are **not** compatible with apps that use APK expansion files (`.obb`).

Your app can support two UX flows:

### Flexible updates

Flexible updates download and install in the **background** with graceful state monitoring. This flow is appropriate when it's acceptable for the user to keep using the app while the update downloads — for example, when you want to encourage users to try a new feature that isn't critical to the core functionality of your app. The app then asks the user to confirm the install, after which Play completes the update (including any app restart).

### Immediate updates

Immediate updates are **full-screen** UX flows that require the user to update and restart the app in order to continue using it. This flow is best when an update is critical to the core functionality of your app. After a user accepts the update, Google Play handles the installation and app restart.

### How this plugin maps to each flow

| Flow | Plugin method |
|------|---------------|
| Flexible (background download → consent → install) | `InAppUpdate.startFlexibleUpdate()` → `InAppUpdate.completeFlexibleUpdate()` |
| Immediate (full-screen, critical) | `InAppUpdate.performImmediateUpdate()` |
| Both | `InAppUpdate.checkForUpdate()` + `installStateListener` for progress |

## Quick Start

```dart
import 'package:in_app_update_android/in_app_update_android.dart';

Future<void> checkAndUpdate() async {
  if (!InAppUpdate.isAndroid) return;

  final info = await InAppUpdate.checkForUpdate();
  if (!info.updateAvailable) return;

  if (info.immediateUpdateAllowed || info.immediateUpdateInProgress) {
    await InAppUpdate.performImmediateUpdate();
    return;
  }

  if (info.flexibleUpdateAllowed) {
    InAppUpdate.installStateListener.listen((state) async {
      if (state.installStatus == InstallStatus.downloaded) {
        await InAppUpdate.completeFlexibleUpdate();
      }
    });

    await InAppUpdate.startFlexibleUpdate();
  }
}
```

> **Tip:** Subscribe to `installStateListener` **before** calling `startFlexibleUpdate()` for the most responsive UI.

## API Reference

| Method | Returns | Description |
|--------|---------|-------------|
| `InAppUpdate.isAndroid` | `bool` | Check if running on Android |
| `checkForUpdate()` | `Future<AppUpdateInfo>` | Check for available updates |
| `performImmediateUpdate()` | `Future<AppUpdateResult>` | Start immediate update |
| `startFlexibleUpdate()` | `Future<AppUpdateResult>` | Start flexible update |
| `completeFlexibleUpdate()` | `Future<void>` | Complete downloaded flexible update |
| `installStateListener` | `Stream<InstallState>` | Stream install state & progress events |

## Play Console Notes

- Update priority is controlled via `inAppUpdatePriority` in the Play Developer API.
- `clientVersionStalenessDays` is provided by Google Play when available.
- Update availability may be delayed by Play Store caching and rollout state.

## License

[MIT](LICENSE)
