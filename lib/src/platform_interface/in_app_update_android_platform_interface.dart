import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:in_app_update_android/src/method_channel/in_app_update_android_method_channel.dart';
import 'package:in_app_update_android/src/models/models.dart';

/// The platform interface for the `in_app_update_android` plugin.
///
/// This class defines the API that platform-specific implementations
/// must implement. It uses the [PlatformInterface] pattern to ensure
/// safe extension and prevent accidental breaking changes.
abstract class InAppUpdateAndroidPlatform extends PlatformInterface {
  /// Constructs an InAppUpdateAndroidPlatform.
  InAppUpdateAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static InAppUpdateAndroidPlatform _instance =
      MethodChannelInAppUpdateAndroid();

  /// The default instance of [InAppUpdateAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelInAppUpdateAndroid].
  static InAppUpdateAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InAppUpdateAndroidPlatform] when
  /// they register themselves.
  static set instance(InAppUpdateAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() {
    throw UnimplementedError('checkUpdateAndroid() has not been implemented.');
  }

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    throw UnimplementedError(
      'startImmediateUpdateAndroid() has not been implemented.',
    );
  }

  /// Android: Starts the flexible (background download) update flow.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  ///
  /// Listen to [installStateStreamAndroid] for download progress.
  /// Call [completeUpdateAndroid] when the download is complete.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    throw UnimplementedError(
      'startFlexibleUpdateAndroid() has not been implemented.',
    );
  }

  /// Android: Completes a flexible update by triggering an app restart.
  ///
  /// Call this after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded].
  Future<void> completeUpdateAndroid() {
    throw UnimplementedError(
      'completeUpdateAndroid() has not been implemented.',
    );
  }

  /// Android: A stream of install state changes during any in-app update.
  ///
  /// Emits [InstallStateAndroid] events with download progress and status
  /// for both immediate and flexible updates.
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    throw UnimplementedError(
      'installStateStreamAndroid has not been implemented.',
    );
  }
}
