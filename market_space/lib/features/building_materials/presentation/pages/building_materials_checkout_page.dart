// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/building_material_cart_model.dart';

class BuildingMaterialsCheckoutPage extends StatefulWidget {
  const BuildingMaterialsCheckoutPage({super.key});

  @override
  State<BuildingMaterialsCheckoutPage> createState() =>
      _BuildingMaterialsCheckoutPageState();
}

class _BuildingMaterialsCheckoutPageState
    extends State<BuildingMaterialsCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(
    text: 'المهندس أحمد الهواري',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '01012345678',
  );
  final TextEditingController _addressController = TextEditingController(
    text: 'موقع إنشاء عمارة النخيل، شارع التسعين',
  );
  final TextEditingController _cityController = TextEditingController(
    text: 'التجمع الخامس',
  );
  final TextEditingController _notesController = TextEditingController();

  String _selectedGovernorate = 'القاهرة';
  DateTime _selectedDeliveryDate = DateTime.now().add(const Duration(days: 2));
  int _numberOfShipments = 1; // 1 = دفعة واحدة، 2 = دفعتين، 3 = 3 دفعات
  String _selectedPaymentMethod = 'تحويل بنكي معتمد';
  bool _isSubmitting = false;

  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'القليوبية',
    'الإسكندرية',
    'الشرقية',
    'المنوفية',
    'السويس',
    'الفيوم',
    'بني سويف',
  ];

  final List<String> _paymentMethods = [
    'تحويل بنكي معتمد',
    'الدفع عند الاستلام مع عربون',
    'شيك بنكي مقبول الدفع',
    'بطاقة ائتمانية / دفع إلكتروني',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmOrder(BuildingMaterialCartModel cart) async {
    if (!_formKey.currentState!.validate()) return;
    if (cart.items.isEmpty) return;

    setState(() => _isSubmitting = true);

    final dependencies = AppDependencies.of(context);
    final orderController = dependencies.buildingMaterialsOrderController;
    final cartController = dependencies.buildingMaterialsCartController;

    // في نظام Marketplace، نأخذ المورد الرئيسي للمواد المطلوبة
    final primarySupplier = cart.items.first.supplier;

    final createdOrder = await orderController.createOrder(
      cart: cart,
      supplier: primarySupplier,
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      city: _cityController.text.trim(),
      governorate: _selectedGovernorate,
      deliveryNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      requestedDeliveryDate: _selectedDeliveryDate,
      numberOfStagedShipments: _numberOfShipments,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (createdOrder != null) {
      // إفراغ السلة فقط بعد نجاح إنشاء الطلب
      await cartController.clearCart();
      if (!mounted) return;

      // إظهار حوار التأكيد والتوجه لصفحة تفاصيل الطلب
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          title: Row(
            children: const [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.emerald700,
                size: 28,
              ),
              SizedBox(width: 8),
              Text('تم تأكيد الطلب بنجاح!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رقم الطلب الرسمي: ${createdOrder.orderNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text('المورد: ${createdOrder.supplier.name}'),
              Text(
                'عدد الشحنات المجدولة: ${createdOrder.shipments.length} شحنة',
              ),
              Text(
                'الإجمالي: ${createdOrder.grandTotal.toStringAsFixed(0)} ج.م',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ctx.pop();
                context.go(
                  '${RouteNames.buildingMaterialsOrderDetail}?orderId=${createdOrder.id}',
                );
              },
              child: const Text('متابعة الطلب والشحنات'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderController.value.errorMessage ??
                'فشل إنشاء الطلب. يرجى المحاولة مرة أخرى.',
          ),
          backgroundColor: AppColors.rose600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final cartController = dependencies.buildingMaterialsCartController;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'إتمام الطلب وتحديد التوريد',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
        body: ValueListenableBuilder<BuildingMaterialCartModel>(
          valueListenable: cartController,
          builder: (context, cart, _) {
            if (cart.items.isEmpty) {
              return const Center(child: Text('السلة فارغة.'));
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // بيانات المستلم وموقع التشوين
                  _buildDeliverySection(),
                  const SizedBox(height: AppSpacing.md),

                  // نظام التوريد على مراحل (Staged Deliveries)
                  _buildStagedDeliveriesOption(),
                  const SizedBox(height: AppSpacing.md),

                  // طريقة الدفع
                  _buildPaymentMethodSection(),
                  const SizedBox(height: AppSpacing.md),

                  // مراجعة سريعة للمواد
                  _buildOrderReviewSection(cart),
                  const SizedBox(height: AppSpacing.lg),

                  // زر التأكيد
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleConfirmOrder(cart),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'تأكيد الطلب (${cart.grandTotal.toStringAsFixed(0)} ج.م)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
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
            children: const [
              Icon(
                Icons.location_city_rounded,
                color: AppColors.emerald700,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'بيانات موقع المشروع والاستلام',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.slate200),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'اسم المهندس / المستلم بالموقع',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'يرجى إدخال اسم المستلم' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم هاتف مسؤول التشوين',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) => v == null || v.trim().length < 10
                ? 'يرجى إدخال رقم هاتف صحيح'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGovernorate,
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _governorates.map((gov) {
                    return DropdownMenuItem(value: gov, child: Text(gov));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGovernorate = val);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'المدينة / المنطقة',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'العنوان التفصيلي وموقع الورشة/المشروع',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'يرجى إدخال العنوان التفصيلي'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'ملاحظات لسائقي الشاحنات وتفريغ البضاعة (اختياري)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStagedDeliveriesOption() {
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
            children: const [
              Icon(Icons.alt_route_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text(
                'جدولة التوريد المرحلي (Staged Deliveries)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'يمكنك توريد كامل الكمية دفعة واحدة أو تجزئتها على شحنات لتجنب تزاحم الموقع.',
            style: TextStyle(fontSize: 12, color: AppColors.slate600),
          ),
          const SizedBox(height: AppSpacing.md),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('دفعة واحدة')),
              ButtonSegment(value: 2, label: Text('دفعتين')),
              ButtonSegment(value: 3, label: Text('3 شحنات')),
            ],
            selected: {_numberOfShipments},
            onSelectionChanged: (set) {
              setState(() => _numberOfShipments = set.first);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تاريخ بدء أول شحنة:'),
              TextButton.icon(
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(
                  '${_selectedDeliveryDate.year}/${_selectedDeliveryDate.month}/${_selectedDeliveryDate.day}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDeliveryDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDeliveryDate = picked);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
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
            children: const [
              Icon(Icons.payment_rounded, color: AppColors.slate800, size: 20),
              SizedBox(width: 8),
              Text(
                'طريقة الدفع المعتمدة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.slate200),
          ..._paymentMethods.map((method) {
            return RadioListTile<String>(
              value: method,
              groupValue: _selectedPaymentMethod,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                method,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPaymentMethod = val);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderReviewSection(BuildingMaterialCartModel cart) {
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
            'مراجعة عناصر الطلبية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...cart.items.map((i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${i.product.name} (${i.quantity} ${i.selectedUnit.label})',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${i.totalPrice.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 16, color: AppColors.slate200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي الشامل للنقل والتعتيق:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${cart.grandTotal.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.emerald700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
