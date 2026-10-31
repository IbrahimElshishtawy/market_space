import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/features/home_services/presentation/pages/home_services_page.dart';
import 'package:market_space/features/home_services/presentation/views/home_services_bookings_view.dart';
import 'package:market_space/features/home_services/presentation/views/home_services_catalog_view.dart';
import 'package:market_space/features/home_services/presentation/views/home_services_favorites_view.dart';
import 'package:market_space/features/home_services/presentation/views/home_services_home_view.dart';

import '../../widget_test.dart';

Widget _buildTestApp(Widget child, {AppDependencies? dependencies}) {
  return AppDependenciesScope(
    dependencies: dependencies ?? createTestDependencies(),
    child: MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('Home Services Widget UI Tests', () {
    testWidgets('HomeServicesPage renders shell and 5 navigation tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(const HomeServicesPage()));
      await tester.pumpAndSettle();

      expect(find.text('الرئيسية'), findsWidgets);
      expect(find.text('الخدمات'), findsWidgets);
      expect(find.text('حجوزاتي'), findsWidgets);
      expect(find.text('المفضلة'), findsWidgets);
      expect(find.text('الإشعارات'), findsWidgets);
    });

    testWidgets('HomeServicesHomeView renders search bar and quick action categories', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          HomeServicesHomeView(onExploreServicesTap: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ابحث عن خدمة، صيانة، فني متخصص...'), findsOneWidget);
      expect(find.text('الأقسام والخدمات'), findsOneWidget);
      expect(find.text('الخدمات الأكثر طلباً'), findsOneWidget);
      expect(find.text('أفضل الشركات ومزودي الخدمة'), findsOneWidget);
    });

    testWidgets('HomeServicesCatalogView renders filter chips and category selector', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          const HomeServicesCatalogView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('دليل الخدمات المنزلية'), findsOneWidget);
      expect(find.text('جميع الخدمات'), findsWidgets);
      expect(find.text('تكييف وتبريد'), findsWidgets);
      expect(find.text('سعر ثابت'), findsWidgets);
    });

    testWidgets('HomeServicesBookingsView renders filter tabs for bookings', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          HomeServicesBookingsView(
            onExploreServicesTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إدارة ومتابعة الحجوزات'), findsOneWidget);
      expect(find.text('الكل'), findsWidgets);
      expect(find.text('القادمة'), findsWidgets);
      expect(find.text('قيد التنفيذ'), findsWidgets);
      expect(find.text('المكتملة'), findsWidgets);
    });

    testWidgets('HomeServicesFavoritesView renders services and providers segments', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          HomeServicesFavoritesView(
            onExploreServicesTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الخدمات المحفوظة'), findsOneWidget);
      expect(find.text('مزودو الخدمة'), findsOneWidget);
    });
  });
}
