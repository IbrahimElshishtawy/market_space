enum ApplianceOrderStatus {
  confirmed('تم التأكيد', 'confirmed'),
  processing('جاري التحضير', 'processing'),
  shipped('تم الشحن', 'shipped'),
  outForDelivery('جاري التوصيل', 'out_for_delivery'),
  delivered('تم التسليم', 'delivered'),
  cancelled('ملغي', 'cancelled');

  final String label;
  final String code;

  const ApplianceOrderStatus(this.label, this.code);
}

class ApplianceOrderItemModel {
  final String id;
  final String title;
  final String brandName;
  final String imageUrl;
  final int quantity;
  final double unitPrice;

  const ApplianceOrderItemModel({
    required this.id,
    required this.title,
    required this.brandName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;
}

class ApplianceOrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final List<ApplianceOrderItemModel> items;
  final ApplianceOrderStatus status;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double grandTotal;
  final String paymentMethod;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryDate;

  const ApplianceOrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.grandTotal,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDeliveryDate,
  });

  ApplianceOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<ApplianceOrderItemModel>? items,
    ApplianceOrderStatus? status,
    double? subtotal,
    double? shippingFee,
    double? discountAmount,
    double? grandTotal,
    String? paymentMethod,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? estimatedDeliveryDate,
  }) {
    return ApplianceOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discountAmount: discountAmount ?? this.discountAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
    );
  }
}
