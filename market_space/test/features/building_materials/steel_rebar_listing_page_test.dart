import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/repositories/building_materials_repository.dart';
import 'package:market_space/features/building_materials/presentation/controllers/steel_rebar_controller.dart';
import 'package:market_space/features/building_materials/presentation/pages/steel_rebar_listing_page.dart';
import 'package:market_space/features/building_materials/widgets/steel_rebar_filter_chips/size_filter_chip.dart';

void main() {
  group('SteelRebar Listing Controller & Page Tests', () {
    late BuildingMaterialsRepository repository;
    late SteelRebarController controller;

    setUp(() {
      repository = const BuildingMaterialsRepositoryImpl(
        networkDelay: Duration.zero,
      );
      controller = SteelRebarController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Controller loads steel daily price, sizes, and products', () async {
      expect(controller.value.isLoading, true);

      await controller.loadData();

      expect(controller.value.isLoading, false);
      expect(controller.value.dailyPrice, isNotNull);
      expect(controller.value.dailyPrice!.title, 'سعر طن الحديد اليوم');
      expect(controller.value.availableSizes.length, 5);
      expect(controller.value.products.length, 4);
    });

    test('Selecting a size filters steel products list', () async {
      await controller.loadData();

      await controller.selectSize('12 مم');
      expect(controller.value.selectedSize, '12 مم');
      expect(controller.value.products.length, 1);
      expect(controller.value.products.first.brandName, 'حديد عز');

      await controller.selectSize('الكل');
      expect(controller.value.products.length, 4);
    });

    testWidgets('SteelRebarListingPage renders screenshot matching content', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: SteelRebarListingPage(controller: controller)),
      );

      // Loading State
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // 1. Header Title & Subtitle
      expect(find.text('حديد التسليح'), findsOneWidget);
      expect(
        find.text('حديد معتمد من كبرى المصانع بتوريد مباشر للموقع.'),
        findsOneWidget,
      );

      // 2. Size Filter Chips
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('8 مم'), findsOneWidget);
      expect(find.widgetWithText(SizeFilterChip, '10 مم'), findsOneWidget);
      expect(find.widgetWithText(SizeFilterChip, '12 مم'), findsOneWidget);
      expect(find.widgetWithText(SizeFilterChip, '14 مم'), findsOneWidget);

      // 3. Hero Daily Steel Price Banner
      expect(find.text('سعر طن الحديد اليوم'), findsOneWidget);
      expect(find.text('38,500 ج.م / طن'), findsWidgets);
      expect(find.text('+1.5%'), findsOneWidget);
      expect(find.text('سجل الأسعار'), findsOneWidget);
      expect(find.text('اطلب كميتك'), findsOneWidget);

      // 4. Products Section ("المنتجات المتاحة")
      expect(find.text('المنتجات المتاحة'), findsOneWidget);
      expect(find.text('حديد تسليح عز (أطوال) 12مم'), findsOneWidget);
      expect(find.text('حديد تسليح بشاي 16 مم'), findsOneWidget);
      expect(find.text('حديد تسليح المصريين 10مم'), findsOneWidget);
      expect(find.text('حديد تسليح الجارحي 14 مم'), findsOneWidget);
    });

    testWidgets('Tapping size filter chip filters visible brand products', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(home: SteelRebarListingPage(controller: controller)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(SizeFilterChip, '12 مم'));
      await tester.pumpAndSettle();

      expect(find.text('حديد تسليح عز (أطوال) 12مم'), findsOneWidget);
      expect(find.text('حديد تسليح بشاي 16 مم'), findsNothing);
    });
  });
}
