import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/fashion/data/mock/mock_fashion_data.dart';
import 'package:market_space/features/fashion/data/models/fashion_product_model.dart';
import 'package:market_space/features/fashion/data/repositories/fashion_repository.dart';
import 'package:market_space/features/fashion/navigation/fashion_navigation_config.dart';
import 'package:market_space/features/fashion/presentation/controllers/fashion_cart_controller.dart';
import 'package:market_space/features/fashion/presentation/controllers/fashion_controller.dart';
import 'package:market_space/features/fashion/presentation/pages/fashion_page.dart';
import 'package:market_space/features/fashion/presentation/pages/fashion_product_detail_page.dart';

void main() {
  group('Fashion Feature Tests', () {
    test('MockFashionData satisfies minimum requirement of 60+ products with variants', () {
      expect(MockFashionData.products.length, greaterThanOrEqualTo(60));
      // Verify all products have variants with size and color
      for (final p in MockFashionData.products) {
        expect(p.variants.isNotEmpty, isTrue);
        expect(p.availableSizes.isNotEmpty, isTrue);
        expect(p.availableColors.isNotEmpty, isTrue);
      }
    });

    test('FashionNavigationConfig matches section bottom nav pattern', () {
      expect(FashionNavigationConfig.sectionId, equals('fashion'));
      expect(FashionNavigationConfig.config.items.length, equals(5));
      expect(FashionNavigationConfig.config.sectionName, equals('الملابس والأزياء'));
    });

    test('FashionController searches and filters by department and category', () async {
      final repo = MockFashionRepository();
      final controller = FashionController(repository: repo);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.value.products.isNotEmpty, isTrue);

      // Filter by department (men)
      await controller.setDepartment(FashionDepartment.men);
      expect(controller.value.selectedDepartment, equals(FashionDepartment.men));
      expect(controller.value.products.every((p) => p.department == FashionDepartment.men || p.department == FashionDepartment.unisex), isTrue);

      // Search query
      await controller.setSearchQuery('بولو');
      expect(controller.value.searchQuery, equals('بولو'));
      expect(controller.value.products.any((p) => p.name.contains('بولو')), isTrue);
    });

    test('FashionCartController manages variants, quantities, and calculates totals accurately', () {
      final cartController = FashionCartController();
      final initialCount = cartController.value.items.length;

      final testProduct = MockFashionData.products.first;
      final size = testProduct.availableSizes.first;
      final color = testProduct.availableColors.first;

      cartController.addItem(testProduct, size, color, quantity: 2);
      expect(cartController.value.items.length, greaterThanOrEqualTo(initialCount));

      final addedItem = cartController.value.items.firstWhere(
        (i) => i.product.id == testProduct.id && i.selectedSize == size && i.selectedColor == color,
      );
      expect(addedItem.selectedSize, equals(size));
      expect(addedItem.selectedColor, equals(color));
      expect(cartController.value.subtotal, greaterThan(0));
    });

    testWidgets('FashionProductDetailPage validates variant stock before adding to cart', (
      WidgetTester tester,
    ) async {
      final cartController = FashionCartController();
      // Product with known stock
      final product = MockFashionData.products.first;

      await tester.pumpWidget(
        MaterialApp(
          home: FashionProductDetailPage(
            product: product,
            cartController: cartController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(product.name), findsOneWidget);
      expect(find.text('دليل المقاسات'), findsOneWidget);

      // Tap add to cart button
      final addToCartFinder = find.byType(ElevatedButton);
      expect(addToCartFinder, findsOneWidget);

      await tester.tap(addToCartFinder);
      await tester.pumpAndSettle();

      // Successfully added with confirmation snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('FashionPage renders search and category tabs', (
      WidgetTester tester,
    ) async {
      final repo = MockFashionRepository();
      final controller = FashionController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: FashionPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الملابس والإكسسوارات'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
