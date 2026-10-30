import '../models/building_material_cart_model.dart';
import '../models/material_product_model.dart';
import '../models/supplier_model.dart';
import '../models/unit_of_measurement.dart';
import '../services/shipping_calculator.dart';

abstract class BuildingMaterialsCartRepository {
  Future<BuildingMaterialCartModel> getCart();
  Future<BuildingMaterialCartModel> addToCart({
    required MaterialProductModel product,
    required double quantity,
    required MaterialUnit unit,
    SupplierModel? supplier,
  });
  Future<BuildingMaterialCartModel> updateQuantity({
    required String itemId,
    required double newQuantity,
  });
  Future<BuildingMaterialCartModel> removeFromCart(String itemId);
  Future<BuildingMaterialCartModel> clearCart();
  Future<BuildingMaterialCartModel> updateTargetLocation({
    required String governorate,
    double? latitude,
    double? longitude,
  });
  Future<BuildingMaterialCartModel> applyCoupon(String couponCode);
}

class BuildingMaterialsCartRepositoryImpl
    implements BuildingMaterialsCartRepository {
  BuildingMaterialCartModel _cart = const BuildingMaterialCartModel(
    id: 'cart-bm-default',
    userId: 'user-demo-1',
    targetGovernorate: 'القاهرة',
  );

  final Duration delay;

  BuildingMaterialsCartRepositoryImpl({
    this.delay = const Duration(milliseconds: 150),
  });

  @override
  Future<BuildingMaterialCartModel> getCart() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return _cart;
  }

  @override
  Future<BuildingMaterialCartModel> addToCart({
    required MaterialProductModel product,
    required double quantity,
    required MaterialUnit unit,
    SupplierModel? supplier,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    final resolvedSupplier = supplier ?? product.supplier;
    final unitPrice = UnitConverter.convertUnitPrice(
      priceInFromUnit: product.unitPrice,
      from: product.baseUnit,
      to: unit,
    );

    final existingIndex = _cart.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedUnit == unit,
    );

    final List<BuildingMaterialCartItemModel> updatedItems = List.from(
      _cart.items,
    );

    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      final newQty = existing.quantity + quantity;
      updatedItems[existingIndex] = existing.copyWith(
        quantity: newQty,
        unitPrice: unitPrice,
      );
    } else {
      updatedItems.add(
        BuildingMaterialCartItemModel(
          id: 'item-${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          supplier: resolvedSupplier,
          selectedUnit: unit,
          quantity: quantity,
          unitPrice: unitPrice,
          isAvailable: product.isAvailable,
        ),
      );
    }

    _cart = _cart.copyWith(items: updatedItems);
    _recalculateFreight();
    return _cart;
  }

  @override
  Future<BuildingMaterialCartModel> updateQuantity({
    required String itemId,
    required double newQuantity,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    if (newQuantity <= 0) {
      return removeFromCart(itemId);
    }

    final updatedItems = _cart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    _cart = _cart.copyWith(items: updatedItems);
    _recalculateFreight();
    return _cart;
  }

  @override
  Future<BuildingMaterialCartModel> removeFromCart(String itemId) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    final updatedItems =
        _cart.items.where((item) => item.id != itemId).toList();
    _cart = _cart.copyWith(items: updatedItems);
    _recalculateFreight();
    return _cart;
  }

  @override
  Future<BuildingMaterialCartModel> clearCart() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _cart = _cart.copyWith(
      items: const [],
      calculatedFreight: 0.0,
      discountAmount: 0.0,
      couponCode: null,
    );
    return _cart;
  }

  @override
  Future<BuildingMaterialCartModel> updateTargetLocation({
    required String governorate,
    double? latitude,
    double? longitude,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _cart = _cart.copyWith(targetGovernorate: governorate);
    _recalculateFreight(lat: latitude, lng: longitude);
    return _cart;
  }

  @override
  Future<BuildingMaterialCartModel> applyCoupon(String couponCode) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (couponCode.trim().toUpperCase() == 'BUILD10') {
      final discount = UnitConverter.roundCurrency(_cart.subtotal * 0.10);
      _cart = _cart.copyWith(
        couponCode: couponCode,
        discountAmount: discount,
      );
    } else {
      _cart = _cart.copyWith(couponCode: null, discountAmount: 0.0);
    }
    return _cart;
  }

  void _recalculateFreight({double? lat, double? lng}) {
    if (_cart.items.isEmpty) {
      _cart = _cart.copyWith(calculatedFreight: 0.0, isFreightConfirmed: true);
      return;
    }

    // حساب الشحن لكل مورد وتجميع الإجمالي
    double totalFreight = 0.0;
    bool allConfirmed = true;

    final itemsBySupplier = _cart.itemsBySupplier;
    for (final entry in itemsBySupplier.entries) {
      final supplier = entry.value.first.supplier;
      final result = ShippingCalculator.calculateFreight(
        supplier: supplier,
        items: entry.value,
        targetGovernorate: _cart.targetGovernorate,
        projectLat: lat,
        projectLng: lng,
      );

      if (result.isDeliverable) {
        totalFreight += result.totalFreightCost;
        if (result.requiresConfirmation) {
          allConfirmed = false;
        }
      } else {
        allConfirmed = false;
      }
    }

    _cart = _cart.copyWith(
      calculatedFreight: totalFreight,
      isFreightConfirmed: allConfirmed,
    );
  }
}
