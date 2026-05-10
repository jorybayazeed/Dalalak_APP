import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Sprint 2 Widget Tests (Tour Packages)', () {
    
    testWidgets('TC1: Smoke test - basic widget renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Sprint 2 Packages Test')),
          ),
        ),
      );
      
      expect(find.text('Sprint 2 Packages Test'), findsOneWidget);
    });
    
  });
}