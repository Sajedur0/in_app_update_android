import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_android/in_app_update_android.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InAppUpdate', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        null,
      );
    });

    test('checkForUpdate throws when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        () => InAppUpdate.checkForUpdate(),
        throwsA(isA<Exception>()),
      );
    });

    test('checkForUpdate returns AppUpdateInfo on success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return {
            'updateAvailability': 2,
            'immediateUpdateAllowed': true,
            'immediateAllowedPreconditions': null,
            'flexibleUpdateAllowed': true,
            'flexibleAllowedPreconditions': null,
            'availableVersionCode': 2,
            'installStatus': 1,
            'packageName': 'com.example.app',
            'clientVersionStalenessDays': null,
            'updatePriority': 0,
          };
        },
      );

      final info = await InAppUpdate.checkForUpdate();

      expect(info.updateAvailability, UpdateAvailability.updateAvailable);
      expect(info.packageName, 'com.example.app');
      expect(info.immediateUpdateAllowed, true);
      expect(info.flexibleUpdateAllowed, true);
      expect(info.availableVersionCode, 2);
    });

    test('performImmediateUpdate throws when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        () => InAppUpdate.performImmediateUpdate(),
        throwsA(isA<Exception>()),
      );
    });

    test('performImmediateUpdate returns success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return 0;
        },
      );

      final result = await InAppUpdate.performImmediateUpdate();

      expect(result, AppUpdateResult.success);
    });

    test('performImmediateUpdate returns userDeniedUpdate', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return 1;
        },
      );

      final result = await InAppUpdate.performImmediateUpdate();

      expect(result, AppUpdateResult.userDeniedUpdate);
    });

    test('startFlexibleUpdate throws when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        () => InAppUpdate.startFlexibleUpdate(),
        throwsA(isA<Exception>()),
      );
    });

    test('startFlexibleUpdate returns success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return 0;
        },
      );

      final result = await InAppUpdate.startFlexibleUpdate();

      expect(result, AppUpdateResult.success);
    });

    test('completeFlexibleUpdate does not throw', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android/methods'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        InAppUpdate.completeFlexibleUpdate(),
        completes,
      );
    });
  });

  group('AppUpdateResult', () {
    test('fromValue returns success for 0', () {
      expect(AppUpdateResult.fromValue(0), AppUpdateResult.success);
    });

    test('fromValue returns userDeniedUpdate for 1', () {
      expect(AppUpdateResult.fromValue(1), AppUpdateResult.userDeniedUpdate);
    });

    test('fromValue returns inAppUpdateFailed for 2', () {
      expect(AppUpdateResult.fromValue(2), AppUpdateResult.inAppUpdateFailed);
    });

    test('fromValue returns inAppUpdateFailed for unknown values', () {
      expect(AppUpdateResult.fromValue(99), AppUpdateResult.inAppUpdateFailed);
    });
  });

  group('UpdateAvailability', () {
    test('fromPlayCoreValue returns unknown for 0', () {
      expect(UpdateAvailability.fromPlayCoreValue(0), UpdateAvailability.unknown);
    });

    test('fromPlayCoreValue returns updateNotAvailable for 1', () {
      expect(UpdateAvailability.fromPlayCoreValue(1), UpdateAvailability.updateNotAvailable);
    });

    test('fromPlayCoreValue returns updateAvailable for 2', () {
      expect(UpdateAvailability.fromPlayCoreValue(2), UpdateAvailability.updateAvailable);
    });

    test('fromPlayCoreValue returns developerTriggeredUpdateInProgress for 3', () {
      expect(
        UpdateAvailability.fromPlayCoreValue(3),
        UpdateAvailability.developerTriggeredUpdateInProgress,
      );
    });
  });

  group('InstallStatus', () {
    test('fromPlayCoreValue returns unknown for 0', () {
      expect(InstallStatus.fromPlayCoreValue(0), InstallStatus.unknown);
    });

    test('fromPlayCoreValue returns pending for 1', () {
      expect(InstallStatus.fromPlayCoreValue(1), InstallStatus.pending);
    });

    test('fromPlayCoreValue returns downloading for 2', () {
      expect(InstallStatus.fromPlayCoreValue(2), InstallStatus.downloading);
    });

    test('fromPlayCoreValue returns downloaded for 11', () {
      expect(InstallStatus.fromPlayCoreValue(11), InstallStatus.downloaded);
    });

    test('fromPlayCoreValue returns installing for 5', () {
      expect(InstallStatus.fromPlayCoreValue(5), InstallStatus.installing);
    });

    test('fromPlayCoreValue returns installed for 6', () {
      expect(InstallStatus.fromPlayCoreValue(6), InstallStatus.installed);
    });

    test('fromPlayCoreValue returns failed for 7', () {
      expect(InstallStatus.fromPlayCoreValue(7), InstallStatus.failed);
    });

    test('fromPlayCoreValue returns canceled for 8', () {
      expect(InstallStatus.fromPlayCoreValue(8), InstallStatus.canceled);
    });
  });

  group('InAppUpdate streams', () {
    test('installStateListener emits mapped InstallState objects', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(
        const EventChannel('in_app_update_android/stateEvents'),
        MockStreamHandler.inline(
          onListen: (dynamic arguments, MockStreamHandlerEventSink events) {
            events.success({
              'installStatus': 2,
              'bytesDownloaded': 500,
              'totalBytesToDownload': 1000,
              'installErrorCode': 0,
            });
            events.success({
              'installStatus': 11,
              'bytesDownloaded': 1000,
              'totalBytesToDownload': 1000,
              'installErrorCode': 0,
            });
          },
          onCancel: (dynamic arguments) {},
        ),
      );

      final events = await InAppUpdate.installStateListener.take(2).toList();

      expect(events.length, 2);
      expect(events[0].installStatus, InstallStatus.downloading);
      expect(events[0].bytesDownloaded, 500);
      expect(events[0].totalBytesToDownload, 1000);
      expect(events[0].installErrorCode, 0);

      expect(events[1].installStatus, InstallStatus.downloaded);
      expect(events[1].bytesDownloaded, 1000);
      expect(events[1].totalBytesToDownload, 1000);
      expect(events[1].installErrorCode, 0);
    });

    test('installUpdateListener emits mapped InstallStatus values', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(
        const EventChannel('in_app_update_android/stateEvents'),
        MockStreamHandler.inline(
          onListen: (dynamic arguments, MockStreamHandlerEventSink events) {
            events.success({
              'installStatus': 2,
              'bytesDownloaded': 500,
              'totalBytesToDownload': 1000,
              'installErrorCode': 0,
            });
            events.success({
              'installStatus': 11,
              'bytesDownloaded': 1000,
              'totalBytesToDownload': 1000,
              'installErrorCode': 0,
            });
          },
          onCancel: (dynamic arguments) {},
        ),
      );

      final events = await InAppUpdate.installUpdateListener.take(2).toList();

      expect(events.length, 2);
      expect(events[0], InstallStatus.downloading);
      expect(events[1], InstallStatus.downloaded);
    });
  });
}
