import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/data/repositories/real_estate_repository.dart';
import 'package:market_space/features/real_estate/presentation/controllers/real_estate_detail_controller.dart';
import 'package:market_space/features/real_estate/presentation/pages/real_estate_detail_page.dart';

void main() {
  group('RealEstateDetailPage & DetailController Tests', () {
    late MockRealEstateRepository repository;
    late RealEstateDetailController controller;

    setUp(() {
      repository = MockRealEstateRepository();
      controller = RealEstateDetailController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Controller loads property detail successfully', () async {
      expect(controller.value.isLoading, true);

      await controller.loadDetail('aqar-1');

      expect(controller.value.isLoading, false);
      expect(controller.value.detail, isNotNull);
      expect(controller.value.detail!.title, contains('شقة مودرن بفيو مفتوح'));
      expect(controller.value.detail!.specs.length, 9);
      expect(controller.value.detail!.advertiser.name, 'أ. أحمد سليمان');
    });

    test('Controller updates photo index and expand state', () async {
      await controller.loadDetail('aqar-1');

      controller.setPhotoIndex(3);
      expect(controller.value.currentPhotoIndex, 3);

      expect(controller.value.isExpanded, true);
      controller.toggleExpand();
      expect(controller.value.isExpanded, false);
    });

    testWidgets('RealEstateDetailPage renders all screenshot components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RealEstateDetailPage(
            listingId: 'aqar-1',
            controller: controller,
          ),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Title & Header Info
      expect(
        find.text('شقة مودرن بفيو مفتوح على الشارع الرئيسي'),
        findsOneWidget,
      );
      expect(find.text('طنطا، شارع النادي (قريب من الاستاد)'), findsOneWidget);
      expect(find.textContaining('14,000 ج.م'), findsOneWidget);
      expect(find.text('لليجار'), findsOneWidget);

      // Specs 3x3 Grid Items
      expect(find.text('3 غرف'), findsOneWidget);
      expect(find.text('سوبر لوكس'), findsOneWidget);
      expect(find.text('الدور الخامس'), findsOneWidget);
      expect(find.text('2 حمام'), findsOneWidget);
      expect(find.text('175 م²'), findsOneWidget);
      expect(find.text('بحري صريح'), findsOneWidget);
      expect(find.text('أسانسير'), findsOneWidget);
      expect(find.text('غاز طبيعي'), findsOneWidget);
      expect(find.text('جراج بالبدروم'), findsOneWidget);

      // Description & Advertiser Card
      expect(find.text('الوصف التفصيلي'), findsOneWidget);
      expect(
        find.textContaining('فرصة ممتازة للسكن أو الاستثمار الراقي'),
        findsOneWidget,
      );
      expect(find.text('أ. أحمد سليمان'), findsOneWidget);
      expect(find.text('مالك مباشر'), findsOneWidget);
      expect(find.text('واتساب'), findsOneWidget);
      expect(find.text('أتصال'), findsOneWidget);

      // Expand/Collapse Button
      expect(find.text('إخفاء'), findsOneWidget);
    });

    testWidgets('Toggling expand/collapse in RealEstateDetailPage works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RealEstateDetailPage(
            listingId: 'aqar-1',
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hideFinder = find.text('إخفاء');
      await tester.ensureVisible(hideFinder);
      await tester.pumpAndSettle();

      // Tap on 'إخفاء' to collapse
      await tester.tap(hideFinder);
      await tester.pumpAndSettle();

      // Should show 'إظهار التفاصيل'
      final showFinder = find.text('إظهار التفاصيل');
      expect(showFinder, findsOneWidget);
      expect(find.text('أ. أحمد سليمان'), findsNothing);

      // Tap on 'إظهار التفاصيل' to expand
      await tester.ensureVisible(showFinder);
      await tester.pumpAndSettle();
      await tester.tap(showFinder);
      await tester.pumpAndSettle();

      expect(find.text('إخفاء'), findsOneWidget);
      expect(find.text('أ. أحمد سليمان'), findsOneWidget);
    });
  });
}
