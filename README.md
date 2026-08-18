<p align="center">
  <img src="https://raw.githubusercontent.com/sajedur0/in_app_update_android/main/logo.png" alt="Logo" width="120" onerror="this.style.display='none'"/>
</p>

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
  <a href="https://github.com/sajedur0/in_app_update_android/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/sajedur0/in_app_update_android/ci.yml?branch=main&logo=github&label=CI" alt="CI">
  </a>
  <img src="https://img.shields.io/badge/platform-android-green?logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.24.0-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.5.0-blue?logo=dart" alt="Dart">
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
| Flutter | `>=3.24.0` |
| Dart | `>=3.5.0` |
| Android API | 21+ |
| Installation | Google Play, Internal App Sharing, or any Play testing track |

> **Note:** In-app updates do **not** work with locally sideloaded debug APKs. Use Play internal app sharing or a testing track when developing.

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
