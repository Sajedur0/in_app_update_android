import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_update_android/in_app_update_android.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InAppUpdateExampleApp());
}

class InAppUpdateExampleApp extends StatelessWidget {
  const InAppUpdateExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-App Update Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InAppUpdateScreen(),
    );
  }
}

class InAppUpdateScreen extends StatefulWidget {
  const InAppUpdateScreen({super.key});

  @override
  State<InAppUpdateScreen> createState() => _InAppUpdateScreenState();
}

class _InAppUpdateScreenState extends State<InAppUpdateScreen> {
  String _status = 'Tap a button to start';
  bool _loading = false;
  StreamSubscription<InstallState>? _installStateSubscription;

  @override
  void initState() {
    super.initState();
    _installStateSubscription = InAppUpdate.installStateListener.listen(
      (state) {
        if (!mounted) return;
        final progress = state.downloadProgress;
        setState(() {
          _status = progress == null
              ? 'Install state: ${state.installStatus}'
              : 'Install state: ${state.installStatus}\n'
                    'Progress: ${(progress * 100).toStringAsFixed(1)}%';
        });

        if (state.installStatus == InstallStatus.downloaded) {
          InAppUpdate.completeFlexibleUpdate();
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _status = 'Install state error: $error');
      },
    );
  }

  Future<void> checkForUpdate() async {
    setState(() => _loading = true);
    try {
      final info = await InAppUpdate.checkForUpdate();
      setState(() {
        _status =
            'Availability: ${info.updateAvailability}\n'
            'Package: ${info.packageName}\n'
            'Version code: ${info.availableVersionCode}\n'
            'Priority: ${info.updatePriority}';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> performImmediateUpdate() async {
    setState(() => _loading = true);
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      setState(() => _status = 'Immediate update result: $result');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> startFlexibleUpdate() async {
    setState(() => _loading = true);
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      setState(() => _status = 'Flexible update result: $result');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _installStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> completeFlexibleUpdate() async {
    setState(() => _loading = true);
    try {
      await InAppUpdate.completeFlexibleUpdate();
      setState(() => _status = 'Flexible update completed');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Update Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (_loading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: checkForUpdate,
                  child: const Text('Check for Update'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: performImmediateUpdate,
                  child: const Text('Perform Immediate Update'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: startFlexibleUpdate,
                  child: const Text('Start Flexible Update'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: completeFlexibleUpdate,
                  child: const Text('Complete Flexible Update'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
