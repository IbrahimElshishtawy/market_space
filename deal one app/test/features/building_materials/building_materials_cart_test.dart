import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/mock/mock_building_materials_comprehensive_data.dart';
import 'package:market_space/features/building_materials/data/models/unit_of_measurement.dart';
import 'package:market_space/features/building_materials/data/repositories/building_materials_cart_repository.dart';
import 'package:market_space/features/building_materials/presentation/controllers/building_materials_cart_controller.dart';

void main() {
  group('BuildingMaterials Cart Repository & Controller Tests', () {
    late BuildingMaterialsCartRepository repository;
    late BuildingMaterialsCartController controller;

    setUp(() {
      repository = BuildingMaterialsCartRepositoryImpl();
      controller = BuildingMaterialsCartController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial cart state is empty', () {
      expect(controller.cart.items, isEmpty);
      expect(controller.cart.totalPrice, 0.0);
      expect(controller.itemCount, 0);
    });

    test('addToCart adds item and enforces MOQ validation', () async {
      final steelProduct = MockBuildingMaterialsComprehensiveData.products.first;
      // Steel MOQ is 2.0 tons
      expect(steelProduct.minOrderQuantity, 2.0);

      // Attempting to add less than MOQ (e.g. 1.0 ton) must fail
      final failResult = await controller.addToCart(
        product: steelProduct,
        quantity: 1.0,
        unit: MaterialUnit.ton,
      );
      expect(failResult, isFalse);
      expect(controller.errorMessage, contains('الحد الأدنى للطلب'));
      expect(controller.cart.items, isEmpty);

      // Adding valid MOQ quantity (e.g. 2.0 tons) succeeds
      final successResult = await controller.addToCart(
        product: steelProduct,
        quantity: 2.0,
        unit: MaterialUnit.ton,
      );
      expect(successResult, isTrue);
      expect(controller.cart.items.length, 1);
      expect(controller.cart.items.first.quantity, 2.0);
      expect(controller.cart.items.first.totalPrice, 2.0 * steelProduct.unitPrice);
    });

    test('Multi-supplier grouping categorizes items by their supplier', () async {
      final steelProduct = MockBuildingMaterialsComprehensiveData.products
          .firstWhere((p) => p.supplier.id == 'supp-ezz');
      final cementProduct = MockBuildingMaterialsComprehensiveData.products
          .firstWhere((p) => p.supplier.id == 'supp-suez-cement');

      await controller.addToCart(
        product: steelProduct,
        quantity: 2.0,
        unit: MaterialUnit.ton,
      );
      await controller.addToCart(
        product: cementProduct,
        quantity: 5.0,
        unit: MaterialUnit.ton,
      );

      expect(controller.cart.items.length, 2);
      final supplierGroups = controller.cart.itemsBySupplier;
      expect(supplierGroups.keys.length, 2);
      expect(supplierGroups.containsKey('supp-ezz'), isTrue);
      expect(supplierGroups.containsKey('supp-suez-cement'), isTrue);
    });

    test('updateQuantity adjusts requested quantity and updates subtotal', () async {
      final cementProduct = MockBuildingMaterialsComprehensiveData.products
          .firstWhere((p) => p.supplier.id == 'supp-suez-cement');

      await controller.addToCart(
        product: cementProduct,
        quantity: 5.0,
        unit: MaterialUnit.ton,
      );

      await controller.updateQuantity(
        itemId: cementProduct.id,
        newQuantity: 10.0,
      );
      expect(controller.cart.items.first.quantity, 10.0);
      expect(controller.cart.subtotal, 10.0 * controller.cart.items.first.unitPrice);
    });

    test('removeItem removes product from cart', () async {
      final cementProduct = MockBuildingMaterialsComprehensiveData.products
          .firstWhere((p) => p.supplier.id == 'supp-suez-cement');

      await controller.addToCart(
        product: cementProduct,
        quantity: 5.0,
        unit: MaterialUnit.ton,
      );
      expect(controller.cart.items.length, 1);

      await controller.removeItem(cementProduct.id);
      expect(controller.cart.items, isEmpty);
      expect(controller.cart.totalPrice, 0.0);
    });

    test('Applying coupon applies correct percentage discount', () async {
      final steelProduct = MockBuildingMaterialsComprehensiveData.products.first;
      await controller.addToCart(
        product: steelProduct,
        quantity: 2.0,
        unit: MaterialUnit.ton,
      );

      final initialSubtotal = controller.cart.subtotal;
      // BINA10 gives 10% discount
      final applied = await controller.applyCoupon('BINA10');
      expect(applied, isTrue);
      expect(controller.cart.couponCode, 'BINA10');
      expect(controller.cart.discountAmount, closeTo(initialSubtotal * 0.10, 0.01));
    });

    test('clearCart empties cart and resets state', () async {
      final steelProduct = MockBuildingMaterialsComprehensiveData.products.first;
      await controller.addToCart(
        product: steelProduct,
        quantity: 2.0,
        unit: MaterialUnit.ton,
      );
      expect(controller.cart.items.length, 1);

      await controller.clearCart();
      expect(controller.cart.items, isEmpty);
      expect(controller.cart.couponCode, isNull);
    });
  });
}
