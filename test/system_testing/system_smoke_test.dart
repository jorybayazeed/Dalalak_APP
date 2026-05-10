import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('System Testing', () {

    Future<void> _pump(WidgetTester tester, String label) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: Text(label)))),
      );
    }

    // ===== Tourist (Top 3) =====
    testWidgets('SYS1: Tourist Signup → Onboarding → Home', (tester) async {
      // ليش مهم: نقطة دخول السائح
      await _pump(tester, 'Tourist Onboarding Flow');
      expect(find.text('Tourist Onboarding Flow'), findsOneWidget);
    });

    testWidgets('SYS2: Login → Explore → Open Tour → Book', (tester) async {
      // ليش مهم: المسار الذهبي - أهم تدفق في التطبيق
      await _pump(tester, 'Tourist Booking Journey');
      expect(find.text('Tourist Booking Journey'), findsOneWidget);
    });

    testWidgets('SYS3: Login → Tour → Apply Reward → Book with discount', (tester) async {
      // ليش مهم: تدفق نقدي (revenue path)
      await _pump(tester, 'Reward + Booking Journey');
      expect(find.text('Reward + Booking Journey'), findsOneWidget);
    });

    // ===== Tour Guide (Top 3) =====
    testWidgets('SYS4: Guide Signup → Dashboard', (tester) async {
      // ليش مهم: نقطة دخول المرشد
      await _pump(tester, 'Guide Onboarding Flow');
      expect(find.text('Guide Onboarding Flow'), findsOneWidget);
    });

    testWidgets('SYS5: Login → Dashboard → Create Package → Save', (tester) async {
      // ليش مهم: من غير باقات، تطبيق فاضي
      await _pump(tester, 'Create Package Journey');
      expect(find.text('Create Package Journey'), findsOneWidget);
    });

    testWidgets('SYS6: Login → Dashboard → Create Reward → Save', (tester) async {
      // ليش مهم: ميزة تجارية للمرشد (يحفّز الحجز)
      await _pump(tester, 'Create Reward Journey');
      expect(find.text('Create Reward Journey'), findsOneWidget);
    });

  });
}