/// Represents the result of an in-app update flow on Android.
enum UpdateResultAndroid {
  /// The update was accepted and completed successfully.
  success,

  /// The user canceled the update.
  userCanceled,

  /// The update flow failed due to an error.
  inAppUpdateFailed;

  /// Creates an [UpdateResultAndroid] from an integer value.
  ///
  /// - 0: success (Activity.RESULT_OK)
  /// - 1: userCanceled (Activity.RESULT_CANCELED)
  /// - 2: inAppUpdateFailed (ActivityResult.RESULT_IN_APP_UPDATE_FAILED)
  static UpdateResultAndroid fromValue(int value) {
    return switch (value) {
      0 => UpdateResultAndroid.success,
      1 => UpdateResultAndroid.userCanceled,
      _ => UpdateResultAndroid.inAppUpdateFailed,
    };
  }
}
