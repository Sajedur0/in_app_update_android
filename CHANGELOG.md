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
