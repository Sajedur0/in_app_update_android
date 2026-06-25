import 'package:in_app_update_android/src/models/install_status_android.dart';
import 'package:in_app_update_android/src/models/update_availability_android.dart';

/// Contains information about an available in-app update on Android.
///
/// Returned by [InAppUpdateAndroid.checkUpdateAndroid].
class AppUpdateInfoAndroid {
  /// The availability of an update.
  final UpdateAvailabilityAndroid updateAvailability;

  /// The version code of the available update, or `null` if unavailable.
  final int? availableVersionCode;

  /// The in-app update priority as set by the developer in the
  /// Google Play Developer API. Ranges from 0 (default) to 5 (highest).
  final int updatePriority;

  /// The number of days since the update became available on the Play Store,
  /// or `null` if unavailable.
  final int? clientVersionStalenessDays;

  /// Whether an immediate update is allowed for this update.
  final bool isImmediateUpdateAllowed;

  /// Whether a flexible update is allowed for this update.
  final bool isFlexibleUpdateAllowed;

  /// The current install status of the update.
  final InstallStatusAndroid installStatus;

  const AppUpdateInfoAndroid({
    required this.updateAvailability,
    this.availableVersionCode,
    required this.updatePriority,
    this.clientVersionStalenessDays,
    required this.isImmediateUpdateAllowed,
    required this.isFlexibleUpdateAllowed,
    required this.installStatus,
  });

  /// Creates an [AppUpdateInfoAndroid] from a map received via the method channel.
  factory AppUpdateInfoAndroid.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfoAndroid(
      updateAvailability: UpdateAvailabilityAndroid.fromPlayCoreValue(
        map['updateAvailability'] as int,
      ),
      availableVersionCode: map['availableVersionCode'] as int?,
      updatePriority: map['updatePriority'] as int,
      clientVersionStalenessDays: map['clientVersionStalenessDays'] as int?,
      isImmediateUpdateAllowed: map['isImmediateUpdateAllowed'] as bool,
      isFlexibleUpdateAllowed: map['isFlexibleUpdateAllowed'] as bool,
      installStatus: InstallStatusAndroid.fromPlayCoreValue(
        map['installStatus'] as int,
      ),
    );
  }

  @override
  String toString() {
    return 'AppUpdateInfoAndroid('
        'updateAvailability: $updateAvailability, '
        'availableVersionCode: $availableVersionCode, '
        'updatePriority: $updatePriority, '
        'clientVersionStalenessDays: $clientVersionStalenessDays, '
        'isImmediateUpdateAllowed: $isImmediateUpdateAllowed, '
        'isFlexibleUpdateAllowed: $isFlexibleUpdateAllowed, '
        'installStatus: $installStatus)';
  }
}
