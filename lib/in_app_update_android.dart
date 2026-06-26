import 'package:flutter/material.dart';
import 'package:in_app_update_android/src/models/models.dart';
import 'package:in_app_update_android/src/platform_interface/in_app_update_android_platform_interface.dart';

export 'package:in_app_update_android/src/models/models.dart';

/// A Flutter plugin for in-app updates on Android using Google Play's
/// In-App Updates API.
///
/// Use [checkUpdateAndroid] to check for updates, then
/// [showImmediateUpdatePrompt] or [startImmediateUpdateAndroid] /
/// [startFlexibleUpdateAndroid] to start the update flow.
class InAppUpdateAndroid {
  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() {
    return InAppUpdateAndroidPlatform.instance.checkUpdateAndroid();
  }

  /// Android: Shows a material prompt dialog with update details and starts
  /// the immediate (full-screen, blocking) update flow if the user accepts.
  ///
  /// The dialog displays the new version code, update priority, and staleness
  /// days. Tapping "Update" launches the Google Play immediate update flow.
  ///
  /// Returns [UpdateResultAndroid] if the user accepted the update and the
  /// flow completed (or was canceled/failed), or `null` if the user dismissed
  /// the dialog or no update was available.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  ///
  /// Use [title], [message], [updateButtonText], and [cancelButtonText] to
  /// customize the dialog text. If omitted, sensible defaults are used.
  Future<UpdateResultAndroid?> showImmediateUpdatePrompt(
    BuildContext context, {
    bool allowAssetPackDeletion = false,
    String title = 'Update Available',
    String? message,
    String updateButtonText = 'Update',
    String cancelButtonText = 'Not Now',
  }) async {
    final info = await checkUpdateAndroid();

    if (!context.mounted) return null;

    if (info.updateAvailability != UpdateAvailabilityAndroid.updateAvailable ||
        !info.isImmediateUpdateAllowed) {
      return null;
    }

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final buf = StringBuffer();
        if (info.availableVersionCode != null) {
          buf.writeln('New version: ${info.availableVersionCode}');
        }
        if (info.updatePriority > 0) {
          buf.writeln('Priority: ${info.updatePriority}');
        }
        if (info.clientVersionStalenessDays != null) {
          buf.writeln(
            'Available since: ${info.clientVersionStalenessDays} days ago',
          );
        }
        final detailMessage = message ?? buf.toString().trim();

        return AlertDialog(
          title: Text(title),
          content: Text(detailMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(cancelButtonText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(updateButtonText),
            ),
          ],
        );
      },
    );

    if (accepted != true) {
      return null;
    }

    return startImmediateUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
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
