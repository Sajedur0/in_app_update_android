## 1.1.2

- Fixed: `AppUpdateInfo.hashCode` now includes allowed preconditions, consistent with equality.
- Updated: Example project SDK to `^3.12.0`.

## 1.1.1

- Fixed: `AppUpdateInfo` equality now compares allowed preconditions by value.
- Added: `AppUpdateInfo.toString()` for easier debugging.
- Fixed: `onCancel` no longer unregisters listener during active flexible update.
- Fixed: Null-safe pending result handling on engine/activity detach.
- Fixed: `pendingEvents` list is now thread-safe.
- Fixed: `handleCompleteUpdate` returns `NO_FLEXIBLE_UPDATE` error when no flexible update is in progress.
- Added: `InAppUpdate.resetCachedStream()` for test isolation.
- Added: ProGuard consumer rules for Play Core library.
- Added: Unit tests for `completeFlexibleUpdate` error path.
- Migrated to Flutter's built-in Kotlin support.
- Minimum Flutter `>=3.44.0`, Dart `^3.12.0`.

## 1.1.0

- Fixed: Flexible update listener registered eagerly to prevent missed progress events.
- Fixed: Install state events buffered and flushed when stream is listened to.
- Fixed: Flexible update auto-completes pending result on terminal state.
- Improved: Example app shows distinct UI states for flexible update.
- Added: Unit tests for `startFlexibleUpdate` and `installStateListener`.

## 1.0.9

- Fixed: Example app builds on AGP 9+ with built-in Kotlin support.
- Fixed: Lifecycle listeners unregistered on engine detach to prevent leaks.
- Minimum Flutter `3.44.0`, Dart `3.12`.

## 1.0.8

- Added: `InAppUpdate.isAndroid` guard for cross-platform apps.
- Added: `InAppUpdateException` for typed plugin errors.
- Added: Optional `allowAssetPackDeletion` for immediate and flexible updates.
- Added: `AppUpdateInfo.updateAvailable`, `immediateUpdateInProgress`, `InstallState.downloadProgress` helpers.
- Changed: Native update flow now uses `AppUpdateOptions` consistently.
- Improved: Example app listens to `installStateListener` with progress display.
- Fixed: Pending result completed with error on engine detach.

## 1.0.7

- Added: `InstallState` class with status, bytes downloaded/total, and error code.
- Added: `InAppUpdate.installStateListener` stream.
- Deprecated: `installUpdateListener` (use `installStateListener`).
- Fixed: Aligned Kotlin `jvmTarget` to `17` for compilation compatibility.
- Fixed: Listener registration cleanup to prevent memory leaks.

## 1.0.6

- **Breaking**: `showImmediateUpdatePrompt()` now uses Play Core's native popup. Removed custom dialog parameters.
- Added: `installStateStreamAndroid` works for both immediate and flexible updates.
- Changed: `showImmediateUpdatePrompt()` re-triggers on `developerTriggeredUpdateInProgress`.
- Fixed: `IntentSender.SendIntentException` caught on native side.
- Fixed: `appUpdateType` cleared after activity result to prevent stale state.
- Fixed: `onActivityResumed` validates activity and checks `isUpdateTypeAllowed`.

## 1.0.5

- Added: `showImmediateUpdatePrompt()` with version dialog and immediate update flow.
- Added: Customizable dialog parameters.

## 1.0.4

- Fixed: Immediate update resumes after returning from Play Store.
- Added: `ActivityLifecycleCallbacks` to monitor resume and restart interrupted flows.

## 1.0.3

- Migrated to Flutter built-in Kotlin support.

## 1.0.2

- Null safety: removed force unwrapping in method channel calls.
- Fixed: Listener leak during configuration changes.
- Added: 24 Dart unit tests.
- Added: GitHub Actions CI workflow.

## 1.0.1

- Performance improvements and minor bug fixes.

## 1.0.0

- Initial release.
