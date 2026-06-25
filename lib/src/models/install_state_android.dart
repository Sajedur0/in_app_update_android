import 'package:in_app_update_android/src/models/install_status_android.dart';

/// Represents the current install state during a flexible update on Android.
///
/// Emitted by [InAppUpdateAndroid.installStateStreamAndroid].
class InstallStateAndroid {
  /// The current install status.
  final InstallStatusAndroid status;

  /// The number of bytes downloaded so far.
  final int bytesDownloaded;

  /// The total number of bytes to download.
  final int totalBytesToDownload;

  const InstallStateAndroid({
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytesToDownload,
  });

  /// Creates an [InstallStateAndroid] from a map received via the event channel.
  factory InstallStateAndroid.fromMap(Map<String, dynamic> map) {
    return InstallStateAndroid(
      status: InstallStatusAndroid.fromPlayCoreValue(map['status'] as int),
      bytesDownloaded: map['bytesDownloaded'] as int,
      totalBytesToDownload: map['totalBytesToDownload'] as int,
    );
  }

  @override
  String toString() {
    return 'InstallStateAndroid('
        'status: $status, '
        'bytesDownloaded: $bytesDownloaded, '
        'totalBytesToDownload: $totalBytesToDownload)';
  }
}
