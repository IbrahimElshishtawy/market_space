import '../../../data/mock/mock_home_appliances_data.dart';
import '../../../data/models/appliance_product_model.dart';
import '../models/appliance_cart_model.dart';

abstract class HomeAppliancesCartRepository {
  Future<ApplianceCartModel> getCart({String? userId});
  Future<ApplianceCartModel> addToCart(
    ApplianceProductModel product, {
    int quantity = 1,
    String? userId,
  });
  Future<ApplianceCartModel> updateQuantity(
    String cartItemId,
    int quantity, {
    String? userId,
  });
  Future<ApplianceCartModel> removeFromCart(
    String cartItemId, {
    String? userId,
  });
  Future<ApplianceCartModel> applyCoupon(String code, {String? userId});
  Future<ApplianceCartModel> clearCart({String? userId});
}

class MockHomeAppliancesCartRepository implements HomeAppliancesCartRepository {
  ApplianceCartModel _cartStore = ApplianceCartModel(
    id: 'cart-1',
    userId: 'user-1',
    items: [
      ApplianceCartItemModel(
        id: 'cart-item-1',
        product: MockHomeAppliancesData.products.firstWhere(
          (p) => p.id == 'prod-1',
        ),
        quantity: 1,
      ),
    ],
    shippingFee: 150.0,
  );

  @override
  Future<ApplianceCartModel> getCart({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _cartStore;
  }

  @override
  Future<ApplianceCartModel> addToCart(
    ApplianceProductModel product, {
    int quantity = 1,
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final items = List<ApplianceCartItemModel>.from(_cartStore.items);
    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final current = items[existingIndex];
      items[existingIndex] = current.copyWith(
        quantity: current.quantity + quantity,
      );
    } else {
      items.add(
        ApplianceCartItemModel(
          id: 'cart-item-${DateTime.now().millisecondsSinceEpoch}',
          product: product.copyWith(inCart: true),
          quantity: quantity,
        ),
      );
    }

    _cartStore = _cartStore.copyWith(items: items);
    return _cartStore;
  }

  @override
  Future<ApplianceCartModel> updateQuantity(
    String cartItemId,
    int quantity, {
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final items = List<ApplianceCartItemModel>.from(_cartStore.items);
    final index = items.indexWhere((i) => i.id == cartItemId);

    if (index != -1) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
    }

    _cartStore = _cartStore.copyWith(items: items);
    return _cartStore;
  }

  @override
  Future<ApplianceCartModel> removeFromCart(
    String cartItemId, {
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final items = List<ApplianceCartItemModel>.from(_cartStore.items);
    items.removeWhere((i) => i.id == cartItemId);

    _cartStore = _cartStore.copyWith(items: items);
    return _cartStore;
  }

  @override
  Future<ApplianceCartModel> applyCoupon(String code, {String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (code.trim().toUpperCase() == 'MARKET500') {
      _cartStore = _cartStore.copyWith(
        appliedCouponCode: 'MARKET500',
        discountAmount: 500.0,
      );
    } else {
      throw Exception('رمز الكوبون غير صالح أو منتهي الصلاحية');
    }
    return _cartStore;
  }

  @override
  Future<ApplianceCartModel> clearCart({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _cartStore = _cartStore.copyWith(
      items: [],
      appliedCouponCode: null,
      discountAmount: 0.0,
    );
    return _cartStore;
  }
}
