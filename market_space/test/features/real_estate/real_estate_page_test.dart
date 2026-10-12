import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/data/models/real_estate_listing_model.dart';
import 'package:market_space/features/real_estate/data/repositories/real_estate_repository.dart';
import 'package:market_space/features/real_estate/presentation/controllers/real_estate_controller.dart';
import 'package:market_space/features/real_estate/presentation/pages/real_estate_page.dart';

void main() {
  group('RealEstatePage & Controller Tests', () {
    late MockRealEstateRepository repository;
    late RealEstateController controller;

    setUp(() {
      repository = MockRealEstateRepository();
      controller = RealEstateController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Controller loads mock listings successfully', () async {
      expect(controller.value.isLoading, true);

      await controller.loadListings();

      expect(controller.value.isLoading, false);
      expect(controller.value.listings.length, 4);
      expect(
        controller.value.listings.first.title,
        contains('شقة مودرن بفيو مفتوح'),
      );
    });

    test('Filter by RealEstateType.forRent filters items correctly', () async {
      await controller.loadListings();

      controller.setFilterType(RealEstateType.forRent);
      await Future.delayed(const Duration(milliseconds: 350));

      final items = controller.value.listings;
      expect(items.every((item) => item.type == RealEstateType.forRent), true);
      expect(items.length, 2);
    });

    test('Search query filters items by title/location', () async {
      await controller.loadListings();

      controller.setSearchQuery('سيجر');
      await Future.delayed(const Duration(milliseconds: 350));

      final items = controller.value.listings;
      expect(items.length, 1);
      expect(items.first.title, contains('سيجر'));
    });

    testWidgets('RealEstatePage renders matching screenshot content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: RealEstatePage(controller: controller)),
      );

      // Initial loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('مصطفي هيكل'), findsOneWidget);
      expect(find.text('الغربية - طنطا'), findsOneWidget);

      // Check search input hint
      expect(find.text('أبحث عن عقار للبيع أو الإيجار...'), findsOneWidget);

      // Check filter chips
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('شقق للبيع'), findsOneWidget);
      expect(find.text('شقق للإيجار'), findsOneWidget);

      // Check Card 1 content (for rent)
      expect(
        find.text('شقة مودرن بفيو مفتوح على الشارع الرئيسي'),
        findsOneWidget,
      );
      expect(find.textContaining('14,000 ج.م'), findsOneWidget);
      expect(find.text('3 غرفة'), findsOneWidget);
      expect(find.text('سوبر لوكس'), findsOneWidget);
      expect(find.text('الدور الخامس'), findsOneWidget);
      expect(find.text('175 م²'), findsOneWidget);
      expect(find.text('2 حمام'), findsAtLeast(1));

      // Check Card 2 content (for sale)
      expect(
        find.text('شقة بواجهة متميزة في برج سكني جديد بسيجر'),
        findsOneWidget,
      );
      expect(find.textContaining('3,200,000 ج.م'), findsOneWidget);
      expect(find.text('4 غرفة'), findsOneWidget);
      expect(find.text('لوكس'), findsOneWidget);
      expect(find.text('الدور الثالث'), findsOneWidget);
      expect(find.text('210 م²'), findsOneWidget);

      // Check details button
      expect(find.text('التفاصيل'), findsWidgets);
    });

    testWidgets('RealEstatePage handles navigation and filter clicks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: RealEstatePage(controller: controller)),
      );
      await tester.pumpAndSettle();

      // Tap on "شقق للبيع" chip
      await tester.tap(find.text('شقق للبيع'));
      await tester.pumpAndSettle();

      // Should only show forSale items
      expect(find.textContaining('3,200,000 ج.م'), findsOneWidget);
      expect(find.textContaining('14,000 ج.م'), findsNothing);
    });
  });
}
