import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Exception thrown by the in-app update plugin for predictable API failures.
class InAppUpdateException implements Exception {
  final String code;
  final String message;
  final Object? details;

  const InAppUpdateException(this.code, this.message, [this.details]);

  @override
  String toString() {
    final suffix = details == null ? '' : ' ($details)';
    return 'InAppUpdateException($code): $message$suffix';
  }
}

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
  final int bytesDownloaded;
  final int totalBytesToDownload;

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
    this.bytesDownloaded = 0,
    this.totalBytesToDownload = 0,
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfo(
      updateAvailability: UpdateAvailability.fromPlayCoreValue(
        _asInt(map['updateAvailability']),
      ),
      immediateUpdateAllowed: map['immediateUpdateAllowed'] as bool? ?? false,
      immediateAllowedPreconditions: _asIntList(
        map['immediateAllowedPreconditions'],
      ),
      flexibleUpdateAllowed: map['flexibleUpdateAllowed'] as bool? ?? false,
      flexibleAllowedPreconditions: _asIntList(
        map['flexibleAllowedPreconditions'],
      ),
      availableVersionCode: _asNullableInt(map['availableVersionCode']),
      installStatus: InstallStatus.fromPlayCoreValue(
        _asInt(map['installStatus']),
      ),
      packageName: map['packageName'] as String? ?? '',
      clientVersionStalenessDays: _asNullableInt(
        map['clientVersionStalenessDays'],
      ),
      updatePriority: _asInt(map['updatePriority']),
      bytesDownloaded: _asInt(map['bytesDownloaded']),
      totalBytesToDownload: _asInt(map['totalBytesToDownload']),
    );
  }

  /// Whether Google Play reports an update that can be requested.
  bool get updateAvailable =>
      updateAvailability == UpdateAvailability.updateAvailable;

  /// Whether an immediate update flow was already triggered and should resume.
  bool get immediateUpdateInProgress =>
      updateAvailability ==
      UpdateAvailability.developerTriggeredUpdateInProgress;
}

/// A Flutter plugin for Android in-app updates using Google Play Core API.
///
/// Provides static methods to check for updates, start immediate or flexible
/// update flows, and listen to install status events.
class InAppUpdate {
  static const MethodChannel _methodChannel = MethodChannel(
    'in_app_update_android/methods',
  );
  static const EventChannel _eventChannel = EventChannel(
    'in_app_update_android/stateEvents',
  );

  /// In-app updates are only available on Android devices served by Google Play.
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Checks whether an in-app update is available via Play Core.
  static Future<AppUpdateInfo> checkForUpdate() async {
    _ensureAndroid();
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'checkForUpdate',
    );
    if (result == null) {
      throw const InAppUpdateException(
        'NULL_RESULT',
        'checkForUpdate returned null',
      );
    }
    return AppUpdateInfo.fromMap(result);
  }

  /// Starts the immediate (full-screen, blocking) update flow.
  ///
  /// Set [allowAssetPackDeletion] to true only when your app can safely
  /// redownload Play Asset Delivery asset packs after the update.
  static Future<AppUpdateResult> performImmediateUpdate({
    bool allowAssetPackDeletion = false,
  }) async {
    _ensureAndroid();
    final result = await _methodChannel.invokeMethod<int>(
      'performImmediateUpdate',
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    if (result == null) {
      throw const InAppUpdateException(
        'NULL_RESULT',
        'performImmediateUpdate returned null',
      );
    }
    return AppUpdateResult.fromValue(result);
  }

  /// Starts the flexible (background download) update flow.
  ///
  /// Set [allowAssetPackDeletion] to true only when your app can safely
  /// redownload Play Asset Delivery asset packs after the update.
  static Future<AppUpdateResult> startFlexibleUpdate({
    bool allowAssetPackDeletion = false,
  }) async {
    _ensureAndroid();
    final result = await _methodChannel.invokeMethod<int>(
      'startFlexibleUpdate',
      {'allowAssetPackDeletion': allowAssetPackDeletion},
    );
    if (result == null) {
      throw const InAppUpdateException(
        'NULL_RESULT',
        'startFlexibleUpdate returned null',
      );
    }
    return AppUpdateResult.fromValue(result);
  }

  /// Completes a flexible update, triggering an app restart.
  static Future<void> completeFlexibleUpdate() async {
    _ensureAndroid();
    await _methodChannel.invokeMethod<void>('completeFlexibleUpdate');
  }

  /// Stream of install state events containing status, progress, and potential error codes.
  static Stream<InstallState> get installStateListener {
    _ensureAndroid();
    return _eventChannel.receiveBroadcastStream().map((event) {
      return InstallState.fromMap(event as Map<dynamic, dynamic>);
    });
  }

  /// Stream of install status events during an update.
  @Deprecated('Use installStateListener instead')
  static Stream<InstallStatus> get installUpdateListener {
    return installStateListener.map((state) => state.installStatus);
  }

  static void _ensureAndroid() {
    if (!isAndroid) {
      throw const InAppUpdateException(
        'UNSUPPORTED_PLATFORM',
        'Google Play in-app updates are only supported on Android.',
      );
    }
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
        _asInt(map['installStatus']),
      ),
      bytesDownloaded: _asInt(map['bytesDownloaded']),
      totalBytesToDownload: _asInt(map['totalBytesToDownload']),
      installErrorCode: _asInt(map['installErrorCode']),
    );
  }

  /// Download progress from 0.0 to 1.0 when the total size is known.
  double? get downloadProgress {
    if (totalBytesToDownload <= 0) return null;
    return bytesDownloaded / totalBytesToDownload;
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

int _asInt(Object? value) => _asNullableInt(value) ?? 0;

int? _asNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw ArgumentError.value(value, 'value', 'Expected a numeric value.');
}

List<int>? _asIntList(Object? value) {
  if (value == null) return null;
  if (value is! List) {
    throw ArgumentError.value(value, 'value', 'Expected a list of integers.');
  }
  return value.map(_asInt).toList(growable: false);
}
