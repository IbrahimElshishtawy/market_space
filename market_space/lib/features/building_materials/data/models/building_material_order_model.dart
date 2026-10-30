import 'staged_shipment_model.dart';
import 'supplier_model.dart';
import 'unit_of_measurement.dart';

enum BuildingMaterialOrderStatus {
  pendingConfirmation('بانتظار التأكيد', 'pending_confirmation'),
  priceReview('جاري مراجعة السعر', 'price_review'),
  confirmed('تم تأكيد الطلب', 'confirmed'),
  processing('جاري التجهيز', 'processing'),
  readyForShipping('جاهز للشحن', 'ready_for_shipping'),
  shipped('تم الشحن', 'shipped'),
  inTransit('في الطريق للموقع', 'in_transit'),
  delivered('تم التسليم بالكامل', 'delivered'),
  partialDelivery('تسليم جزئي', 'partial_delivery'),
  cancelled('ملغي', 'cancelled'),
  returned('مرتجع', 'returned');

  final String label;
  final String code;

  const BuildingMaterialOrderStatus(this.label, this.code);
}

class BuildingMaterialOrderItemModel {
  final String id;
  final String productId;
  final String title;
  final String brand;
  final String imageUrl;
  final MaterialUnit unit;
  final double requestedQuantity;
  final double deliveredQuantity;
  final double unitPrice;
  final Map<String, String> technicalSpecs;

  const BuildingMaterialOrderItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.brand,
    required this.imageUrl,
    required this.unit,
    required this.requestedQuantity,
    this.deliveredQuantity = 0.0,
    required this.unitPrice,
    this.technicalSpecs = const {},
  });

  double get totalPrice =>
      UnitConverter.roundCurrency(requestedQuantity * unitPrice);

  double get remainingQuantity {
    final diff = requestedQuantity - deliveredQuantity;
    return diff > 0 ? diff : 0.0;
  }

  bool get isFullyDelivered => deliveredQuantity >= requestedQuantity;
}

class OrderTimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const OrderTimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = true,
  });
}

class BuildingMaterialOrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final SupplierModel supplier;
  final List<BuildingMaterialOrderItemModel> items;
  final BuildingMaterialOrderStatus status;
  final double subtotal;
  final double freightCost;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;
  final String paymentMethod;
  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final String city;
  final String governorate;
  final double? projectLatitude;
  final double? projectLongitude;
  final String? deliveryNotes;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryDate;
  final List<StagedShipmentModel> shipments;
  final List<OrderTimelineEvent> timeline;

  const BuildingMaterialOrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.supplier,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.freightCost,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.grandTotal,
    required this.paymentMethod,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    required this.city,
    required this.governorate,
    this.projectLatitude,
    this.projectLongitude,
    this.deliveryNotes,
    required this.createdAt,
    this.estimatedDeliveryDate,
    this.shipments = const [],
    this.timeline = const [],
  });

  double get totalRequestedQuantity =>
      items.fold(0.0, (sum, item) => sum + item.requestedQuantity);

  double get totalDeliveredQuantity =>
      items.fold(0.0, (sum, item) => sum + item.deliveredQuantity);

  double get deliveryCompletionRatio {
    if (totalRequestedQuantity <= 0) return 0.0;
    final ratio = totalDeliveredQuantity / totalRequestedQuantity;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  int get deliveryCompletionPercentage =>
      (deliveryCompletionRatio * 100).round();

  BuildingMaterialOrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    SupplierModel? supplier,
    List<BuildingMaterialOrderItemModel>? items,
    BuildingMaterialOrderStatus? status,
    double? subtotal,
    double? freightCost,
    double? discountAmount,
    double? taxAmount,
    double? grandTotal,
    String? paymentMethod,
    String? recipientName,
    String? recipientPhone,
    String? deliveryAddress,
    String? city,
    String? governorate,
    double? projectLatitude,
    double? projectLongitude,
    String? deliveryNotes,
    DateTime? createdAt,
    DateTime? estimatedDeliveryDate,
    List<StagedShipmentModel>? shipments,
    List<OrderTimelineEvent>? timeline,
  }) {
    return BuildingMaterialOrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      supplier: supplier ?? this.supplier,
      items: items ?? this.items,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      freightCost: freightCost ?? this.freightCost,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      projectLatitude: projectLatitude ?? this.projectLatitude,
      projectLongitude: projectLongitude ?? this.projectLongitude,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      shipments: shipments ?? this.shipments,
      timeline: timeline ?? this.timeline,
    );
  }
}
