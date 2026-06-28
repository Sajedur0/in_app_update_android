import 'dart:async';
import 'package:flutter/services.dart';

/// Status of an in-app update installation.
enum InstallStatus {
  unknown,
  pending,
  downloading,
  installing,
  installed,
  failed,
  canceled,
  downloaded;

  static InstallStatus fromPlayCoreValue(int value) {
    return switch (value) {
      1 => InstallStatus.pending,
      2 => InstallStatus.downloading,
      5 => InstallStatus.installing,
      6 => InstallStatus.installed,
      7 => InstallStatus.failed,
      8 => InstallStatus.canceled,
      11 => InstallStatus.downloaded,
      _ => InstallStatus.unknown,
    };
  }
}

/// Availability of an in-app update.
enum UpdateAvailability {
  unknown,
  updateNotAvailable,
  updateAvailable,
  developerTriggeredUpdateInProgress;

  static UpdateAvailability fromPlayCoreValue(int value) {
    return switch (value) {
      1 => UpdateAvailability.updateNotAvailable,
      2 => UpdateAvailability.updateAvailable,
      3 => UpdateAvailability.developerTriggeredUpdateInProgress,
      _ => UpdateAvailability.unknown,
    };
  }
}

/// Result of an in-app update flow.
enum AppUpdateResult {
  success,
  userDeniedUpdate,
  inAppUpdateFailed;

  static AppUpdateResult fromValue(int value) {
    return switch (value) {
      0 => AppUpdateResult.success,
      1 => AppUpdateResult.userDeniedUpdate,
      _ => AppUpdateResult.inAppUpdateFailed,
    };
  }
}

/// Information about an available in-app update.
class AppUpdateInfo {
  final UpdateAvailability updateAvailability;
  final bool immediateUpdateAllowed;
  final List<int>? immediateAllowedPreconditions;
  final bool flexibleUpdateAllowed;
  final List<int>? flexibleAllowedPreconditions;
  final int? availableVersionCode;
  final InstallStatus installStatus;
  final String packageName;
  final int? clientVersionStalenessDays;
  final int updatePriority;

  const AppUpdateInfo({
    required this.updateAvailability,
    required this.immediateUpdateAllowed,
    this.immediateAllowedPreconditions,
    required this.flexibleUpdateAllowed,
    this.flexibleAllowedPreconditions,
    this.availableVersionCode,
    required this.installStatus,
    required this.packageName,
    this.clientVersionStalenessDays,
    required this.updatePriority,
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfo(
      updateAvailability: UpdateAvailability.fromPlayCoreValue(
        map['updateAvailability'] as int,
      ),
      immediateUpdateAllowed: map['immediateUpdateAllowed'] as bool,
      immediateAllowedPreconditions:
          (map['immediateAllowedPreconditions'] as List<dynamic>?)
              ?.cast<int>(),
      flexibleUpdateAllowed: map['flexibleUpdateAllowed'] as bool,
      flexibleAllowedPreconditions:
          (map['flexibleAllowedPreconditions'] as List<dynamic>?)
              ?.cast<int>(),
      availableVersionCode: map['availableVersionCode'] as int?,
      installStatus: InstallStatus.fromPlayCoreValue(
        map['installStatus'] as int,
      ),
      packageName: map['packageName'] as String,
      clientVersionStalenessDays: map['clientVersionStalenessDays'] as int?,
      updatePriority: map['updatePriority'] as int,
    );
  }
}

/// A Flutter plugin for Android in-app updates using Google Play Core API.
///
/// Provides static methods to check for updates, start immediate or flexible
/// update flows, and listen to install status events.
class InAppUpdate {
  static const MethodChannel _methodChannel =
      MethodChannel('in_app_update_android/methods');
  static const EventChannel _eventChannel =
      EventChannel('in_app_update_android/stateEvents');

  /// Checks whether an in-app update is available via Play Core.
  static Future<AppUpdateInfo> checkForUpdate() async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'checkForUpdate',
    );
    if (result == null) {
      throw Exception('checkForUpdate returned null');
    }
    return AppUpdateInfo.fromMap(result);
  }

  /// Starts the immediate (full-screen, blocking) update flow.
  static Future<AppUpdateResult> performImmediateUpdate() async {
    final result = await _methodChannel.invokeMethod<int>(
      'performImmediateUpdate',
    );
    if (result == null) {
      throw Exception('performImmediateUpdate returned null');
    }
    return AppUpdateResult.fromValue(result);
  }

  /// Starts the flexible (background download) update flow.
  static Future<AppUpdateResult> startFlexibleUpdate() async {
    final result = await _methodChannel.invokeMethod<int>(
      'startFlexibleUpdate',
    );
    if (result == null) {
      throw Exception('startFlexibleUpdate returned null');
    }
    return AppUpdateResult.fromValue(result);
  }

  /// Completes a flexible update, triggering an app restart.
  static Future<void> completeFlexibleUpdate() async {
    await _methodChannel.invokeMethod<void>('completeFlexibleUpdate');
  }

  /// Stream of install state events containing status, progress, and potential error codes.
  static Stream<InstallState> get installStateListener {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return InstallState.fromMap(event as Map<dynamic, dynamic>);
    });
  }

  /// Stream of install status events during an update.
  @Deprecated('Use installStateListener instead')
  static Stream<InstallStatus> get installUpdateListener {
    return installStateListener.map((state) => state.installStatus);
  }
}

/// Detailed installation state of a flexible in-app update.
class InstallState {
  final InstallStatus installStatus;
  final int bytesDownloaded;
  final int totalBytesToDownload;
  final int installErrorCode;

  const InstallState({
    required this.installStatus,
    required this.bytesDownloaded,
    required this.totalBytesToDownload,
    required this.installErrorCode,
  });

  factory InstallState.fromMap(Map<dynamic, dynamic> map) {
    return InstallState(
      installStatus: InstallStatus.fromPlayCoreValue(
        map['installStatus'] as int,
      ),
      bytesDownloaded: map['bytesDownloaded'] as int,
      totalBytesToDownload: map['totalBytesToDownload'] as int,
      installErrorCode: map['installErrorCode'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstallState &&
        other.installStatus == installStatus &&
        other.bytesDownloaded == bytesDownloaded &&
        other.totalBytesToDownload == totalBytesToDownload &&
        other.installErrorCode == installErrorCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      installStatus,
      bytesDownloaded,
      totalBytesToDownload,
      installErrorCode,
    );
  }

  @override
  String toString() {
    return 'InstallState(installStatus: $installStatus, bytesDownloaded: $bytesDownloaded, totalBytesToDownload: $totalBytesToDownload, installErrorCode: $installErrorCode)';
  }
}
