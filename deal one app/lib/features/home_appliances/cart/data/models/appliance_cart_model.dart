import '../../../data/models/appliance_product_model.dart';

class ApplianceCartItemModel {
  final String id;
  final ApplianceProductModel product;
  final int quantity;

  const ApplianceCartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  ApplianceCartItemModel copyWith({
    String? id,
    ApplianceProductModel? product,
    int? quantity,
  }) {
    return ApplianceCartItemModel(
      id: id ?? this.id,
      product: propertyProduct(product),
      quantity: quantity ?? this.quantity,
    );
  }

  ApplianceProductModel propertyProduct(ApplianceProductModel? p) =>
      p ?? product;

  double get unitPrice {
    final cleaned = product.priceFormatted
        .replaceAll('ج.م', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get totalPrice => unitPrice * quantity;
}

class ApplianceCartModel {
  final String id;
  final String userId;
  final List<ApplianceCartItemModel> items;
  final double shippingFee;
  final String? appliedCouponCode;
  final double discountAmount;

  const ApplianceCartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    this.shippingFee = 150.0,
    this.appliedCouponCode,
    this.discountAmount = 0.0,
  });

  ApplianceCartModel copyWith({
    String? id,
    String? userId,
    List<ApplianceCartItemModel>? items,
    double? shippingFee,
    String? appliedCouponCode,
    double? discountAmount,
  }) {
    return ApplianceCartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      shippingFee: shippingFee ?? this.shippingFee,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get grandTotal {
    final total =
        subtotal + (items.isEmpty ? 0.0 : shippingFee) - discountAmount;
    return total < 0 ? 0.0 : total;
  }

  int get totalItemCount =>
      items.fold(0, (count, item) => count + item.quantity);
}
