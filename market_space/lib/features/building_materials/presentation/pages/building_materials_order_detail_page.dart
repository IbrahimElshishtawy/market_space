import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/building_material_order_model.dart';
import '../../data/models/staged_shipment_model.dart';

class BuildingMaterialsOrderDetailPage extends StatefulWidget {
  final String orderId;

  const BuildingMaterialsOrderDetailPage({super.key, required this.orderId});

  @override
  State<BuildingMaterialsOrderDetailPage> createState() =>
      _BuildingMaterialsOrderDetailPageState();
}

class _BuildingMaterialsOrderDetailPageState
    extends State<BuildingMaterialsOrderDetailPage> {
  BuildingMaterialOrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final dependencies = AppDependencies.of(context);
    final repo = dependencies.buildingMaterialsOrderController.repository;
    try {
      final order = await repo.getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmShipment(String shipmentId) async {
    final dependencies = AppDependencies.of(context);
    final success = await dependencies.buildingMaterialsOrderController
        .confirmShipmentDelivery(
          orderId: widget.orderId,
          shipmentId: shipmentId,
        );

    if (success) {
      await _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد استلام الشحنة بنجاح وتحديث نسبة التوريد بالموقع.'),
            backgroundColor: AppColors.emerald700,
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟ سيتم إخطار المورد فوراً.'),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: const Text('رجوع')),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('تأكيد الإلغاء', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (confirm == true) {
      final dependencies = AppDependencies.of(context);
      final ok = await dependencies.buildingMaterialsOrderController.cancelOrder(widget.orderId);
      if (ok) {
        await _loadOrder();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء الطلب بنجاح.'), backgroundColor: AppColors.slate800),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            _order != null ? 'طلب ${_order!.orderNumber}' : 'تفاصيل الطلب',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: AppLoadingIndicator())
            : _order == null
            ? const Center(child: Text('الطلب غير موجود.'))
            : _buildContent(_order!),
      ),
    );
  }

  Widget _buildContent(BuildingMaterialOrderModel order) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // بطاقة الحالة العامة ونسبة التوريد
        _buildStatusHeaderCard(order),
        const SizedBox(height: AppSpacing.md),

        // قسم التوريد على مراحل (Staged Deliveries)
        if (order.shipments.isNotEmpty) ...[
          _buildStagedShipmentsSection(order),
          const SizedBox(height: AppSpacing.md),
        ],

        // بيانات المورد
        _buildSupplierCard(order),
        const SizedBox(height: AppSpacing.md),

        // عناصر الطلبية ومواصفاتها
        _buildItemsCard(order),
        const SizedBox(height: AppSpacing.md),

        // موقع المشروع وبيانات التسليم
        _buildDeliverySiteCard(order),
        const SizedBox(height: AppSpacing.md),

        // ملخص التكاليف والفاتورة
        _buildPricingCard(order),
        const SizedBox(height: AppSpacing.md),

        // الجدول الزمني للطلب (Timeline)
        _buildTimelineCard(order),
        const SizedBox(height: AppSpacing.lg),

        // إجراءات الطلب (إلغاء الطلب إذا كان متاحاً)
        if (order.status == BuildingMaterialOrderStatus.confirmed ||
            order.status == BuildingMaterialOrderStatus.pendingConfirmation ||
            order.status == BuildingMaterialOrderStatus.priceReview) ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('إلغاء هذا الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _cancelOrder,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ],
    );
  }

  Widget _buildStatusHeaderCard(BuildingMaterialOrderModel order) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate900),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'طريقة الدفع: ${order.paymentMethod}',
            style: TextStyle(fontSize: 12, color: AppColors.slate600),
          ),
          const Divider(height: 20, color: AppColors.slate200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressMetric('المطلوب', '${order.totalRequestedQuantity.toStringAsFixed(0)} وحدة'),
              _buildProgressMetric('تم تسليمه', '${order.totalDeliveredQuantity.toStringAsFixed(0)} وحدة', color: AppColors.emerald700),
              _buildProgressMetric(
                'المتبقي',
                '${(order.totalRequestedQuantity - order.totalDeliveredQuantity).clamp(0, double.infinity).toStringAsFixed(0)} وحدة',
                color: Colors.orange.shade800,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadii.full,
            child: LinearProgressIndicator(
              value: order.deliveryCompletionRatio,
              minHeight: 8,
              backgroundColor: AppColors.slate200,
              valueColor: AlwaysStoppedAnimation<Color>(
                order.deliveryCompletionRatio >= 1.0 ? AppColors.emerald700 : const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.slate500)),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color ?? AppColors.slate800),
        ),
      ],
    );
  }

  Widget _buildStagedShipmentsSection(BuildingMaterialOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                'الشحنات والدفعات المجدولة (${order.shipments.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.slate200),
          ...order.shipments.map((shp) {
            return _buildShipmentCard(shp);
          }),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(StagedShipmentModel shp) {
    final isDelivered = shp.status == ShipmentStatus.delivered;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDelivered ? AppColors.emerald50.withValues(alpha: 0.5) : AppColors.slate50,
        borderRadius: AppRadii.md,
        border: Border.all(
          color: isDelivered ? AppColors.emerald300 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'شحنة رقم: ${shp.shipmentNumber} (دفعة ${shp.shipmentIndex} من ${shp.totalShipments})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDelivered ? AppColors.emerald100 : const Color(0xFFDBEAFE),
                  borderRadius: AppRadii.sm,
                ),
                child: Text(
                  shp.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDelivered ? AppColors.emerald800 : const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'الكمية المخصصة: ${shp.allocatedQuantity.toStringAsFixed(0)} ${shp.unit.label}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(
            'موعد التوريد: ${shp.scheduledDate.year}/${shp.scheduledDate.month}/${shp.scheduledDate.day}',
            style: TextStyle(fontSize: 11, color: AppColors.slate600),
          ),
          if (shp.driverName != null) ...[
            const SizedBox(height: 4),
            Text(
              'السائق: ${shp.driverName} • الشاحنة: ${shp.truckPlateNumber ?? "غير محدد"}',
              style: TextStyle(fontSize: 11, color: AppColors.slate600),
            ),
          ],
          if (shp.status == ShipmentStatus.inTransit ||
              (shp.status == ShipmentStatus.delivered && !shp.isConfirmedByBuyer)) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: const Text('تأكيد استلام وتفريغ هذه الشحنة', style: TextStyle(fontSize: 12)),
                onPressed: () => _confirmShipment(shp.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplierCard(BuildingMaterialOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded, color: AppColors.slate700, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                ),
                Text(
                  '${order.supplier.companyType} • هاتف: ${order.supplier.contactPhone}',
                  style: TextStyle(fontSize: 11, color: AppColors.slate500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppColors.emerald700),
            tooltip: 'الاتصال بالمورد',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('الاتصال بـ ${order.supplier.contactPhone}')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildingMaterialOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل المواد المطلوبة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
          ),
          const Divider(height: 20, color: AppColors.slate200),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AppNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 50,
                    height: 50,
                    borderRadius: AppRadii.sm,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('المصنع: ${item.brand}', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                        Text(
                          '${item.requestedQuantity.toStringAsFixed(0)} ${item.unit.label} × ${item.unitPrice.toStringAsFixed(0)} ج.م',
                          style: TextStyle(fontSize: 11, color: AppColors.slate600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliverySiteCard(BuildingMaterialOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'موقع تسليم المشروع والتعتيق',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.slate900),
          ),
          const Divider(height: 20, color: AppColors.slate200),
          Text('المستلم: ${order.recipientName} (${order.recipientPhone})', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text('العنوان: ${order.deliveryAddress}، ${order.city}، ${order.governorate}', style: const TextStyle(fontSize: 12)),
          if (order.deliveryNotes != null) ...[
            const SizedBox(height: 4),
            Text('ملاحظات الموقع: ${order.deliveryNotes}', style: TextStyle(fontSize: 11, color: AppColors.slate600)),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildingMaterialOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('فاتورة التوريد الإجمالية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton.icon(
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('تحميل الفاتورة PDF', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جاري تحميل فاتورة الطلب ${order.orderNumber}...')),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.slate200),
          _buildPriceRow('إجمالي المواد', '${order.subtotal.toStringAsFixed(0)} ج.م'),
          _buildPriceRow('تكلفة النقل والتعتيق', '${order.freightCost.toStringAsFixed(0)} ج.م'),
          if (order.discountAmount > 0)
            _buildPriceRow('الخصم المعتمد', '- ${order.discountAmount.toStringAsFixed(0)} ج.م', isDiscount: true),
          const Divider(height: 16, color: AppColors.slate200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي الصافي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                '${order.grandTotal.toStringAsFixed(0)} ج.م',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.emerald700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.slate600)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : AppColors.slate800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildingMaterialOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الجدول الزمني للطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: AppSpacing.md),
          ...order.timeline.map((evt) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      evt.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: evt.isCompleted ? AppColors.emerald700 : AppColors.slate400,
                      size: 18,
                    ),
                    Container(width: 2, height: 35, color: AppColors.slate200),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(evt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(evt.description, style: TextStyle(fontSize: 11, color: AppColors.slate600)),
                      Text(
                        '${evt.timestamp.hour}:${evt.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 10, color: AppColors.slate400),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildingMaterialOrderStatus status) {
    switch (status) {
      case BuildingMaterialOrderStatus.delivered:
        return AppColors.emerald700;
      case BuildingMaterialOrderStatus.partialDelivery:
      case BuildingMaterialOrderStatus.inTransit:
      case BuildingMaterialOrderStatus.shipped:
        return const Color(0xFF2563EB);
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
