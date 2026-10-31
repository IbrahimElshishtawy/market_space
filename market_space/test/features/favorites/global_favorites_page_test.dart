import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/favorites/data/models/unified_favorite_item_model.dart';
import 'package:market_space/features/favorites/data/repositories/unified_favorites_repository.dart';
import 'package:market_space/features/favorites/presentation/controllers/unified_favorites_controller.dart';
import 'package:market_space/features/favorites/presentation/pages/global_favorites_page.dart';

void main() {
  group('Global Favorites Controller & Page Tests', () {
    test('UnifiedFavoritesController loads favorites across sectors', () async {
      final repo = UnifiedFavoritesRepositoryImpl();
      final controller = UnifiedFavoritesController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.value.favorites.isNotEmpty, isTrue);

      final sectors = controller.value.favorites.map((i) => i.sectorId).toSet();
      expect(sectors.contains('real_estate'), isTrue);
      expect(sectors.contains('building_materials'), isTrue);
      expect(sectors.contains('home_appliances'), isTrue);
    });

    test('UnifiedFavoritesController filters by sector', () async {
      final repo = UnifiedFavoritesRepositoryImpl();
      final controller = UnifiedFavoritesController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      await controller.setSectorFilter(FavoriteSectorFilter.realEstate);
      expect(controller.value.selectedSector, FavoriteSectorFilter.realEstate);
      expect(controller.value.favorites.every((i) => i.sectorId == 'real_estate'), isTrue);

      await controller.setSectorFilter(FavoriteSectorFilter.all);
      expect(controller.value.selectedSector, FavoriteSectorFilter.all);
      expect(controller.value.favorites.length, greaterThan(1));
    });

    test('UnifiedFavoritesController optimistic toggle removes item', () async {
      final repo = UnifiedFavoritesRepositoryImpl();
      final controller = UnifiedFavoritesController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      final firstItem = controller.value.favorites.first;
      await controller.toggleFavorite(firstItem);

      expect(controller.isFavorite(firstItem.itemId), isFalse);
    });

    testWidgets('GlobalFavoritesPage renders header, filters and favorite items', (tester) async {
      final repo = UnifiedFavoritesRepositoryImpl();
      final controller = UnifiedFavoritesController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: GlobalFavoritesPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('المفضلة الموحدة'), findsOneWidget);
      expect(find.text('الكل'), findsWidgets);
      expect(find.text('عقارات'), findsWidgets);
      expect(find.text('مواد بناء'), findsWidgets);
    });
  });
}
