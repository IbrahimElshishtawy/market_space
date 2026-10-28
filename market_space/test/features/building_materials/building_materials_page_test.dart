import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/repositories/building_materials_repository.dart';
import 'package:market_space/features/building_materials/presentation/controllers/building_materials_controller.dart';
import 'package:market_space/features/building_materials/presentation/pages/building_materials_page.dart';

void main() {
  group('BuildingMaterials Repository, Controller & Page Tests', () {
    late BuildingMaterialsRepository repository;
    late BuildingMaterialsController controller;

    setUp(() {
      repository = const BuildingMaterialsRepositoryImpl(
        networkDelay: Duration.zero,
      );
      controller = BuildingMaterialsController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Repository fetches all mock building materials data', () async {
      final banner = await repository.getDailyPriceBanner();
      final categories = await repository.getCategories();
      final products = await repository.getMostRequestedProducts();
      final contractorBanner = await repository.getContractorProjectBanner();

      expect(banner.title, 'سعر طن الأسمنت اليوم');
      expect(banner.badgeText, 'تحديث يومي');
      expect(categories.length, 6);
      expect(products.length, 4);
      expect(contractorBanner.title, 'طلبيات المشاريع والمقاولات الخاصة');
    });

    test('Controller loads data and updates state correctly', () async {
      expect(controller.value.isLoading, true);

      await controller.loadData();

      expect(controller.value.isLoading, false);
      expect(controller.value.dailyPriceBanner, isNotNull);
      expect(controller.value.categories.length, 6);
      expect(controller.value.mostRequestedProducts.length, 4);
      expect(controller.value.contractorBanner, isNotNull);
    });

    test('Controller updates selected category and search query', () async {
      await controller.loadData();

      controller.selectCategory('cat-steel');
      expect(controller.value.selectedCategoryId, 'cat-steel');

      // Tapping same category toggles off
      controller.selectCategory('cat-steel');
      expect(controller.value.selectedCategoryId, isNull);

      controller.setSearchQuery('حديد');
      expect(controller.value.searchQuery, 'حديد');
    });

    testWidgets('BuildingMaterialsPage renders screenshot matching UI elements', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BuildingMaterialsPage(controller: controller),
        ),
      );

      // Loading state initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('مصطفي هيكل'), findsOneWidget);
      expect(find.text('الغربية - طنطا'), findsOneWidget);

      // 2. Search hint
      expect(
        find.text('أبحث عن مواد البناء "أسمنت، حديد، طوب"'),
        findsOneWidget,
      );

      // 3. Hero Daily Price Banner
      expect(find.text('تحديث يومي'), findsOneWidget);
      expect(find.text('سعر طن الأسمنت اليوم'), findsOneWidget);
      expect(find.textContaining('2,850 ج.م / طن'), findsOneWidget);
      expect(find.text('اطلب كميتك'), findsOneWidget);

      // 4. Sub-Categories Section ("أقسام مواد البناء")
      expect(find.text('أقسام مواد البناء'), findsOneWidget);
      expect(find.text('حديد التسليح'), findsOneWidget);
      expect(find.text('الأسمنت والمونة'), findsOneWidget);
      expect(find.text('الطوب والبلوك'), findsOneWidget);
      expect(find.text('الرمل والزلط'), findsOneWidget);
      expect(find.text('مواد العزل'), findsOneWidget);
      expect(find.text('أدوات التأسيس'), findsOneWidget);

      // 5. Most Requested Products Section ("الخامات الأكثر طلباً")
      expect(find.text('الخامات الأكثر طلباً'), findsOneWidget);
      expect(find.text('حديد تسليح 12مم - مصانع معتمدة'), findsOneWidget);
      expect(find.text('أسمنت بورتلاندي ممتاز (50 كجم)'), findsOneWidget);
      expect(find.text('طوب خرساني مفرغ (25×12×13 سم)'), findsOneWidget);
      expect(find.text('رمل حرش ممتاز للخرسانة والمونة'), findsOneWidget);

      // 6. Contractor Projects Banner
      expect(find.text('طلبيات المشاريع والمقاولات الخاصة'), findsOneWidget);
      expect(find.text('اطلب مقايسة مخصصة'), findsOneWidget);
    });

    testWidgets('Tapping sub-category tile selects it in state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BuildingMaterialsPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('حديد التسليح'));
      await tester.pumpAndSettle();

      expect(controller.value.selectedCategoryId, 'cat-steel');
    });
  });
}
