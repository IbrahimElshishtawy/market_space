import 'package:flutter/foundation.dart';

import 'package:market_space/features/home_appliances/orders/data/models/appliance_order_model.dart';
import 'package:market_space/features/home_appliances/orders/data/repositories/home_appliances_order_repository.dart';

class HomeAppliancesOrderState {
  final bool isLoading;
  final List<ApplianceOrderModel> orders;
  final ApplianceOrderStatus? statusFilter;
  final String? errorMessage;

  const HomeAppliancesOrderState({
    this.isLoading = false,
    this.orders = const [],
    this.statusFilter,
    this.errorMessage,
  });

  HomeAppliancesOrderState copyWith({
    bool? isLoading,
    List<ApplianceOrderModel>? orders,
    ApplianceOrderStatus? statusFilter,
    bool clearStatusFilter = false,
    String? errorMessage,
  }) {
    return HomeAppliancesOrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      errorMessage: errorMessage,
    );
  }

  List<ApplianceOrderModel> get filteredOrders {
    if (statusFilter == null) return orders;
    return orders.where((o) => o.status == statusFilter).toList();
  }
}

class HomeAppliancesOrderController
    extends ValueNotifier<HomeAppliancesOrderState> {
  final HomeAppliancesOrderRepository repository;
  bool _isDisposed = false;

  HomeAppliancesOrderController({HomeAppliancesOrderRepository? repository})
    : repository = repository ?? MockHomeAppliancesOrderRepository(),
      super(const HomeAppliancesOrderState(isLoading: true)) {
    loadOrders();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadOrders() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await repository.getOrders();
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, orders: list);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل طلبات الأجهزة: $e',
      );
    }
  }

  void setStatusFilter(ApplianceOrderStatus? status) {
    if (_isDisposed) return;
    if (status == null) {
      value = value.copyWith(clearStatusFilter: true);
    } else {
      value = value.copyWith(statusFilter: status);
    }
  }

  Future<void> placeOrder(ApplianceOrderModel order) async {
    if (_isDisposed) return;
    await repository.placeOrder(order);
    await loadOrders();
  }

  Future<void> cancelOrder(String orderId) async {
    if (_isDisposed) return;
    await repository.cancelOrder(orderId);
    await loadOrders();
  }
}
