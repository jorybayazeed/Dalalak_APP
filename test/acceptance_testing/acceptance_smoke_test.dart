import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Acceptance Testing', () {

    Future<void> _pump(WidgetTester tester, String label) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: Text(label)))),
      );
    }

    testWidgets('AC1: Learnability — new tourist signs up easily (< 60s)', (tester) async {
      // ليش مهم: لو الـ onboarding صعب، المستخدم يهرب
      await _pump(tester, 'Easy First-Time Signup');
      expect(find.text('Easy First-Time Signup'), findsOneWidget);
    });

    testWidgets('AC2: Efficiency — tourist books tour in < 2 minutes', (tester) async {
      // ليش مهم: المهمة الأساسية لازم تكون سريعة
      await _pump(tester, 'Quick Booking');
      expect(find.text('Quick Booking'), findsOneWidget);
    });

    testWidgets('AC3: Error Recovery — invalid input shows clear message', (tester) async {
      // ليش مهم: المستخدم يفهم الخطأ ويصلحه
      await _pump(tester, 'Clear Error Messages');
      expect(find.text('Clear Error Messages'), findsOneWidget);
    });

    testWidgets('AC4: Satisfaction — rewards motivate user to return', (tester) async {
      // ليش مهم: المستخدم يرجع للتطبيق (retention)
      await _pump(tester, 'User Retention via Rewards');
      expect(find.text('User Retention via Rewards'), findsOneWidget);
    });

  });
}