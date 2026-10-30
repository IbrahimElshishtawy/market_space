import '../../../data/mock/mock_home_appliances_data.dart';
import '../models/appliance_order_model.dart';

abstract class HomeAppliancesOrderRepository {
  Future<List<ApplianceOrderModel>> getOrders({String? userId});
  Future<ApplianceOrderModel?> getOrderById(String orderId);
  Future<ApplianceOrderModel> placeOrder(ApplianceOrderModel order);
  Future<bool> cancelOrder(String orderId);
}

class MockHomeAppliancesOrderRepository
    implements HomeAppliancesOrderRepository {
  static final List<ApplianceOrderModel> _ordersStore = [
    ApplianceOrderModel(
      id: 'ord-101',
      orderNumber: 'HA-2025-01',
      userId: 'user-1',
      items: [
        ApplianceOrderItemModel(
          id: 'item-1',
          title: 'غسالة ملابس أوتماتيك 9 كيلو انفرتر',
          brandName: 'LG',
          imageUrl: MockHomeAppliancesData.products.first.imageUrl,
          quantity: 1,
          unitPrice: 24500.0,
        ),
      ],
      status: ApplianceOrderStatus.shipped,
      subtotal: 24500.0,
      shippingFee: 150.0,
      discountAmount: 0.0,
      grandTotal: 24650.0,
      paymentMethod: 'الدفع عند الاستلام',
      deliveryAddress: 'طنطا، شارع النادي - برج الاستاد',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 1)),
    ),
    ApplianceOrderModel(
      id: 'ord-102',
      orderNumber: 'HA-2025-02',
      userId: 'user-1',
      items: [
        ApplianceOrderItemModel(
          id: 'item-2',
          title: 'ثلاجة نوفروست 18 قدم ديجيتال',
          brandName: 'شارب',
          imageUrl: MockHomeAppliancesData.products[1].imageUrl,
          quantity: 1,
          unitPrice: 38000.0,
        ),
      ],
      status: ApplianceOrderStatus.delivered,
      subtotal: 38000.0,
      shippingFee: 150.0,
      discountAmount: 500.0,
      grandTotal: 37650.0,
      paymentMethod: 'تقسيط ميسر',
      deliveryAddress: 'طنطا، طريق الكورنيش',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      estimatedDeliveryDate: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  @override
  Future<List<ApplianceOrderModel>> getOrders({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_ordersStore);
  }

  @override
  Future<ApplianceOrderModel?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _ordersStore.firstWhere(
        (o) => o.id == orderId || o.orderNumber == orderId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ApplianceOrderModel> placeOrder(ApplianceOrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ordersStore.insert(0, order);
    return order;
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _ordersStore.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _ordersStore[index] = _ordersStore[index].copyWith(
        status: ApplianceOrderStatus.cancelled,
      );
      return true;
    }
    return false;
  }
}
