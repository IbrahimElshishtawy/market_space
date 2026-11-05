import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/repositories/building_materials_repository.dart';
import 'package:market_space/features/building_materials/presentation/controllers/category_detail_controller.dart';
import 'package:market_space/features/building_materials/presentation/pages/building_material_category_detail_page.dart';

void main() {
  group('BuildingMaterialCategoryDetailPage Tests', () {
    late BuildingMaterialsRepository repository;

    setUp(() {
      repository = const BuildingMaterialsRepositoryImpl(
        networkDelay: Duration.zero,
      );
    });

    test('Loads category detail for Cement category', () async {
      final controller = CategoryDetailController(
        categoryId: 'cat-cement',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadData();

      expect(controller.value.isLoading, false);
      expect(controller.value.categoryDetail, isNotNull);
      expect(controller.value.categoryDetail!.title, 'الأسمنت والمونة');
      expect(controller.value.categoryDetail!.products.length, 4);
    });

    test('Loads category detail for Bricks category', () async {
      final controller = CategoryDetailController(
        categoryId: 'cat-bricks',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadData();

      expect(controller.value.isLoading, false);
      expect(controller.value.categoryDetail!.title, 'الطوب والبلوك');
    });

    testWidgets('Renders Cement category page elements correctly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = CategoryDetailController(
        categoryId: 'cat-cement',
        repository: repository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BuildingMaterialCategoryDetailPage(
            categoryId: 'cat-cement',
            controller: controller,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الأسمنت والمونة'), findsOneWidget);
      expect(find.text('سعر طن الأسمنت اليوم'), findsOneWidget);
      expect(find.text('2,850 ج.م / طن'), findsWidgets);
      expect(find.text('أسمنت بورتلاندي عادي (شكارة 50كجم)'), findsOneWidget);
      expect(
        find.text('أسمنت بني سويف مقاوم للأملاح والأساسات'),
        findsOneWidget,
      );
    });

    testWidgets('Renders Sand category page elements correctly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = CategoryDetailController(
        categoryId: 'cat-sand',
        repository: repository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BuildingMaterialCategoryDetailPage(
            categoryId: 'cat-sand',
            controller: controller,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('الرمل والزلط'), findsOneWidget);
      expect(find.text('سعر متر الرمل والزلط اليوم'), findsOneWidget);
      expect(find.text('350 ج.م / متر مكعب'), findsWidgets);
      expect(find.text('رمل حرش ممتاز للخرسانات والمونة'), findsOneWidget);
    });
  });
}
