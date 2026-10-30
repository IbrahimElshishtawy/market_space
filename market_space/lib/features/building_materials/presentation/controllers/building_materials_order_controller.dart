import 'package:flutter/foundation.dart';

import '../../data/models/building_material_cart_model.dart';
import '../../data/models/building_material_order_model.dart';
import '../../data/models/rfq_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/building_materials_order_repository.dart';

class BuildingMaterialsOrderState {
  final bool isLoading;
  final String? errorMessage;
  final List<BuildingMaterialOrderModel> orders;
  final List<RfqRequestModel> rfqs;
  final BuildingMaterialOrderStatus? filterStatus;

  const BuildingMaterialsOrderState({
    this.isLoading = false,
    this.errorMessage,
    this.orders = const [],
    this.rfqs = const [],
    this.filterStatus,
  });

  BuildingMaterialsOrderState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<BuildingMaterialOrderModel>? orders,
    List<RfqRequestModel>? rfqs,
    BuildingMaterialOrderStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return BuildingMaterialsOrderState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      orders: orders ?? this.orders,
      rfqs: rfqs ?? this.rfqs,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

class BuildingMaterialsOrderController
    extends ValueNotifier<BuildingMaterialsOrderState> {
  final BuildingMaterialsOrderRepository repository;

  BuildingMaterialsOrderController({
    BuildingMaterialsOrderRepository? repository,
  }) : repository = repository ?? BuildingMaterialsOrderRepositoryImpl(),
       super(const BuildingMaterialsOrderState());

  Future<void> loadOrders({BuildingMaterialOrderStatus? filterStatus}) async {
    value = value.copyWith(
      isLoading: true,
      errorMessage: null,
      filterStatus: filterStatus,
      clearFilter: filterStatus == null,
    );
    try {
      final orders = await repository.getOrders(filterStatus: filterStatus);
      value = value.copyWith(isLoading: false, orders: orders);
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<BuildingMaterialOrderModel?> createOrder({
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
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final order = await repository.createOrderFromCart(
        cart: cart,
        supplier: supplier,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        deliveryAddress: deliveryAddress,
        city: city,
        governorate: governorate,
        projectLat: projectLat,
        projectLng: projectLng,
        deliveryNotes: deliveryNotes,
        paymentMethod: paymentMethod,
        requestedDeliveryDate: requestedDeliveryDate,
        numberOfStagedShipments: numberOfStagedShipments,
      );
      final updatedOrders = [order, ...value.orders];
      value = value.copyWith(isLoading: false, orders: updatedOrders);
      return order;
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedOrder = await repository.cancelOrder(orderId);
      final updatedList = value.orders.map((o) {
        return o.id == orderId ? updatedOrder : o;
      }).toList();
      value = value.copyWith(isLoading: false, orders: updatedList);
      return true;
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> confirmShipmentDelivery({
    required String orderId,
    required String shipmentId,
  }) async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedOrder = await repository.confirmShipmentDelivery(
        orderId: orderId,
        shipmentId: shipmentId,
      );
      final updatedList = value.orders.map((o) {
        return o.id == orderId ? updatedOrder : o;
      }).toList();
      value = value.copyWith(isLoading: false, orders: updatedList);
      return true;
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> loadRfqs() async {
    try {
      final rfqs = await repository.getRfqs();
      value = value.copyWith(rfqs: rfqs);
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> createRfq(RfqRequestModel rfq) async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final created = await repository.createRfq(rfq);
      final updatedRfqs = [created, ...value.rfqs];
      value = value.copyWith(isLoading: false, rfqs: updatedRfqs);
      return true;
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> acceptQuote({
    required String rfqId,
    required String quoteId,
  }) async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedRfq = await repository.acceptQuote(
        rfqId: rfqId,
        quoteId: quoteId,
      );
      final updatedRfqs = value.rfqs.map((r) {
        return r.id == rfqId ? updatedRfq : r;
      }).toList();
      value = value.copyWith(isLoading: false, rfqs: updatedRfqs);
      return true;
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
