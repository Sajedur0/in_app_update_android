import 'package:flutter/services.dart';
import 'package:in_app_update_android/src/models/models.dart';
import 'package:in_app_update_android/src/platform_interface/in_app_update_android_platform_interface.dart';

/// An implementation of [InAppUpdateAndroidPlatform] that uses method channels.
class MethodChannelInAppUpdateAndroid extends InAppUpdateAndroidPlatform {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _methodChannel = MethodChannel(
    'in_app_update_android',
  );

  /// The event channel for receiving install state updates during flexible updates.
  static const EventChannel _eventChannel = EventChannel(
    'in_app_update_android/installStateAndroid',
  );

  @override
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'checkForUpdateAndroid',
    );
    if (result == null) {
      throw Exception('checkForUpdateAndroid returned null');
    }
    return AppUpdateInfoAndroid.fromMap(result);
  }

  @override
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) async {
    final result = await _methodChannel.invokeMethod<int>(
      'startImmediateUpdateAndroid',
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    if (result == null) {
      throw Exception('startImmediateUpdateAndroid returned null');
    }
    return UpdateResultAndroid.fromValue(result);
  }

  @override
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) async {
    final result = await _methodChannel.invokeMethod<int>(
      'startFlexibleUpdateAndroid',
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    if (result == null) {
      throw Exception('startFlexibleUpdateAndroid returned null');
    }
    return UpdateResultAndroid.fromValue(result);
  }

  @override
  Future<void> completeUpdateAndroid() async {
    await _methodChannel.invokeMethod<void>('completeUpdateAndroid');
  }

  @override
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return InstallStateAndroid.fromMap(
        Map<String, dynamic>.from(event as Map),
      );
    });
  }
}
