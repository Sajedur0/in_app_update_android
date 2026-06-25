import 'package:in_app_update_android/src/models/models.dart';
import 'package:in_app_update_android/src/platform_interface/in_app_update_android_platform_interface.dart';

export 'package:in_app_update_android/src/models/models.dart';

/// A Flutter plugin for in-app updates on Android using Google Play's
/// In-App Updates API.
///
/// Use [checkUpdateAndroid] to check for updates, then
/// [startImmediateUpdateAndroid] or [startFlexibleUpdateAndroid] to start the
/// update flow.
class InAppUpdateAndroid {
  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() {
    return InAppUpdateAndroidPlatform.instance.checkUpdateAndroid();
  }

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  ///
  /// The user must accept the update to continue using the app. If the user
  /// closes the update screen, [UpdateResultAndroid.userCanceled] is returned.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    return InAppUpdateAndroidPlatform.instance.startImmediateUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
  }

  /// Android: Starts the flexible (background download) update flow.
  ///
  /// The update downloads in the background while the user continues
  /// using the app. Listen to [installStateStreamAndroid] for download
  /// progress, and call [completeUpdateAndroid] when the download is complete.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    return InAppUpdateAndroidPlatform.instance.startFlexibleUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
  }

  /// Android: Completes a flexible update by triggering an app restart.
  ///
  /// Call this after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded].
  Future<void> completeUpdateAndroid() {
    return InAppUpdateAndroidPlatform.instance.completeUpdateAndroid();
  }

  /// Android: A stream of install state changes during a flexible update.
  ///
  /// Emits [InstallStateAndroid] events with download progress and status.
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    return InAppUpdateAndroidPlatform.instance.installStateStreamAndroid;
  }
}
