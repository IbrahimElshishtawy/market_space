import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/home_appliances/data/repositories/home_appliances_repository.dart';
import 'package:market_space/features/home_appliances/presentation/controllers/home_appliances_controller.dart';
import 'package:market_space/features/home_appliances/presentation/pages/home_appliances_page.dart';

void main() {
  group('HomeAppliancesPage & Controller Tests', () {
    late MockHomeAppliancesRepository repository;
    late HomeAppliancesController controller;

    setUp(() {
      repository = MockHomeAppliancesRepository();
      controller = HomeAppliancesController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Controller loads categories, hero banner and products', () async {
      expect(controller.value.isLoading, true);

      await controller.loadData();

      expect(controller.value.isLoading, false);
      expect(controller.value.categories.length, 8);
      expect(controller.value.heroBanner, isNotNull);
      expect(controller.value.products.length, 4);
    });

    test('Filtering by category key filters products correctly', () async {
      await controller.loadData();

      controller.setCategoryFilter('cat-fridge');
      await Future.delayed(const Duration(milliseconds: 300));

      final items = controller.value.products;
      expect(items.length, 1);
      expect(items.first.title, contains('ثلاجة توشيبا'));
    });

    test('Searching by query filters products by title or brand', () async {
      await controller.loadData();

      controller.setSearchQuery('SAMSUNG');
      await Future.delayed(const Duration(milliseconds: 300));

      final items = controller.value.products;
      expect(items.length, 1);
      expect(items.first.title, contains('سامسونج'));
    });

    testWidgets('HomeAppliancesPage renders matching screenshot content', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: HomeAppliancesPage(controller: controller)),
      );

      // Initial Loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Header Info
      expect(find.text('مصطفي هيكل'), findsOneWidget);
      expect(find.text('الغربية - طنطا'), findsOneWidget);

      // Search hint
      expect(find.text('ابحث عن جهاز، ماركة، أو موديل...'), findsOneWidget);

      // Hero Banner
      expect(find.text('عرض اليوم'), findsOneWidget);
      expect(find.textContaining('خصم يصل إلى 30%'), findsOneWidget);
      expect(find.text('تسوق الآن'), findsOneWidget);

      // Categories Section
      expect(find.text('تصفّح حسب الفئة'), findsOneWidget);
      expect(find.text('شاشات وتلفزيونات'), findsOneWidget);
      expect(find.text('ثلاجات وديب فريزر'), findsOneWidget);
      expect(find.text('غسالات ومجففات'), findsOneWidget);
      expect(find.text('بوتاجازات وأفران'), findsOneWidget);
      expect(find.text('تكييفات ومراوح'), findsOneWidget);
      expect(find.text('أجهزة المطبخ'), findsOneWidget);
      expect(find.text('أجهزة صغيرة'), findsOneWidget);
      expect(find.text('سخانات وفلاتر'), findsOneWidget);

      // Financing Banner
      expect(find.text('قسط أجهزتك على 12 أو 24 شهر'), findsOneWidget);
      expect(find.text('اعرف لمتك'), findsOneWidget);

      // Products Grid Section
      expect(find.text('الأكثر طلباً في طنطا'), findsOneWidget);
      expect(find.text('ثلاجة توشيبا نوفروست'), findsOneWidget);
      expect(find.text('شاشة سامسونج 55'), findsOneWidget);
      expect(find.text('تكييف كاريير أوبتيماكس'), findsOneWidget);
      expect(find.text('ماكينة إسبريسو ديلونجي'), findsOneWidget);

      // Add to cart buttons
      expect(find.text('أضف للسلة'), findsNWidgets(4));
    });

    testWidgets('Tapping category filters product list', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: HomeAppliancesPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      // Tap on 'ثلاجات وديب فريزر'
      await tester.tap(find.text('ثلاجات وديب فريزر'));
      await tester.pumpAndSettle();

      // Only Toshiba Fridge should remain
      expect(find.text('ثلاجة توشيبا نوفروست'), findsOneWidget);
      expect(find.text('شاشة سامسونج 55'), findsNothing);
    });
  });
}
