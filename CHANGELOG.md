## 1.0.8

- **Added**: `InAppUpdate.isAndroid` helper to guard Google Play in-app update calls in cross-platform Flutter apps.
- **Added**: `InAppUpdateException` for typed plugin errors such as unsupported platforms and null platform responses.
- **Added**: Optional `allowAssetPackDeletion` parameter to immediate and flexible update flows.
- **Added**: `AppUpdateInfo.updateAvailable`, `AppUpdateInfo.immediateUpdateInProgress`, and `InstallState.downloadProgress` convenience helpers.
- **Added**: Download byte metadata and failed update preconditions to the native update info payload.
- **Changed**: Native Android update flow now uses `AppUpdateOptions` consistently when checking allowed update types and starting update flows.
- **Improved**: Example app now listens to `installStateListener`, displays flexible update progress, and completes downloaded flexible updates.
- **Improved**: README now documents Play Store testing requirements, internal app sharing, signing, version code, and rollout limitations.
- **Fixed**: Pending update results are now completed with an error if the Flutter engine detaches before the update flow returns.

## 1.0.7

- **Added**: `InstallState` class to represent detailed in-app update progress (status, bytes downloaded, total bytes, and error code).
- **Added**: `InAppUpdate.installStateListener` stream to listen to the new detailed `InstallState` progress events.
- **Deprecated**: `InAppUpdate.installUpdateListener` (replaced by `installStateListener`).
- **Fixed**: Native Android compilation target compatibility by aligning Kotlin's `jvmTarget` to `17` in `build.gradle`.
- **Fixed**: Resolved Kotlin compilation overrides mismatch for `ActivityLifecycleCallbacks`.
- **Fixed**: Cleaned up activity and stream listener registration to prevent memory leaks and handle permanent detachment.

## 1.0.6

- **Breaking**: `showImmediateUpdatePrompt()` now launches Google Play Core's native update popup directly instead of showing a custom Material dialog. Removed `context`, `title`, `message`, `updateButtonText`, `cancelButtonText` parameters.
- **Added**: `installStateStreamAndroid` now works for both immediate and flexible updates. The `InstallStateUpdatedListener` is registered permanently while the plugin is attached, so install state events (download progress, install status) are emitted regardless of update type.
- **Changed**: `showImmediateUpdatePrompt()` now also triggers when `developerTriggeredUpdateInProgress` is detected, so the prompt reappears every time the app is opened until the update is installed.
- **Fixed**: Added `try-catch` around `startUpdateFlowForResult` on the native side to properly handle `IntentSender.SendIntentException`.
- **Fixed**: `appUpdateType` is now cleared after activity result handling, preventing stale state on subsequent lifecycle callbacks.
- **Fixed**: `onActivityResumed` now verifies the activity matches the plugin's activity and checks `isUpdateTypeAllowed` directly for more reliable update resumption.

## 1.0.5

- Added: `showImmediateUpdatePrompt()` – convenience method that checks for an update, shows a Material confirmation dialog with version details, and starts the immediate update flow on user acceptance.
- Added: Customizable dialog parameters (`title`, `message`, `updateButtonText`, `cancelButtonText`).
- Added: Package layout documentation to README.

## 1.0.4

- Fixed: Immediate update flow now correctly resumes when returning from the Play Store update activity by handling `DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS` state.
- Added: `Application.ActivityLifecycleCallbacks` to monitor activity resume and restart interrupted update flows.

## 1.0.3

- Migrated to Flutter Built-in Kotlin support by removing manual KGP configuration.

## 1.0.2

- Null safety improvements: removed force unwrapping in method channel calls.
- Code cleanup: merged duplicate Kotlin branches in update handler.
- Fixed: listener leak during configuration changes.
- Fixed: gradle version string now matches pubspec.
- Added: Dart unit tests (24 tests).
- Added: CI workflow (GitHub Actions).

## 1.0.1

- Performance Improvements: Under-the-hood optimizations for a smoother and faster app experience.

- Bug Fixes: Resolved minor issues to improve overall app stability.

## 1.0.0

- Initial version.
