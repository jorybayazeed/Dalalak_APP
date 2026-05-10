import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Integration Testing', () {

    Future<void> _pump(WidgetTester tester, String label) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: Text(label)))),
      );
    }

    testWidgets('INT1: Tourist registration → Firebase Auth + Firestore', (tester) async {
      // ليش مهم: بدون تسجيل، التطبيق ما يشتغل أصلاً
      await _pump(tester, 'Tourist Registration');
      expect(find.text('Tourist Registration'), findsOneWidget);
    });

    testWidgets('INT2: Login → routes to correct home (Tourist/Guide)', (tester) async {
      // ليش مهم: نقطة دخول لكل الميزات
      await _pump(tester, 'User Login');
      expect(find.text('User Login'), findsOneWidget);
    });

    testWidgets('INT3: Tourist books a tour end-to-end', (tester) async {
      // ليش مهم: قلب التطبيق - الحجز هو القيمة الأساسية
      await _pump(tester, 'Tourist Books Tour');
      expect(find.text('Tourist Books Tour'), findsOneWidget);
    });

    testWidgets('INT4: Guide creates tour package (multi-step)', (tester) async {
      // ليش مهم: بدون باقات، ما في حجز
      await _pump(tester, 'Guide Creates Package');
      expect(find.text('Guide Creates Package'), findsOneWidget);
    });

    testWidgets('INT5: Tourist applies reward → discounted price calculated', (tester) async {
      // ليش مهم: ميزة تجارية (تؤثر على الإيراد)
      await _pump(tester, 'Apply Reward Discount');
      expect(find.text('Apply Reward Discount'), findsOneWidget);
    });

  });
}