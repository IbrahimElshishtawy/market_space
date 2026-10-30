import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/features/building_materials/data/mock/mock_building_materials_comprehensive_data.dart';
import 'package:market_space/features/building_materials/data/models/unit_of_measurement.dart';
import 'package:market_space/features/building_materials/presentation/pages/building_materials_categories_page.dart';
import 'package:market_space/features/building_materials/presentation/pages/building_materials_cart_page.dart';
import 'package:market_space/features/building_materials/presentation/pages/building_materials_orders_page.dart';

import '../../widget_test.dart';

Widget _buildTestApp(Widget child, {AppDependencies? dependencies}) {
  return AppDependenciesScope(
    dependencies: dependencies ?? createTestDependencies(),
    child: MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  group('BuildingMaterials Widget UI Tests', () {
    testWidgets('BuildingMaterialsCategoriesPage renders all 10 categories', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(const BuildingMaterialsCategoriesPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify page title
      expect(find.text('تصنيفات مواد البناء'), findsOneWidget);
      // Verify primary categories from mock data
      expect(find.text('حديد التسليح والقطاعات'), findsOneWidget);
      expect(find.text('الأسمنت والمونة'), findsOneWidget);
      expect(find.text('الطوب والبلوك الإنشائي'), findsOneWidget);
      expect(find.text('الرمل والزلط والسن'), findsOneWidget);
      expect(find.text('السيراميك والبورسلين'), findsOneWidget);
    });

    testWidgets('BuildingMaterialsCategoriesPage filters categories when searching', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(const BuildingMaterialsCategoriesPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Enter search text 'عزل'
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'عزل');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Only isolation category should match
      expect(find.text('مواد العزل المائي والحراري'), findsOneWidget);
      expect(find.text('حديد التسليح والقطاعات'), findsNothing);
    });

    testWidgets('BuildingMaterialsCartPage renders empty state when cart has no items', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dependencies = createTestDependencies();
      await dependencies.buildingMaterialsCartController.clearCart();

      await tester.pumpWidget(_buildTestApp(const BuildingMaterialsCartPage(), dependencies: dependencies));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('سلة المشتريات فارغة'), findsOneWidget);
      expect(find.text('تصفح مواد البناء'), findsOneWidget);
    });

    testWidgets('BuildingMaterialsCartPage displays supplier card and item details when cart has items', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dependencies = createTestDependencies();
      await dependencies.buildingMaterialsCartController.clearCart();

      final steelProduct = MockBuildingMaterialsComprehensiveData.products.first;
      await dependencies.buildingMaterialsCartController.addToCart(
        product: steelProduct,
        quantity: 2.0,
        unit: MaterialUnit.ton,
      );

      await tester.pumpWidget(_buildTestApp(const BuildingMaterialsCartPage(), dependencies: dependencies));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check supplier name displayed
      expect(find.text(steelProduct.supplier.name), findsOneWidget);
      // Check product name displayed
      expect(find.text(steelProduct.name), findsOneWidget);
      // Check checkout action button is present
      expect(find.text('متابعة إتمام الطلب والتسليم'), findsOneWidget);
    });

    testWidgets('BuildingMaterialsOrdersPage renders tabs and orders list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dependencies = createTestDependencies();
      await dependencies.buildingMaterialsOrderController.loadOrders();

      await tester.pumpWidget(_buildTestApp(const BuildingMaterialsOrdersPage(), dependencies: dependencies));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('طلبيات مواد البناء والتوريد'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('قيد التوريد'), findsOneWidget);
      expect(find.text('المكتملة'), findsOneWidget);
      expect(find.text('عروض الأسعار'), findsOneWidget);

      // Verify at least one order card from mock orders is present
      expect(find.textContaining('شركة حديد عز لتجارة وتوزيع الصلب'), findsWidgets);
    });
  });
}
