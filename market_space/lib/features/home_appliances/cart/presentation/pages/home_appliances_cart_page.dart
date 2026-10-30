import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import 'package:market_space/core/routing/route_names.dart';
import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/features/home_appliances/cart/presentation/controllers/home_appliances_cart_controller.dart';
import 'package:market_space/features/home_appliances/cart/presentation/widgets/cart_item_card.dart';
import 'package:market_space/features/home_appliances/navigation/home_appliances_navigation_config.dart';
import 'package:market_space/shared/widgets/app_empty_state.dart';
import 'package:market_space/shared/widgets/app_error_view.dart';
import 'package:market_space/shared/widgets/app_loading_indicator.dart';

class HomeAppliancesCartPage extends StatefulWidget {
  final HomeAppliancesCartController? controller;

  const HomeAppliancesCartPage({super.key, this.controller});

  @override
  State<HomeAppliancesCartPage> createState() => _HomeAppliancesCartPageState();
}

class _HomeAppliancesCartPageState extends State<HomeAppliancesCartPage> {
  late final HomeAppliancesCartController _controller;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomeAppliancesCartController();
    _controller.loadCart();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final success = await _controller.applyCoupon(code);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تطبيق خصم الكوبون بنجاح!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _proceedToCheckout() {
    if (GoRouter.maybeOf(context) != null) {
      context.push('/home-appliances/checkout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('سلة تسوق الأجهزة'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppColors.neutral,
          actions: [
            TextButton(
              onPressed: _controller.clearCart,
              child: const Text(
                'إفراغ',
                style: TextStyle(color: Colors.redAccent, fontSize: 12.0),
              ),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<HomeAppliancesCartState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return Center(
                  child: AppErrorView(
                    message: state.errorMessage!,
                    onRetry: _controller.loadCart,
                  ),
                );
              }

              final cart = state.cart;

              if (cart.items.isEmpty) {
                return const Center(
                  child: AppEmptyState(
                    title: 'سلة التسوق فارغة',
                    message: 'تصفح قسم الأجهزة المنزلية وأضف المنتجات التي ترغب بشرائها إلى السلة',
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.neutral,
                onRefresh: _controller.loadCart,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8.0),

                      // Cart Items List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return CartItemCard(
                            item: item,
                            onQuantityChanged: (qty) =>
                                _controller.updateQuantity(item.id, qty),
                            onRemoveTap: () =>
                                _controller.removeFromCart(item.id),
                          );
                        },
                      ),

                      const SizedBox(height: 10.0),

                      // Coupon Promo Code Input Box
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.lg,
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'هل لديك كوبون خصم؟ (جرّب MARKET500)',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _couponController,
                                    decoration: const InputDecoration(
                                      hintText: 'أدخل كود الكوبون...',
                                      border: OutlineInputBorder(
                                        borderRadius: AppRadii.md,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 8.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                ElevatedButton(
                                  onPressed: _applyCoupon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neutral,
                                    foregroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadii.md,
                                    ),
                                  ),
                                  child: const Text('تطبيق'),
                                ),
                              ],
                            ),
                            if (state.couponErrorMessage != null) ...[
                              const SizedBox(height: 6.0),
                              Text(
                                state.couponErrorMessage!,
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 10.0),

                      // Order Summary Pricing Breakdown Box
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.lg,
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ملخص الطلب والحساب',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            _buildSummaryRow(
                              'المجموع الفرعي',
                              '${cart.subtotal.toStringAsFixed(0)} ج.م',
                            ),
                            const SizedBox(height: 6.0),
                            _buildSummaryRow(
                              'مصاريف الشحن والتوصيل',
                              '${cart.shippingFee.toStringAsFixed(0)} ج.م',
                            ),
                            if (cart.discountAmount > 0) ...[
                              const SizedBox(height: 6.0),
                              _buildSummaryRow(
                                'خصم الكوبون (${cart.appliedCouponCode})',
                                '-${cart.discountAmount.toStringAsFixed(0)} ج.م',
                                isDiscount: true,
                              ),
                            ],
                            const Divider(height: 20.0),
                            _buildSummaryRow(
                              'الإجمالي النهائي',
                              '${cart.grandTotal.toStringAsFixed(0)} ج.م',
                              isTotal: true,
                            ),
                            const SizedBox(height: 16.0),

                            // Checkout CTA
                            SizedBox(
                              width: double.infinity,
                              height: 44.0,
                              child: ElevatedButton(
                                onPressed: _proceedToCheckout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neutral,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadii.md,
                                  ),
                                  elevation: 2.0,
                                ),
                                child: const Text(
                                  'متابعة إتمام الطلب الشراء',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 90.0),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: HomeAppliancesNavigationConfig.config,
          currentIndex: 2, // 3rd tab is "السلة"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.homeAppliances);
            } else if (index == 1 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/categories');
            } else if (index == 3 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/orders');
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

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14.0 : 12.0,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppColors.secondary : AppColors.neutral,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15.0 : 12.5,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            color: isDiscount ? AppColors.secondary : AppColors.neutral,
          ),
        ),
      ],
    );
  }
}
