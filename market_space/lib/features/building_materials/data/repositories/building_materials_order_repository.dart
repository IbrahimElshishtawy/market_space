import '../mock/mock_building_materials_comprehensive_data.dart';
import '../models/building_material_cart_model.dart';
import '../models/building_material_order_model.dart';
import '../models/rfq_model.dart';
import '../models/staged_shipment_model.dart';
import '../models/supplier_model.dart';
import '../models/unit_of_measurement.dart';

abstract class BuildingMaterialsOrderRepository {
  Future<List<BuildingMaterialOrderModel>> getOrders({
    BuildingMaterialOrderStatus? filterStatus,
  });
  Future<BuildingMaterialOrderModel> getOrderById(String orderId);
  Future<BuildingMaterialOrderModel> createOrderFromCart({
    required BuildingMaterialCartModel cart,
    required SupplierModel supplier,
    required String recipientName,
    required String recipientPhone,
    required String deliveryAddress,
    required String city,
    required String governorate,
    double? projectLat,
    double? projectLng,
    String? deliveryNotes,
    required String paymentMethod,
    required DateTime requestedDeliveryDate,
    int numberOfStagedShipments = 1,
  });
  Future<BuildingMaterialOrderModel> cancelOrder(String orderId);
  Future<BuildingMaterialOrderModel> confirmShipmentDelivery({
    required String orderId,
    required String shipmentId,
  });

  // RFQ
  Future<List<RfqRequestModel>> getRfqs();
  Future<RfqRequestModel> createRfq(RfqRequestModel rfq);
  Future<RfqRequestModel> acceptQuote({
    required String rfqId,
    required String quoteId,
  });
}

