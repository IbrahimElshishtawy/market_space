import 'package:flutter/foundation.dart';

import '../../data/models/building_material_cart_model.dart';
import '../../data/models/material_product_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/models/unit_of_measurement.dart';
import '../../data/repositories/building_materials_cart_repository.dart';

class BuildingMaterialsCartController
    extends ValueNotifier<BuildingMaterialCartModel> {
  final BuildingMaterialsCartRepository repository;
  bool isLoading = false;
  String? errorMessage;

  BuildingMaterialsCartController({BuildingMaterialsCartRepository? repository})
    : repository = repository ?? BuildingMaterialsCartRepositoryImpl(),
      super(
        const BuildingMaterialCartModel(
          id: 'bm-cart-initial',
          userId: 'user-demo-1',
        ),
      );

  BuildingMaterialCartModel get cart => value;
  int get itemCount => value.totalItemCount;

  Future<void> loadCart() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      value = await repository.getCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required MaterialProductModel product,
    required double quantity,
    required MaterialUnit unit,
    SupplierModel? supplier,
  }) async {
    // التحقق من الحد الأدنى للطلب
    if (!product.isValidOrderQuantity(quantity, unit)) {
      errorMessage =
          'الكمية المحددة أقل من الحد الأدنى للطلب (${product.formattedMinOrder}) أو تتجاوز المخزون المتاح.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      value = await repository.addToCart(
        product: product,
        quantity: quantity,
        unit: unit,
        supplier: supplier,
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity({
    required String itemId,
    required double newQuantity,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      value = await repository.updateQuantity(
        itemId: itemId,
        newQuantity: newQuantity,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String itemId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      value = await repository.removeFromCart(itemId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) => removeFromCart(itemId);

  Future<void> clearCart() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      value = await repository.clearCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setGovernorate(String governorate) async {
    try {
      value = await repository.updateTargetLocation(governorate: governorate);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> applyCoupon(String code) async {
    isLoading = true;
    notifyListeners();
    try {
      value = await repository.applyCoupon(code);
      return value.discountAmount > 0;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
