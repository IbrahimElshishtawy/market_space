import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/explore/data/models/explore_search_models.dart';
import 'package:market_space/features/explore/data/repositories/explore_repository.dart';
import 'package:market_space/features/explore/presentation/controllers/explore_controller.dart';
import 'package:market_space/features/explore/presentation/pages/explore_page.dart';

void main() {
  group('Explore Controller & Page Tests', () {
    test('ExploreController initial state loads categories and discovery sections', () async {
      final repo = ExploreRepositoryImpl();
      final controller = ExploreController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.value.categories.length, equals(4));
      expect(controller.value.mostRequested.isNotEmpty, isTrue);
      expect(controller.value.currentOffers.isNotEmpty, isTrue);
      expect(controller.value.latestAdditions.isNotEmpty, isTrue);
      expect(controller.value.searchResults.isNotEmpty, isTrue);
    });

    test('ExploreController searches across sectors and filters results', () async {
      final repo = ExploreRepositoryImpl();
      final controller = ExploreController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      // Search for تكييف
      await controller.onSearchQueryChanged('تكييف');
      expect(controller.value.isSearching, isTrue);
      expect(controller.value.searchResults.length, greaterThanOrEqualTo(2));

      // Filter by appliances sector only
      await controller.setSectorFilter(SectorType.homeAppliances);
      expect(
        controller.value.searchResults.every((e) => e.sectorId == 'home_appliances'),
        isTrue,
      );

      // Clear search
      await controller.clearSearch();
      expect(controller.value.searchQuery, isEmpty);
    });

    testWidgets('ExplorePage renders search bar, sector filter chips, and categories', (tester) async {
      final repo = ExploreRepositoryImpl();
      final controller = ExploreController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: ExplorePage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('استكشف المنصة'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('العقارات'), findsWidgets);
      expect(find.text('مواد البناء'), findsWidgets);
      expect(find.text('الخدمات المنزلية'), findsWidgets);
      expect(find.text('الأجهزة المنزلية'), findsWidgets);
    });
  });
}
