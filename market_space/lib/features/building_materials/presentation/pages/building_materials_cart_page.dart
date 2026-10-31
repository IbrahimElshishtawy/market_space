import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/building_material_cart_model.dart';
import '../controllers/building_materials_cart_controller.dart';
import '../../navigation/building_materials_navigation_config.dart';

class BuildingMaterialsCartPage extends StatefulWidget {
  const BuildingMaterialsCartPage({super.key});

  @override
  State<BuildingMaterialsCartPage> createState() =>
      _BuildingMaterialsCartPageState();
}

class _BuildingMaterialsCartPageState extends State<BuildingMaterialsCartPage> {
  final TextEditingController _couponController = TextEditingController();
  int _selectedTabIndex = 2; // السلة
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dependencies = AppDependencies.maybeOf(context);
      dependencies?.buildingMaterialsCartController.loadCart();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _onBottomNavSelected(int index) {
    if (index == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = index);

    final config = BuildingMaterialsNavigationConfig.config;
    final item = config.items[index];
    context.go(item.destination);
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final controller = dependencies.buildingMaterialsCartController;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'سلة مواد البناء والتوريدات',
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
            ValueListenableBuilder<BuildingMaterialCartModel>(
              valueListenable: controller,
              builder: (context, cart, _) {
                if (cart.items.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  tooltip: 'إفراغ السلة',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('إفراغ السلة'),
                        content: const Text('هل أنت متأكد من حذف جميع المواد من السلة؟'),
                        actions: [
                          TextButton(onPressed: () => ctx.pop(false), child: const Text('إلغاء')),
                          TextButton(
                            onPressed: () => ctx.pop(true),
                            child: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await controller.clearCart();
                    }
                  },
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: BuildingMaterialsNavigationConfig.config,
          currentIndex: _selectedTabIndex,
          onTabSelected: _onBottomNavSelected,
        ),
        body: ValueListenableBuilder<BuildingMaterialCartModel>(
          valueListenable: controller,
          builder: (context, cart, _) {
            if (cart.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: AppEmptyState(
                    title: 'سلة المشتريات فارغة',
                    message: 'لم تقم بإضافة مواد بناء بعد. تصفح الأقسام واختر الكميات المطلوبة لمشروعك.',
                    action: ElevatedButton(
                      onPressed: () => context.go(RouteNames.buildingMaterials),
                      child: const Text('تصفح مواد البناء'),
                    ),
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // محدد المحافظة لحساب تكلفة الشحن الفعلي
                _buildLocationCard(controller, cart),
                const SizedBox(height: AppSpacing.md),

                // مجموعات المنتجات مقسمة حسب المورد (Marketplace)
                ...cart.itemsBySupplier.entries.map((entry) {
                  return _buildSupplierGroupCard(controller, entry.key, entry.value);
                }),
                const SizedBox(height: AppSpacing.md),

                // كود الخصم
                _buildCouponCard(controller, cart),
                const SizedBox(height: AppSpacing.md),

                // ملخص التكاليف والنقل
                _buildSummaryCard(cart),
                const SizedBox(height: AppSpacing.lg),

                // زر الانتقال إلى الدفع والإنهاء
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.slate300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.md,
                    ),
                  ),
                  onPressed: cart.hasInvalidItems
                      ? null
                      : () {
                          context.push(RouteNames.buildingMaterialsCheckout);
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        cart.hasInvalidItems
                            ? 'يرجى تصحيح الكميات المخالفة للحد الأدنى'
                            : 'متابعة إتمام الطلب والتسليم',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildingMaterialsCartController controller,
    BuildingMaterialCartModel cart,
  ) {
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
              color: AppColors.emerald50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined, color: AppColors.emerald700, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'موقع تسليم وتشوين المشروع',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                ),
                Text(
                  'تؤثر المحافظة على حساب مسافة النقل وسعة الشاحنات',
                  style: TextStyle(fontSize: 11, color: AppColors.slate500),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: cart.targetGovernorate,
            underline: const SizedBox.shrink(),
            items: _governorates.map((gov) {
              return DropdownMenuItem(
                value: gov,
                child: Text(gov, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                controller.setGovernorate(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierGroupCard(
    BuildingMaterialsCartController controller,
    String supplierId,
    List<BuildingMaterialCartItemModel> items,
  ) {
    final supplier = items.first.supplier;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس المورد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lgValue)),
              border: const Border(bottom: BorderSide(color: AppColors.slate200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.business_rounded, size: 18, color: AppColors.slate700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                  ),
                ),
                Text(
                  '${items.length} مواد',
                  style: TextStyle(fontSize: 11, color: AppColors.slate600, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // قائمة المواد
          ...items.map((item) {
            return _buildCartItemTile(controller, item);
          }),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildingMaterialsCartController controller,
    BuildingMaterialCartItemModel item,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                imageUrl: item.product.primaryImageUrl,
                width: 70,
                height: 70,
                borderRadius: AppRadii.md,
                fit: BoxFit.cover,
                fallbackIcon: Icons.broken_image,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.slate900),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'المصنع: ${item.product.brand}',
                      style: TextStyle(fontSize: 11, color: AppColors.slate500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.unitPrice.toStringAsFixed(0)} ج.م / ${item.selectedUnit.label}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald700),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.slate400, size: 20),
                onPressed: () => controller.removeFromCart(item.id),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // عداد الكمية والإجمالي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.slate300),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: () {
                            controller.updateQuantity(
                              itemId: item.id,
                              newQuantity: item.quantity - 1.0,
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)} ${item.selectedUnit.label}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: () {
                            controller.updateQuantity(
                              itemId: item.id,
                              newQuantity: item.quantity + 1.0,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '${item.totalPrice.toStringAsFixed(0)} ج.م',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slate900),
              ),
            ],
          ),

          // تنبيه الحد الأدنى للطلب
          if (item.isBelowMinOrder) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'أقل كمية مسموح بها هي ${item.product.formattedMinOrder}',
                  style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponCard(
    BuildingMaterialsCartController controller,
    BuildingMaterialCartModel cart,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: const InputDecoration(
                hintText: 'كوبون الخصم (جرب: BUILD10)',
                hintStyle: TextStyle(fontSize: 12),
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.slate800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.sm),
            ),
            onPressed: () async {
              final ok = await controller.applyCoupon(_couponController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'تم تطبيق خصم 10% بنجاح!' : 'كوبون غير صالح'),
                    backgroundColor: ok ? AppColors.emerald700 : AppColors.rose600,
                  ),
                );
              }
            },
            child: const Text('تطبيق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildingMaterialCartModel cart) {
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
            'ملخص التوريد والشحن الإنشائي',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.slate900),
          ),
          const Divider(height: 20, color: AppColors.slate200),
          _buildSummaryRow('إجمالي المواد', '${cart.subtotal.toStringAsFixed(0)} ج.م'),
          _buildSummaryRow('إجمالي الوزن التقديري', '${cart.totalWeightTons.toStringAsFixed(1)} طن'),
          _buildSummaryRow(
            'تكلفة النقل والتعتيق بالموقع',
            cart.calculatedFreight > 0 ? '${cart.calculatedFreight.toStringAsFixed(0)} ج.م' : 'تحدد بعد المعاينة',
            highlight: true,
          ),
          if (cart.discountAmount > 0)
            _buildSummaryRow(
              'الخصم المطبق (${cart.couponCode})',
              '- ${cart.discountAmount.toStringAsFixed(0)} ج.م',
              textColor: Colors.green,
            ),
          const Divider(height: 20, color: AppColors.slate200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'الإجمالي النهائي للطلب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.slate900),
                ),
              ),
              Text(
                '${cart.grandTotal.toStringAsFixed(0)} ج.م',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.emerald700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool highlight = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.slate600)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: textColor ?? (highlight ? AppColors.slate900 : AppColors.slate800),
            ),
          ),
        ],
      ),
    );
  }
}
