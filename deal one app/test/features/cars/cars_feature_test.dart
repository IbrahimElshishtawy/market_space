import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/cars/data/mock/mock_cars_data.dart';
import 'package:market_space/features/cars/data/models/car_filter_model.dart';
import 'package:market_space/features/cars/data/models/car_listing_model.dart';
import 'package:market_space/features/cars/data/repositories/cars_repository.dart';
import 'package:market_space/features/cars/navigation/cars_navigation_config.dart';
import 'package:market_space/features/cars/presentation/controllers/cars_controller.dart';
import 'package:market_space/features/cars/presentation/pages/cars_page.dart';
import 'package:market_space/features/cars/presentation/widgets/car_listing_card.dart';

void main() {
  group('Cars Feature Tests', () {
    test('MockCarsData satisfies minimum requirement of 35+ cars and 15 brands', () {
      expect(MockCarsData.listings.length, greaterThanOrEqualTo(35));
      expect(MockCarsData.brands.length, greaterThanOrEqualTo(15));
    });

    test('CarsNavigationConfig matches section bottom nav pattern', () {
      expect(CarsNavigationConfig.sectionId, equals('cars'));
      expect(CarsNavigationConfig.config.items.length, equals(5));
      expect(CarsNavigationConfig.config.sectionName, equals('السيارات'));
    });

    test('CarsController loads initial data, searches, filters, and toggles favorite', () async {
      final repo = MockCarsRepository();
      final controller = CarsController(repository: repo);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.value.cars.isNotEmpty, isTrue);
      expect(controller.value.brands.length, equals(15));

      // Filter by condition
      await controller.setCondition(CarCondition.newCar);
      expect(controller.value.filter.condition, equals(CarCondition.newCar));
      expect(controller.value.cars.every((c) => c.condition == CarCondition.newCar), isTrue);

      // Reset filter
      await controller.applyFilter(const CarFilterModel());
      expect(controller.value.filter.condition, isNull);

      // Filter by brand
      await controller.setBrand('Toyota');
      expect(controller.value.filter.brand, equals('Toyota'));
      expect(controller.value.cars.every((c) => c.brand == 'Toyota'), isTrue);

      // Search query
      await controller.setSearchQuery('كورولا');
      expect(controller.value.filter.searchQuery, equals('كورولا'));

      // Toggle favorite
      final firstCar = controller.value.cars.first;
      final initialFav = firstCar.isFavorite;
      await controller.toggleFavorite(firstCar.id);
      final updatedCar = controller.value.cars.firstWhere((c) => c.id == firstCar.id);
      expect(updatedCar.isFavorite, equals(!initialFav));
    });

    testWidgets('CarsPage renders search bar, brand chips, and listing cards', (
      WidgetTester tester,
    ) async {
      final repo = MockCarsRepository();
      final controller = CarsController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: CarsPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سوق السيارات'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('فلترة'), findsOneWidget);
      expect(find.byType(CarListingCard), findsWidgets);
    });
  });
}
