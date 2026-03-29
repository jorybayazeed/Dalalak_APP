// Basic smoke test for the Daleelak app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tour_app/main.dart';

void main() {
  testWidgets('App renders startup error view when initialization fails',
      (WidgetTester tester) async {
    // Pump the app with a simulated initialization error so that no Firebase
    // or GetX services are needed during the test.
    await tester.pumpWidget(
      const MyApp(initializationError: 'Test error'),
    );

    // The startup error view should be shown with the error message.
    expect(find.text('Initialization Error'), findsOneWidget);
    expect(find.text('Test error'), findsOneWidget);
  });
}
