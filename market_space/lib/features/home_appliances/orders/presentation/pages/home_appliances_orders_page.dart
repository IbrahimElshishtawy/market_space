import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import 'package:market_space/core/routing/route_names.dart';
import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/features/home_appliances/navigation/home_appliances_navigation_config.dart';
import 'package:market_space/features/home_appliances/orders/data/models/appliance_order_model.dart';
import 'package:market_space/features/home_appliances/orders/presentation/controllers/home_appliances_order_controller.dart';
import 'package:market_space/features/home_appliances/orders/presentation/widgets/order_status_timeline.dart';
import 'package:market_space/shared/widgets/app_empty_state.dart';
import 'package:market_space/shared/widgets/app_error_view.dart';
import 'package:market_space/shared/widgets/app_loading_indicator.dart';
import 'package:market_space/shared/widgets/market_widgets/safe_network_image.dart';

class HomeAppliancesOrdersPage extends StatefulWidget {
  final HomeAppliancesOrderController? controller;

  const HomeAppliancesOrdersPage({super.key, this.controller});

  @override
  State<HomeAppliancesOrdersPage> createState() =>
      _HomeAppliancesOrdersPageState();
}

class _HomeAppliancesOrdersPageState extends State<HomeAppliancesOrdersPage> {
  late final HomeAppliancesOrderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomeAppliancesOrderController();
    _controller.loadOrders();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showOrderDetailsSheet(ApplianceOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفاصيل الطلب: ${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8.0),

                // Order Timeline
                OrderStatusTimeline(currentStatus: order.status),
                const SizedBox(height: 16.0),

                // Items list
                const Text(
                  'المنتجات المشتراة:',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                ...order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadii.xs,
                          child: SizedBox(
                            width: 40.0,
                            height: 40.0,
                            child: SafeNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            '${item.title} (x${item.quantity})',
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ),
                        Text(
                          '${item.totalPrice.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 24.0),

                // Pricing Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي الشامل:'),
                    Text(
                      '${order.grandTotal.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  'طريقة الدفع: ${order.paymentMethod}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  'العنوان: ${order.deliveryAddress}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.lightTextSecondary,
                  ),
                ),

                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: const Text('طلبات الأجهزة المنزلية'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppColors.neutral,
        ),
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<HomeAppliancesOrderState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return Center(
                  child: AppErrorView(
                    message: state.errorMessage!,
                    onRetry: _controller.loadOrders,
                  ),
                );
              }

              final ordersList = state.filteredOrders;

              return RefreshIndicator(
                color: AppColors.neutral,
                onRefresh: _controller.loadOrders,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Status Filter Chips
                    SliverToBoxAdapter(
                      child: Container(
                        height: 48.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: [
                            _buildFilterChip('الكل', null, state.statusFilter),
                            _buildFilterChip(
                              'جاري الشحن',
                              ApplianceOrderStatus.shipped,
                              state.statusFilter,
                            ),
                            _buildFilterChip(
                              'تم التسليم',
                              ApplianceOrderStatus.delivered,
                              state.statusFilter,
                            ),
                            _buildFilterChip(
                              'ملغي',
                              ApplianceOrderStatus.cancelled,
                              state.statusFilter,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (ordersList.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppEmptyState(
                            title: 'لا توجد طلبات سابقة',
                            message: 'عند إتمام طلبات شراء الأجهزة المنزلية ستظهر تفاصيلها وحالة شحنها هنا',
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final order = ordersList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadii.lg,
                              border: Border.all(color: AppColors.lightBorder),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Order Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'رقم الطلب: ${order.orderNumber}',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 3.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: AppRadii.xs,
                                        ),
                                        child: Text(
                                          order.status.label,
                                          style: const TextStyle(
                                            color: AppColors.neutral,
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),

                                  // Timeline Status Progress Bar
                                  OrderStatusTimeline(
                                    currentStatus: order.status,
                                  ),

                                  const Divider(height: 20.0),

                                  // Products Thumbnails & Info Row
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 42.0,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: order.items.length,
                                          itemBuilder: (ctx, i) {
                                            final item = order.items[i];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                left: 6.0,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: AppRadii.xs,
                                                child: SizedBox(
                                                  width: 42.0,
                                                  height: 42.0,
                                                  child: SafeNetworkImage(
                                                    imageUrl: item.imageUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${order.grandTotal.toStringAsFixed(0)} ج.م',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.neutral,
                                            ),
                                          ),
                                          const SizedBox(height: 2.0),
                                          InkWell(
                                            onTap: () =>
                                                _showOrderDetailsSheet(order),
                                            child: const Text(
                                              'عرض التفاصيل >',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.neutral,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }, childCount: ordersList.length),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 90.0)),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: HomeAppliancesNavigationConfig.config,
          currentIndex: 3, // 4th tab is "طلباتي"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.homeAppliances);
            } else if (index == 1 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/categories');
            } else if (index == 2 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/cart');
            } else if (index == 4 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/notifications');
            }
          },
          notificationController: dependencies?.notificationController,
          isVisible: true,
          showFloatingAction: false,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    ApplianceOrderStatus? status,
    ApplianceOrderStatus? selectedStatus,
  ) {
    final isSelected = status == selectedStatus;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.neutral,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.neutral,
          fontSize: 12.0,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => _controller.setStatusFilter(status),
      ),
    );
  }
}
