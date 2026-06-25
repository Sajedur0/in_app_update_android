/// Represents the install status of an in-app update on Android.
///
/// Maps directly to Play Core's `InstallStatus` constants.
enum InstallStatusAndroid {
  /// Install status is unknown.
  unknown,

  /// The update is pending and will be downloaded soon.
  pending,

  /// The update is currently being downloaded.
  downloading,

  /// The update has been downloaded and is ready to be installed.
  downloaded,

  /// The update is currently being installed.
  installing,

  /// The update has been installed successfully.
  installed,

  /// The update has failed.
  failed,

  /// The update has been canceled by the user.
  canceled;

  /// Creates an [InstallStatusAndroid] from a Play Core integer value.
  ///
  /// Play Core constants (non-sequential):
  /// - 0: UNKNOWN
  /// - 1: PENDING
  /// - 2: DOWNLOADING
  /// - 11: DOWNLOADED
  /// - 5: INSTALLING
  /// - 6: INSTALLED
  /// - 7: FAILED
  /// - 8: CANCELED
  static InstallStatusAndroid fromPlayCoreValue(int value) {
    return switch (value) {
      1 => InstallStatusAndroid.pending,
      2 => InstallStatusAndroid.downloading,
      11 => InstallStatusAndroid.downloaded,
      5 => InstallStatusAndroid.installing,
      6 => InstallStatusAndroid.installed,
      7 => InstallStatusAndroid.failed,
      8 => InstallStatusAndroid.canceled,
      _ => InstallStatusAndroid.unknown,
    };
  }
}
