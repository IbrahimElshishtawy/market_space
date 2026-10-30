import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../data/models/building_material_order_model.dart';
import '../../data/models/rfq_model.dart';
import '../../navigation/building_materials_navigation_config.dart';
import '../controllers/building_materials_order_controller.dart';

class BuildingMaterialsOrdersPage extends StatefulWidget {
  const BuildingMaterialsOrdersPage({super.key});

  @override
  State<BuildingMaterialsOrdersPage> createState() =>
      _BuildingMaterialsOrdersPageState();
}

class _BuildingMaterialsOrdersPageState
    extends State<BuildingMaterialsOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBottomNavIndex = 3; // طلباتي

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dependencies = AppDependencies.maybeOf(context);
      dependencies?.buildingMaterialsOrderController.loadOrders();
      dependencies?.buildingMaterialsOrderController.loadRfqs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomNavSelected(int index) {
    if (index == _selectedBottomNavIndex) return;
    setState(() => _selectedBottomNavIndex = index);

    final config = BuildingMaterialsNavigationConfig.config;
    final item = config.items[index];
    context.go(item.destination);
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final orderController = dependencies.buildingMaterialsOrderController;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'طلبيات مواد البناء والتوريد',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.buildingMaterials);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.request_quote_outlined),
              tooltip: 'طلب تسعير جديد (RFQ)',
              onPressed: () => context.push(RouteNames.buildingMaterialsRfq),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.emerald700,
            unselectedLabelColor: AppColors.slate500,
            indicatorColor: AppColors.emerald700,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'قيد التوريد'),
              Tab(text: 'المكتملة'),
              Tab(text: 'عروض الأسعار'),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: BuildingMaterialsNavigationConfig.config,
          currentIndex: _selectedBottomNavIndex,
          onTabSelected: _onBottomNavSelected,
        ),
        body: ValueListenableBuilder<BuildingMaterialsOrderState>(
          valueListenable: orderController,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(state.orders),
                _buildOrdersList(
                  state.orders
                      .where((o) =>
                          o.status != BuildingMaterialOrderStatus.delivered &&
                          o.status != BuildingMaterialOrderStatus.cancelled &&
                          o.status != BuildingMaterialOrderStatus.returned)
                      .toList(),
                ),
                _buildOrdersList(
                  state.orders
                      .where((o) =>
                          o.status == BuildingMaterialOrderStatus.delivered)
                      .toList(),
                ),
                _buildRfqList(state.rfqs),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<BuildingMaterialOrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppEmptyState(
            title: 'لا توجد طلبات في هذا القسم',
            message: 'يمكنك إنشاء طلب جديد لمواد البناء وسيتم جدولته وشحنه لموقع مشروعك.',
            action: ElevatedButton(
              onPressed: () => context.go(RouteNames.buildingMaterials),
              child: const Text('تصفح مواد البناء'),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => AppDependencies.of(context)
          .buildingMaterialsOrderController
          .loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildingMaterialOrderModel order) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: AppRadii.lg,
        onTap: () {
          context.push(
            '${RouteNames.buildingMaterialsOrderDetail}?orderId=${order.id}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم الطلب والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: AppRadii.full,
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // اسم المورد وتاريخ الطلب
              Text(
                'المورد: ${order.supplier.name}',
                style: TextStyle(fontSize: 12, color: AppColors.slate600),
              ),
              Text(
                'تاريخ الطلب: ${order.createdAt.year}/${order.createdAt.month}/${order.createdAt.day}',
                style: TextStyle(fontSize: 11, color: AppColors.slate400),
              ),
              const Divider(height: 16, color: AppColors.slate200),

              // عدد المواد وإجمالي الكمية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} مواد • إجمالي الكمية: ${order.totalRequestedQuantity.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.slate800),
                  ),
                  Text(
                    '${order.grandTotal.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.emerald700),
                  ),
                ],
              ),

              // شريط تقدم التوريد المرحلي
              if (order.shipments.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نسبة اكتمال التوريد للموقع:',
                      style: TextStyle(fontSize: 11, color: AppColors.slate500),
                    ),
                    Text(
                      '${order.deliveryCompletionPercentage}% (${order.totalDeliveredQuantity.toStringAsFixed(0)} من ${order.totalRequestedQuantity.toStringAsFixed(0)})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.slate800),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: AppRadii.full,
                  child: LinearProgressIndicator(
                    value: order.deliveryCompletionRatio,
                    minHeight: 6,
                    backgroundColor: AppColors.slate200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      order.deliveryCompletionRatio >= 1.0 ? AppColors.emerald700 : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRfqList(List<RfqRequestModel> rfqs) {
    if (rfqs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppEmptyState(
            title: 'لا توجد طلبات عروض أسعار',
            message: 'يمكنك طلب عروض أسعار لمشروعك الكبير وتلقي عروض متنافسة من كبرى المصانع والموردين.',
            action: ElevatedButton(
              onPressed: () => context.push(RouteNames.buildingMaterialsRfq),
              child: const Text('طلب عرض سعر الآن'),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: rfqs.length,
      itemBuilder: (context, index) {
        final rfq = rfqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.lg,
            border: Border.all(color: AppColors.slate200),
          ),
          child: ExpansionTile(
            title: Text(
              '${rfq.materialName} (${rfq.quantity.toStringAsFixed(0)} ${rfq.unit.label})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              'المشروع: ${rfq.projectName} • ${rfq.quotes.length} عروض مقدمة',
              style: TextStyle(fontSize: 11, color: AppColors.slate500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: rfq.status == RfqStatus.awarded ? AppColors.emerald50 : const Color(0xFFEFF6FF),
                borderRadius: AppRadii.sm,
              ),
              child: Text(
                rfq.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: rfq.status == RfqStatus.awarded ? AppColors.emerald700 : const Color(0xFF1D4ED8),
                ),
              ),
            ),
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('العروض المقدمة من الموردين:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slate700)),
                    const SizedBox(height: AppSpacing.sm),
                    ...rfq.quotes.map((q) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: q.isAccepted ? AppColors.emerald50 : AppColors.slate50,
                          borderRadius: AppRadii.md,
                          border: Border.all(color: q.isAccepted ? AppColors.emerald300 : AppColors.slate200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(q.supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('سعر الوحدة: ${q.quotedUnitPrice.toStringAsFixed(0)} ج.م • الشحن: ${q.quotedFreightCost.toStringAsFixed(0)} ج.م',
                                      style: TextStyle(fontSize: 11, color: AppColors.slate600)),
                                  Text('مدة التوصيل: ${q.deliveryDurationDays} يوم', style: TextStyle(fontSize: 10, color: AppColors.slate500)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${q.grandTotal.toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.emerald700)),
                                if (!q.isAccepted && rfq.status != RfqStatus.awarded)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.emerald700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      AppDependencies.of(context)
                                          .buildingMaterialsOrderController
                                          .acceptQuote(rfqId: rfq.id, quoteId: q.id);
                                    },
                                    child: const Text('قبول العرض', style: TextStyle(fontSize: 11)),
                                  )
                                else if (q.isAccepted)
                                  const Text('عرض معتمد', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.emerald700)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(BuildingMaterialOrderStatus status) {
    switch (status) {
      case BuildingMaterialOrderStatus.delivered:
        return AppColors.emerald700;
      case BuildingMaterialOrderStatus.partialDelivery:
      case BuildingMaterialOrderStatus.inTransit:
      case BuildingMaterialOrderStatus.shipped:
        return const Color(0xFF2563EB); // أزرق
      case BuildingMaterialOrderStatus.processing:
      case BuildingMaterialOrderStatus.readyForShipping:
      case BuildingMaterialOrderStatus.confirmed:
        return Colors.orange.shade800;
      case BuildingMaterialOrderStatus.pendingConfirmation:
      case BuildingMaterialOrderStatus.priceReview:
        return AppColors.slate700;
      case BuildingMaterialOrderStatus.cancelled:
      case BuildingMaterialOrderStatus.returned:
        return Colors.red.shade700;
    }
  }
}
