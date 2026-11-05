import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/home_appliances/data/repositories/home_appliances_repository.dart';
import 'package:market_space/features/home_appliances/presentation/controllers/appliance_category_listing_controller.dart';
import 'package:market_space/features/home_appliances/presentation/pages/appliance_category_listing_page.dart';

void main() {
  group('ApplianceCategoryListingPage & Controller Tests', () {
    late MockHomeAppliancesRepository repository;
    late ApplianceCategoryListingController controller;

    setUp(() {
      repository = MockHomeAppliancesRepository();
      controller = ApplianceCategoryListingController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Controller loads category details and TV products', () async {
      expect(controller.value.isLoading, true);

      await controller.loadCategory('cat-tv');

      expect(controller.value.isLoading, false);
      expect(controller.value.categoryDetail, isNotNull);
      expect(controller.value.categoryDetail!.title, 'شاشات وتلفزيونات');
      expect(controller.value.products.length, 8);
    });

    test('Filter chip selection reloads filtered products list', () async {
      await controller.loadCategory('cat-tv');

      controller.selectFilterChip('الماركة ˅');
      await Future.delayed(const Duration(milliseconds: 250));

      expect(controller.value.selectedChip, 'الماركة ˅');
      expect(controller.value.products.length, 8);
    });

    testWidgets(
      'ApplianceCategoryListingPage renders matching screenshot content',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2800);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: ApplianceCategoryListingPage(
              categoryId: 'cat-tv',
              controller: controller,
            ),
          ),
        );

        // Loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        // Header title and subtitle
        expect(find.text('شاشات وتلفزيونات'), findsOneWidget);
        expect(find.textContaining('أحدث شاشات Smart & 4K'), findsOneWidget);

        // Filter chips
        expect(find.text('الكل'), findsOneWidget);
        expect(find.text('السعر ˅'), findsOneWidget);
        expect(find.text('الحجم ˅'), findsOneWidget);
        expect(find.text('الماركة ˅'), findsOneWidget);

        // TV Products
        expect(find.text('شاشة سامسونج 55 بوصة Smart 4K'), findsOneWidget);
        expect(find.text('شاشة إل جي (LG) 65 بوصة OLED 4K'), findsOneWidget);
        expect(find.text('شاشة توشيبا 43 بوصة Smart FHD'), findsOneWidget);
        expect(find.text('شاشة تورنيدو 50 بوصة Smart 4K'), findsOneWidget);
        expect(find.text('شاشة سوني (Sony) 55 بوصة Bravia 4K'), findsOneWidget);
        expect(find.text('شاشة جاك (JAC) 32 بوصة LED HD'), findsOneWidget);
        expect(find.text('شاشة شارب 55 بوصة Smart 4K'), findsOneWidget);
        expect(find.text('شاشة فريش 43 بوصة Smart FHD'), findsOneWidget);

        // Brand Badges
        expect(find.text('SAMSUNG'), findsOneWidget);
        expect(find.text('LG'), findsOneWidget);
        expect(find.text('TOSHIBA'), findsOneWidget);
        expect(find.text('TORNADO'), findsOneWidget);
        expect(find.text('SONY'), findsOneWidget);
        expect(find.text('J.A.C'), findsOneWidget);
        expect(find.text('SHARP'), findsOneWidget);
        expect(find.text('FRESH'), findsOneWidget);

        // Cart buttons
        expect(find.text('أضف للسلة'), findsNWidgets(8));
      },
    );

    testWidgets('Tapping a filter chip updates selected chip state', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2800);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ApplianceCategoryListingPage(
            categoryId: 'cat-tv',
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'الماركة ˅' chip
      await tester.tap(find.text('الماركة ˅'));
      await tester.pumpAndSettle();

      expect(controller.value.selectedChip, 'الماركة ˅');
    });
  });
}
