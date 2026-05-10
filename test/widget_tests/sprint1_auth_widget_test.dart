import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sprint 1 Widget Tests (Authentication)', () {
    
    testWidgets('TC1: Smoke test - basic widget renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Sprint 1 Auth Test')),
          ),
        ),
      );
      
      expect(find.text('Sprint 1 Auth Test'), findsOneWidget);
    });
    
  });
}