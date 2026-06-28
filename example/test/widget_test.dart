import 'package:flutter_test/flutter_test.dart';

import 'package:in_app_update_android_example/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const InAppUpdateExampleApp());

    expect(find.text('In-App Update Example'), findsOneWidget);
    expect(find.text('Check for Update'), findsOneWidget);
    expect(find.text('Perform Immediate Update'), findsOneWidget);
    expect(find.text('Start Flexible Update'), findsOneWidget);
    expect(find.text('Complete Flexible Update'), findsOneWidget);
  });
}
