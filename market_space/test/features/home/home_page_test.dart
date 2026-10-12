import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/home/data/mock/mock_home_data.dart';
import 'package:market_space/features/home/presentation/pages/home_page.dart';
import 'package:market_space/features/home/widgets/hero_carousel/hero_carousel.dart';
import 'package:market_space/features/home/widgets/home_header/home_header.dart';
import 'package:market_space/features/home/widgets/home_search_bar/home_search_bar.dart';
import 'package:market_space/features/home/widgets/main_categories/main_categories_section.dart';
import 'package:market_space/features/home/widgets/most_requested_services/most_requested_services_section.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('renders all main sections of home page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(find.text('مصطفي هيكل'), findsOneWidget);
      expect(find.text('الغربية - طنطا'), findsOneWidget);

      // Verify Search Bar
      expect(find.byType(HomeSearchBar), findsOneWidget);
      expect(find.text('أبحث عن عقار، خدمة صيانة...'), findsOneWidget);

      // Verify Hero Carousel
      expect(find.byType(HeroCarousel), findsOneWidget);
      expect(find.text('احجز بيت أحلامك'), findsOneWidget);

      // Verify Main Categories
      expect(find.byType(MainCategoriesSection), findsOneWidget);
      expect(find.text('الأقسام الرئيسية'), findsOneWidget);
      expect(find.text('عقارات'), findsOneWidget);
      expect(find.text('أجهزة منزلية'), findsOneWidget);
      expect(find.text('خدمات منزلية'), findsOneWidget);
      expect(find.text('مواد بناء'), findsOneWidget);

      // Verify Most Requested Services
      expect(find.byType(MostRequestedServicesSection), findsOneWidget);
      expect(find.text('الخدمات الأكثر طلباً'), findsOneWidget);
      expect(find.text('صيانة وتنظيف تكييفات'), findsOneWidget);
      expect(find.text('توريد أسمنت وبلوك'), findsOneWidget);
    });

    testWidgets(
      'HomeHeader displays correct notification count and user info',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: HomeHeader(data: MockHomeData.headerData)),
          ),
        );

        expect(find.text('مصطفي هيكل'), findsOneWidget);
        expect(find.text('الغربية - طنطا'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_basket_outlined), findsOneWidget);
        expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
      },
    );
  });
}
