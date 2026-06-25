import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update_android/in_app_update_android.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InAppUpdateAndroid', () {
    final inAppUpdate = InAppUpdateAndroid();

    test('checkUpdateAndroid throws when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        () => inAppUpdate.checkUpdateAndroid(),
        throwsA(isA<Exception>()),
      );
    });

    test('checkUpdateAndroid returns AppUpdateInfoAndroid on success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return {
            'updateAvailability': 2,
            'availableVersionCode': 2,
            'updatePriority': 0,
            'clientVersionStalenessDays': null,
            'isImmediateUpdateAllowed': true,
            'isFlexibleUpdateAllowed': true,
            'installStatus': 1,
          };
        },
      );

      final info = await inAppUpdate.checkUpdateAndroid();

      expect(info.updateAvailability, UpdateAvailabilityAndroid.updateAvailable);
      expect(info.availableVersionCode, 2);
      expect(info.isImmediateUpdateAllowed, true);
      expect(info.isFlexibleUpdateAllowed, true);
    });

    test('startImmediateUpdateAndroid throws when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        () => inAppUpdate.startImmediateUpdateAndroid(),
        throwsA(isA<Exception>()),
      );
    });

    test('startImmediateUpdateAndroid returns success', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return 0;
        },
      );

      final result = await inAppUpdate.startImmediateUpdateAndroid();

      expect(result, UpdateResultAndroid.success);
    });

    test('startFlexibleUpdateAndroid throws when channel returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        () => inAppUpdate.startFlexibleUpdateAndroid(),
        throwsA(isA<Exception>()),
      );
    });

    test('startFlexibleUpdateAndroid returns userCanceled', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return 1;
        },
      );

      final result = await inAppUpdate.startFlexibleUpdateAndroid();

      expect(result, UpdateResultAndroid.userCanceled);
    });

    test('completeUpdateAndroid does not throw', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      expect(
        inAppUpdate.completeUpdateAndroid(),
        completes,
      );
    });

    test('installStateStreamAndroid emits events', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('in_app_update_android'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      final events = <InstallStateAndroid>[];
      final subscription = inAppUpdate.installStateStreamAndroid.listen(
        (state) => events.add(state),
      );

      await Future.delayed(Duration.zero);
      await subscription.cancel();

      // No events emitted since no native side pushes data
      expect(events, isEmpty);
    });
  });

  group('UpdateResultAndroid', () {
    test('fromValue returns success for 0', () {
      expect(UpdateResultAndroid.fromValue(0), UpdateResultAndroid.success);
    });

    test('fromValue returns userCanceled for 1', () {
      expect(UpdateResultAndroid.fromValue(1), UpdateResultAndroid.userCanceled);
    });

    test('fromValue returns inAppUpdateFailed for 2', () {
      expect(UpdateResultAndroid.fromValue(2), UpdateResultAndroid.inAppUpdateFailed);
    });

    test('fromValue returns inAppUpdateFailed for unknown values', () {
      expect(UpdateResultAndroid.fromValue(99), UpdateResultAndroid.inAppUpdateFailed);
    });
  });

  group('UpdateAvailabilityAndroid', () {
    test('fromPlayCoreValue returns unknown for 0', () {
      expect(UpdateAvailabilityAndroid.fromPlayCoreValue(0), UpdateAvailabilityAndroid.unknown);
    });

    test('fromPlayCoreValue returns updateNotAvailable for 1', () {
      expect(UpdateAvailabilityAndroid.fromPlayCoreValue(1), UpdateAvailabilityAndroid.updateNotAvailable);
    });

    test('fromPlayCoreValue returns updateAvailable for 2', () {
      expect(UpdateAvailabilityAndroid.fromPlayCoreValue(2), UpdateAvailabilityAndroid.updateAvailable);
    });

    test('fromPlayCoreValue returns developerTriggeredUpdateInProgress for 3', () {
      expect(
        UpdateAvailabilityAndroid.fromPlayCoreValue(3),
        UpdateAvailabilityAndroid.developerTriggeredUpdateInProgress,
      );
    });
  });

  group('InstallStatusAndroid', () {
    test('fromPlayCoreValue returns unknown for 0', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(0), InstallStatusAndroid.unknown);
    });

    test('fromPlayCoreValue returns pending for 1', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(1), InstallStatusAndroid.pending);
    });

    test('fromPlayCoreValue returns downloading for 2', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(2), InstallStatusAndroid.downloading);
    });

    test('fromPlayCoreValue returns downloaded for 11', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(11), InstallStatusAndroid.downloaded);
    });

    test('fromPlayCoreValue returns installing for 5', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(5), InstallStatusAndroid.installing);
    });

    test('fromPlayCoreValue returns installed for 6', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(6), InstallStatusAndroid.installed);
    });

    test('fromPlayCoreValue returns failed for 7', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(7), InstallStatusAndroid.failed);
    });

    test('fromPlayCoreValue returns canceled for 8', () {
      expect(InstallStatusAndroid.fromPlayCoreValue(8), InstallStatusAndroid.canceled);
    });
  });
}
