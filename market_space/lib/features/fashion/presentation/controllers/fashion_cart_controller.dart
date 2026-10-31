import 'package:flutter/foundation.dart';

import '../../data/mock/mock_fashion_data.dart';
import '../../data/models/fashion_category_model.dart';
import '../../data/models/fashion_product_model.dart';

class FashionCartState {
  final List<FashionCartItemModel> items;

  const FashionCartState({
    this.items = const [],
  });

  int get totalItems => items.fold(0, (acc, item) => acc + item.quantity);

  double get subtotal => items.fold(0.0, (acc, item) => acc + item.totalPrice);

  double get shippingFee => subtotal > 1000 || items.isEmpty ? 0.0 : 50.0;

  double get grandTotal => subtotal + shippingFee;

  FashionCartState copyWith({
    List<FashionCartItemModel>? items,
  }) {
    return FashionCartState(
      items: items ?? this.items,
    );
  }
}

class FashionCartController extends ValueNotifier<FashionCartState> {
  FashionCartController() : super(_initialState());

  static FashionCartState _initialState() {
    // Populate with 2 initial mock items for realistic UI demonstration
    final p1 = MockFashionData.products.first;
    final p2 = MockFashionData.products[2];

    return FashionCartState(
      items: [
        FashionCartItemModel(
          id: 'cart-1',
          product: p1,
          selectedSize: p1.availableSizes.first,
          selectedColor: p1.availableColors.first,
          quantity: 1,
          unitPrice: p1.price,
        ),
        FashionCartItemModel(
          id: 'cart-2',
          product: p2,
          selectedSize: p2.availableSizes.first,
          selectedColor: p2.availableColors.first,
          quantity: 2,
          unitPrice: p2.price,
        ),
      ],
    );
  }

  void addItem(FashionProductModel product, String size, String color, {int quantity = 1}) {
    final existingIndex = value.items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size && item.selectedColor == color,
    );

    if (existingIndex != -1) {
      final existing = value.items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      final newItems = List<FashionCartItemModel>.from(value.items);
      newItems[existingIndex] = updated;
      value = value.copyWith(items: newItems);
    } else {
      final newItem = FashionCartItemModel(
        id: 'cart-${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        selectedSize: size,
        selectedColor: color,
        quantity: quantity,
        unitPrice: product.price,
      );
      value = value.copyWith(items: [...value.items, newItem]);
    }
  }

  void removeItem(String itemId) {
    value = value.copyWith(
      items: value.items.where((i) => i.id != itemId).toList(),
    );
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final newItems = value.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    value = value.copyWith(items: newItems);
  }

  void clearCart() {
    value = const FashionCartState(items: []);
  }
}
