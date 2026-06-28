# in_app_update_android

A Flutter plugin for Android in-app updates using Google Play Core API.

Supports immediate (blocking) and flexible (background) update flows with install status tracking.

## Features

- **Update Availability Check** – Query Google Play to see if an update is available
- **Immediate Updates** – Full-screen, blocking update flow
- **Flexible Updates** – Background download; install when ready
- **Install Status Stream** – Real-time install status events via Dart stream

## Usage

```dart
import 'package:in_app_update_android/in_app_update_android.dart';

// 1. Check for update
final info = await InAppUpdate.checkForUpdate();

// 2. Check status
if (info.updateAvailability == UpdateAvailability.updateAvailable) {
  // 3. Immediate update
  final result = await InAppUpdate.performImmediateUpdate();

  // Or flexible update
  await InAppUpdate.startFlexibleUpdate();

  // 4. Listen to stream for detailed status & download progress
  InAppUpdate.installStateListener.listen((state) {
    if (state.installStatus == InstallStatus.downloaded) {
      await InAppUpdate.completeFlexibleUpdate();
    } else if (state.installStatus == InstallStatus.downloading) {
      final progress = state.bytesDownloaded / state.totalBytesToDownload;
      print("Download progress: ${(progress * 100).toStringAsFixed(1)}%");
    }
  });
}
```

## API

| Method | Returns | Description |
|--------|---------|-------------|
| `checkForUpdate()` | `Future<AppUpdateInfo>` | Check if an update is available |
| `performImmediateUpdate()` | `Future<AppUpdateResult>` | Start immediate update flow |
| `startFlexibleUpdate()` | `Future<AppUpdateResult>` | Start flexible (background) update |
| `completeFlexibleUpdate()` | `Future<void>` | Complete flexible update (triggers restart) |
| `installStateListener` | `Stream<InstallState>` | Stream of detailed install state events (progress, error code, status) |
| `installUpdateListener` | `Stream<InstallStatus>` | (Deprecated) Stream of install status events |

## Requirements

- Android `minSdk 21`
- Google Play Store installed and signed in
- App distributed via Google Play Store

## License

MIT
