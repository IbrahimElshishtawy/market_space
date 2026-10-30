import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/core/theme/app_spacing.dart';
import 'package:market_space/features/home_appliances/cart/presentation/controllers/home_appliances_cart_controller.dart';
import 'package:market_space/features/home_appliances/orders/data/models/appliance_order_model.dart';
import 'package:market_space/features/home_appliances/orders/presentation/controllers/home_appliances_order_controller.dart';

class HomeAppliancesCheckoutPage extends StatefulWidget {
  const HomeAppliancesCheckoutPage({super.key});

  @override
  State<HomeAppliancesCheckoutPage> createState() =>
      _HomeAppliancesCheckoutPageState();
}

class _HomeAppliancesCheckoutPageState
    extends State<HomeAppliancesCheckoutPage> {
  String _selectedPaymentMethod = 'الدفع عند الاستلام';
  final String _selectedAddress = 'طنطا، شارع النادي - برج الاستاد - الشقة 501';
  bool _isSubmitting = false;

  void _placeOrder(
    HomeAppliancesCartController cartController,
    HomeAppliancesOrderController orderController,
  ) async {
    setState(() => _isSubmitting = true);

    final cart = cartController.value.cart;

    final orderItems = cart.items.map((item) {
      return ApplianceOrderItemModel(
        id: item.id,
        title: item.product.title,
        brandName: item.product.brandName,
        imageUrl: item.product.imageUrl,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      );
    }).toList();

    final order = ApplianceOrderModel(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'HA-${1000 + DateTime.now().second * 12}',
      userId: 'user-1',
      items: orderItems,
      status: ApplianceOrderStatus.confirmed,
      subtotal: cart.subtotal,
      shippingFee: cart.shippingFee,
      discountAmount: cart.discountAmount,
      grandTotal: cart.grandTotal,
      paymentMethod: _selectedPaymentMethod,
      deliveryAddress: _selectedAddress,
      createdAt: DateTime.now(),
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
    );

    await orderController.placeOrder(order);
    await cartController.clearCart();

    if (mounted) {
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إنشاء الطلب بنجاح! رقم الطلب: ${order.orderNumber}',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      if (GoRouter.maybeOf(context) != null) {
        context.go('/home-appliances/orders');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);
    final cartController = HomeAppliancesCartController(
      repository: dependencies?.mockDataProvider != null ? null : null,
    );
    final orderController = HomeAppliancesOrderController(
      repository: dependencies?.mockDataProvider != null ? null : null,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('إتمام الشراء'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppColors.neutral,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Delivery Address Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'عنوان الشحن والتوصيل',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.lightTextSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // 2. Payment Method Selector Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.lg,
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payment_rounded, color: AppColors.primary),
                        SizedBox(width: 8.0),
                        Text(
                          'اختر طريقة الدفع المناسبة',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    RadioListTile<String>(
                      title: const Text('الدفع كاش عند الاستلام'),
                      subtitle: const Text(
                        'ادفع نقدًا فور وصول الشحنة وباب المنزل',
                      ),
                      value: 'الدفع عند الاستلام',
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      onChanged: (val) =>
                          setState(() => _selectedPaymentMethod = val!),
                    ),
                    RadioListTile<String>(
                      title: const Text('بطاقة ائتمان / خصم مباشر'),
                      subtitle: const Text(
                        'دفع أونلاين آمن عبر الفيزا أو الماستركارد',
                      ),
                      value: 'بطاقة ائتمان',
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      onChanged: (val) =>
                          setState(() => _selectedPaymentMethod = val!),
                    ),
                    RadioListTile<String>(
                      title: const Text('تقسيط أجهزة على 12 شهر'),
                      subtitle: const Text(
                        'برنامج التقسيط الميسر بدون فوائد مع البنوك المعتمدة',
                      ),
                      value: 'تقسيط ميسر',
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      onChanged: (val) =>
                          setState(() => _selectedPaymentMethod = val!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // Confirm Order CTA Button
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _placeOrder(cartController, orderController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.md,
                    ),
                    elevation: 3.0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'تأكيد الطلب والشراء الآن',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