class BuildingMaterialsOrderRepositoryImpl
    implements BuildingMaterialsOrderRepository {
  final List<BuildingMaterialOrderModel> _orders = [];
  final List<RfqRequestModel> _rfqs = [];
  final Duration delay;

  BuildingMaterialsOrderRepositoryImpl({
    this.delay = const Duration(milliseconds: 150),
  }) {
    _orders.addAll(MockBuildingMaterialsComprehensiveData.mockOrders);
    _rfqs.addAll(MockBuildingMaterialsComprehensiveData.mockRfqs);
  }

  @override
  Future<List<BuildingMaterialOrderModel>> getOrders({
    BuildingMaterialOrderStatus? filterStatus,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (filterStatus == null) return List.unmodifiable(_orders);
    return _orders.where((o) => o.status == filterStatus).toList();
  }

  @override
  Future<BuildingMaterialOrderModel> getOrderById(String orderId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final order = _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => _orders.first,
    );
    return order;
  }

  @override
  Future<BuildingMaterialOrderModel> createOrderFromCart({
    required BuildingMaterialCartModel cart,
    required SupplierModel supplier,
    required String recipientName,
    required String recipientPhone,
    required String deliveryAddress,
    required String city,
    required String governorate,
    double? projectLat,
    double? projectLng,
    String? deliveryNotes,
    required String paymentMethod,
    required DateTime requestedDeliveryDate,
    int numberOfStagedShipments = 1,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    final String orderId = 'ord-bm-${DateTime.now().millisecondsSinceEpoch}';
    final String orderNumber = 'ORD-BM-${DateTime.now().year}-${_orders.length + 903}';

    // فلترة المنتجات الخاصة بهذا المورد
    final supplierItems = cart.items
        .where((i) => i.supplier.id == supplier.id)
        .toList();

    final orderItems = supplierItems.map((item) {
      return BuildingMaterialOrderItemModel(
        id: 'ord-item-${item.id}',
        productId: item.product.id,
        title: item.product.name,
        brand: item.product.brand,
        imageUrl: item.product.primaryImageUrl,
        unit: item.selectedUnit,
        requestedQuantity: item.quantity,
        deliveredQuantity: 0.0,
        unitPrice: item.unitPrice,
        technicalSpecs: item.product.technicalSpecs,
      );
    }).toList();

    final subtotal = supplierItems.fold(0.0, (sum, i) => sum + i.totalPrice);
    final freight = cart.calculatedFreight > 0 ? cart.calculatedFreight : 1500.0;
    final grandTotal = subtotal + freight - cart.discountAmount;

    // إنشاء الشحنات المرحلية (Staged Deliveries)
    final List<StagedShipmentModel> shipments = [];
    final totalQty = orderItems.fold(0.0, (sum, i) => sum + i.requestedQuantity);
    final primaryUnit = orderItems.isNotEmpty ? orderItems.first.unit : MaterialUnit.ton;
    final shipmentQty = (totalQty / numberOfStagedShipments);

    for (int i = 0; i < numberOfStagedShipments; i++) {
      final daysOffset = i * 2;
      shipments.add(
        StagedShipmentModel(
          id: 'shp-$orderId-${i + 1}',
          shipmentNumber: 'SHP-${orderNumber.split('-').last}-${String.fromCharCode(65 + i)}',
          shipmentIndex: i + 1,
          totalShipments: numberOfStagedShipments,
          allocatedQuantity: UnitConverter.roundCurrency(shipmentQty),
          unit: primaryUnit,
          scheduledDate: requestedDeliveryDate.add(Duration(days: daysOffset)),
          status: i == 0 ? ShipmentStatus.preparing : ShipmentStatus.scheduled,
          driverName: i == 0 ? 'محمد عبد الله (سائق المصنع)' : null,
          driverPhone: i == 0 ? '01011223344' : null,
          truckPlateNumber: i == 0 ? 'ر ق م 4582' : null,
          deliveryNotes: 'الدفعة ${i + 1} من $numberOfStagedShipments',
        ),
      );
    }

    final newOrder = BuildingMaterialOrderModel(
      id: orderId,
      orderNumber: orderNumber,
      userId: cart.userId,
      supplier: supplier,
      items: orderItems,
      status: BuildingMaterialOrderStatus.confirmed,
      subtotal: subtotal,
      freightCost: freight,
      discountAmount: cart.discountAmount,
      taxAmount: 0.0,
      grandTotal: grandTotal,
      paymentMethod: paymentMethod,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      deliveryAddress: deliveryAddress,
      city: city,
      governorate: governorate,
      projectLatitude: projectLat,
      projectLongitude: projectLng,
      deliveryNotes: deliveryNotes,
      createdAt: DateTime.now(),
      estimatedDeliveryDate: requestedDeliveryDate,
      shipments: shipments,
      timeline: [
        OrderTimelineEvent(
          title: 'تم إنشاء الطلب وتأكيده',
          description: 'تم تسجيل الطلب وتنسيق الشحنات مع مورد $supplier.name',
          timestamp: DateTime.now(),
        ),
      ],
    );

    _orders.insert(0, newOrder);
    return newOrder;
  }

  @override
  Future<BuildingMaterialOrderModel> cancelOrder(String orderId) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw ArgumentError('الطلب غير موجود.');

    final existing = _orders[index];
    if (existing.status == BuildingMaterialOrderStatus.delivered ||
        existing.status == BuildingMaterialOrderStatus.inTransit) {
      throw StateError('لا يمكن إلغاء الطلب بعد خروج الشحنة للموقع.');
    }

    final updated = existing.copyWith(
      status: BuildingMaterialOrderStatus.cancelled,
      timeline: [
        ...existing.timeline,
        OrderTimelineEvent(
          title: 'تم إلغاء الطلب',
          description: 'تم إلغاء الطلب واسترجاع الحجز في المستودع',
          timestamp: DateTime.now(),
        ),
      ],
    );
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<BuildingMaterialOrderModel> confirmShipmentDelivery({
    required String orderId,
    required String shipmentId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) throw ArgumentError('الطلب غير موجود.');

    final order = _orders[orderIndex];
    final updatedShipments = order.shipments.map((shp) {
      if (shp.id == shipmentId) {
        return shp.copyWith(
          status: ShipmentStatus.delivered,
          deliveredDate: DateTime.now(),
          isConfirmedByBuyer: true,
        );
      }
      return shp;
    }).toList();

    // حساب إجمالي الكميات المسلمة
    final deliveredShipmentsQty = updatedShipments
        .where((s) => s.status == ShipmentStatus.delivered)
        .fold(0.0, (sum, s) => sum + s.allocatedQuantity);

    final updatedItems = order.items.map((item) {
      return BuildingMaterialOrderItemModel(
        id: item.id,
        productId: item.productId,
        title: item.title,
        brand: item.brand,
        imageUrl: item.imageUrl,
        unit: item.unit,
        requestedQuantity: item.requestedQuantity,
        deliveredQuantity: deliveredShipmentsQty.clamp(0.0, item.requestedQuantity),
        unitPrice: item.unitPrice,
        technicalSpecs: item.technicalSpecs,
      );
    }).toList();

    final allDelivered = updatedShipments.every((s) => s.status == ShipmentStatus.delivered);
    final newStatus = allDelivered
        ? BuildingMaterialOrderStatus.delivered
        : BuildingMaterialOrderStatus.partialDelivery;

    final updatedOrder = order.copyWith(
      shipments: updatedShipments,
      items: updatedItems,
      status: newStatus,
      timeline: [
        ...order.timeline,
        OrderTimelineEvent(
          title: 'تأكيد استلام شحنة',
          description: 'قام العميل بتأكيد استلام الدفعة ومطابقة الأوزان بالموقع',
          timestamp: DateTime.now(),
        ),
      ],
    );

    _orders[orderIndex] = updatedOrder;
    return updatedOrder;
  }

  @override
  Future<List<RfqRequestModel>> getRfqs() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return List.unmodifiable(_rfqs);
  }

  @override
  Future<RfqRequestModel> createRfq(RfqRequestModel rfq) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _rfqs.insert(0, rfq);
    return rfq;
  }

  @override
  Future<RfqRequestModel> acceptQuote({
    required String rfqId,
    required String quoteId,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final rfqIndex = _rfqs.indexWhere((r) => r.id == rfqId);
    if (rfqIndex == -1) throw ArgumentError('طلب عرض السعر غير موجود.');

    final rfq = _rfqs[rfqIndex];
    final updatedQuotes = rfq.quotes.map((q) {
      return SupplierQuoteModel(
        id: q.id,
        rfqId: q.rfqId,
        supplier: q.supplier,
        quotedUnitPrice: q.quotedUnitPrice,
        quotedFreightCost: q.quotedFreightCost,
        unit: q.unit,
        quantity: q.quantity,
        deliveryDurationDays: q.deliveryDurationDays,
        notes: q.notes,
        quoteDate: q.quoteDate,
        validUntil: q.validUntil,
        isAccepted: q.id == quoteId,
      );
    }).toList();

    final updatedRfq = rfq.copyWith(
      status: RfqStatus.awarded,
      quotes: updatedQuotes,
    );
    _rfqs[rfqIndex] = updatedRfq;
    return updatedRfq;
  }
}
