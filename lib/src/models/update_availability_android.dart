/// Represents the availability of an in-app update on Android.
///
/// Maps directly to Play Core's `UpdateAvailability` constants.
enum UpdateAvailabilityAndroid {
  /// Update availability is unknown.
  unknown,

  /// No update is available.
  updateNotAvailable,

  /// An update is available.
  updateAvailable,

  /// An update has been previously started by the developer
  /// and is still in progress.
  developerTriggeredUpdateInProgress;

  /// Creates an [UpdateAvailabilityAndroid] from a Play Core integer value.
  ///
  /// Play Core constants:
  /// - 0: UNKNOWN
  /// - 1: UPDATE_NOT_AVAILABLE
  /// - 2: UPDATE_AVAILABLE
  /// - 3: DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS
  static UpdateAvailabilityAndroid fromPlayCoreValue(int value) {
    return switch (value) {
      1 => UpdateAvailabilityAndroid.updateNotAvailable,
      2 => UpdateAvailabilityAndroid.updateAvailable,
      3 => UpdateAvailabilityAndroid.developerTriggeredUpdateInProgress,
      _ => UpdateAvailabilityAndroid.unknown,
    };
  }
}
