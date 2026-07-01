# in_app_update_android

A Flutter plugin for Android in-app updates using the Google Play Core In-App
Update API.

It supports immediate and flexible update flows, update metadata, install state
events, download progress, and flexible update completion.

## Features

- Check Google Play for update availability
- Start immediate full-screen update flows
- Start flexible background update flows
- Listen to install state and download progress
- Complete a downloaded flexible update
- Optional `allowAssetPackDeletion` support for low-storage update flows
- Typed Dart exception for unsupported platforms and null platform responses

## Requirements

- Android API 21 or newer
- App installed from Google Play, internal app sharing, internal testing, closed
  testing, open testing, or production
- Same `applicationId` and signing key as the app published on Google Play
- A higher `versionCode` available on Google Play
- Google Play Store available on the device

Google Play in-app updates do not work for ordinary locally sideloaded debug
APKs. Use Play internal app sharing or a Play testing track when testing update
availability.

## Usage

```dart
import 'dart:async';

import 'package:in_app_update_android/in_app_update_android.dart';

StreamSubscription<InstallState>? subscription;

Future<void> checkAndUpdate() async {
  if (!InAppUpdate.isAndroid) return;

  final info = await InAppUpdate.checkForUpdate();

  if (!info.updateAvailable) return;

  if (info.immediateUpdateAllowed || info.immediateUpdateInProgress) {
    await InAppUpdate.performImmediateUpdate();
    return;
  }

  if (info.flexibleUpdateAllowed) {
    subscription = InAppUpdate.installStateListener.listen((state) async {
      if (state.installStatus == InstallStatus.downloaded) {
        await InAppUpdate.completeFlexibleUpdate();
      }

      final progress = state.downloadProgress;
      if (progress != null) {
        print('Download: ${(progress * 100).toStringAsFixed(1)}%');
      }
    });

    await InAppUpdate.startFlexibleUpdate();
  }
}
```

If your app uses Play Asset Delivery and can safely redownload asset packs after
an update, you can allow Play to delete asset packs on low-storage devices:

```dart
await InAppUpdate.performImmediateUpdate(allowAssetPackDeletion: true);
await InAppUpdate.startFlexibleUpdate(allowAssetPackDeletion: true);
```

## API

| Method | Returns | Description |
|--------|---------|-------------|
| `InAppUpdate.isAndroid` | `bool` | Whether the current Flutter target platform is Android |
| `checkForUpdate()` | `Future<AppUpdateInfo>` | Check if an update is available |
| `performImmediateUpdate()` | `Future<AppUpdateResult>` | Start an immediate update flow |
| `startFlexibleUpdate()` | `Future<AppUpdateResult>` | Start a flexible update flow |
| `completeFlexibleUpdate()` | `Future<void>` | Complete a downloaded flexible update |
| `installStateListener` | `Stream<InstallState>` | Stream detailed install state, progress, and error code events |
| `installUpdateListener` | `Stream<InstallStatus>` | Deprecated status-only stream |

## Play Console Notes

- `updatePriority` is controlled by the Google Play Developer API release
  field `inAppUpdatePriority`.
- `clientVersionStalenessDays` is provided by Google Play when available.
- Internal app sharing does not support `inAppUpdatePriority`.
- Update availability can be delayed by Play Store caching and rollout state.

## License

MIT
