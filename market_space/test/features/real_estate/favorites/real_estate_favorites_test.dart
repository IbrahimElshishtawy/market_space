import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/data/mock/mock_real_estate_data.dart';
import 'package:market_space/features/real_estate/favorites/presentation/controllers/real_estate_favorites_controller.dart';
import 'package:market_space/features/real_estate/favorites/presentation/pages/real_estate_favorites_page.dart';
import 'package:market_space/features/real_estate/favorites/presentation/widgets/favorite_property_card.dart';

void main() {
  group('Real Estate Favorites Controller Tests', () {
    late RealEstateFavoritesController controller;

    setUp(() {
      controller = RealEstateFavoritesController();
    });

    tearDown(() {
      controller.dispose();
    });

    test(
      'loadFavorites fetches user favorites and populates favoriteIds',
      () async {
        await controller.loadFavorites();

        expect(controller.value.isLoading, isFalse);
        expect(controller.value.favorites.length, equals(1));
        expect(controller.isFavorite('aqar-3'), isTrue);
      },
    );

    test('toggleFavorite toggles status and updates state', () async {
      await controller.loadFavorites();

      final firstListing = MockRealEstateData.listings.first; // aqar-1
      expect(controller.isFavorite(firstListing.id), isFalse);

      final added = await controller.toggleFavorite(firstListing);
      expect(added, isTrue);
      expect(controller.isFavorite(firstListing.id), isTrue);

      final removed = await controller.toggleFavorite(firstListing);
      expect(removed, isFalse);
      expect(controller.isFavorite(firstListing.id), isFalse);
    });

    test('search query filters favorite items', () async {
      await controller.loadFavorites();

      controller.setSearchQuery('دوبلكس');
      expect(controller.value.filteredFavorites.length, equals(1));

      controller.setSearchQuery('غير موجود');
      expect(controller.value.filteredFavorites.length, equals(0));
    });
  });

  group('Real Estate Favorites Page Widget Tests', () {
    testWidgets('renders RealEstateFavoritesPage, cards, and bottom navbar', (
      WidgetTester tester,
    ) async {
      final controller = RealEstateFavoritesController();

      await tester.pumpWidget(
        MaterialApp(home: RealEstateFavoritesPage(controller: controller)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RealEstateFavoritesPage), findsOneWidget);
      expect(find.text('العقارات المفضلة'), findsOneWidget);
      expect(find.byType(FavoritePropertyCard), findsOneWidget);
    });
  });
}
