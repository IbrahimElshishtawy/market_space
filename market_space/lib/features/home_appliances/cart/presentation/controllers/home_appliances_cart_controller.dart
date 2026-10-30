import 'package:flutter/foundation.dart';

import '../../../data/models/appliance_product_model.dart';
import '../../data/models/appliance_cart_model.dart';
import '../../data/repositories/home_appliances_cart_repository.dart';

class HomeAppliancesCartState {
  final bool isLoading;
  final ApplianceCartModel cart;
  final String? couponErrorMessage;
  final String? errorMessage;

  const HomeAppliancesCartState({
    this.isLoading = false,
    this.cart = const ApplianceCartModel(id: '', userId: ''),
    this.couponErrorMessage,
    this.errorMessage,
  });

  HomeAppliancesCartState copyWith({
    bool? isLoading,
    ApplianceCartModel? cart,
    String? couponErrorMessage,
    bool clearCouponError = false,
    String? errorMessage,
  }) {
    return HomeAppliancesCartState(
      isLoading: isLoading ?? this.isLoading,
      cart: cart ?? this.cart,
      couponErrorMessage: clearCouponError
          ? null
          : (couponErrorMessage ?? this.couponErrorMessage),
      errorMessage: errorMessage,
    );
  }
}

class HomeAppliancesCartController
    extends ValueNotifier<HomeAppliancesCartState> {
  final HomeAppliancesCartRepository repository;
  bool _isDisposed = false;

  HomeAppliancesCartController({HomeAppliancesCartRepository? repository})
    : repository = repository ?? MockHomeAppliancesCartRepository(),
      super(const HomeAppliancesCartState(isLoading: true)) {
    loadCart();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadCart() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final cart = await repository.getCart();
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, cart: cart);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل سلة التسوق: $e',
      );
    }
  }

  Future<void> addToCart(
    ApplianceProductModel product, {
    int quantity = 1,
  }) async {
    if (_isDisposed) return;
    try {
      final updatedCart = await repository.addToCart(
        product,
        quantity: quantity,
      );
      if (_isDisposed) return;
      value = value.copyWith(cart: updatedCart);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'فشل إضافة المنتج إلى السلة: $e');
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_isDisposed) return;
    try {
      final updatedCart = await repository.updateQuantity(cartItemId, quantity);
      if (_isDisposed) return;
      value = value.copyWith(cart: updatedCart);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'فشل تحديث كمية المنتج: $e');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (_isDisposed) return;
    try {
      final updatedCart = await repository.removeFromCart(cartItemId);
      if (_isDisposed) return;
      value = value.copyWith(cart: updatedCart);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'فشل إزالة المنتج من السلة: $e');
    }
  }

  Future<bool> applyCoupon(String code) async {
    if (_isDisposed) return false;
    value = value.copyWith(clearCouponError: true);
    try {
      final updatedCart = await repository.applyCoupon(code);
      if (_isDisposed) return true;
      value = value.copyWith(cart: updatedCart);
      return true;
    } catch (e) {
      if (_isDisposed) return false;
      final msg = e.toString().replaceAll('Exception: ', '');
      value = value.copyWith(couponErrorMessage: msg);
      return false;
    }
  }

  Future<void> clearCart() async {
    if (_isDisposed) return;
    try {
      final updatedCart = await repository.clearCart();
      if (_isDisposed) return;
      value = value.copyWith(cart: updatedCart);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(errorMessage: 'فشل إفراغ السلة: $e');
    }
  }
}
