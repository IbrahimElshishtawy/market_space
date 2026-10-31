import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_network_image.dart';

import '../controllers/fashion_cart_controller.dart';

class FashionCartPage extends StatefulWidget {
  final FashionCartController cartController;

  const FashionCartPage({
    super.key,
    required this.cartController,
  });

  @override
  State<FashionCartPage> createState() => _FashionCartPageState();
}

class _FashionCartPageState extends State<FashionCartPage> {
  final TextEditingController _promoController = TextEditingController();
  bool _promoApplied = false;
  double _promoDiscount = 0.0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'FASHION20' || code == 'SALE20') {
      setState(() {
        _promoApplied = true;
        _promoDiscount = widget.cartController.value.subtotal * 0.20;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تطبيق كود الخصم بنجاح! خصم %20'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كود الخصم غير صحيح. جرب كود FASHION20'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _checkout() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final total = widget.cartController.value.grandTotal - _promoDiscount;
        return Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
              const SizedBox(height: 12),
              const Text(
                'تأكيد طلب الشراء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'إجمالي المبلغ المطلوب دفعه: ${total.toStringAsFixed(0)} ج.م\nالدفع عند الاستلام مع إمكانية المعاينة قبل الدفع.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.cartController.clearCart();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تأكيد طلبك بنجاح! رقم الشحنة #FSH-9281'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('تأكيد الطلب الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حقيبة التسوق', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'تفريغ السلة',
            onPressed: () {
              if (widget.cartController.value.items.isNotEmpty) {
                widget.cartController.clearCart();
                setState(() {
                  _promoApplied = false;
                  _promoDiscount = 0.0;
                });
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<FashionCartState>(
        valueListenable: widget.cartController,
        builder: (context, state, child) {
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'حقيبة التسوق فارغة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تصفح أحدث صيحات الموضة وأضف ما يعجبك إلى السلة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.checkroom_outlined),
                      label: const Text('تصفح قسم الأزياء'),
                    ),
                  ],
                ),
              ),
            );
          }

          final finalTotal = (state.grandTotal - _promoDiscount).clamp(0.0, double.infinity);

          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.items.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Container(
                      padding: const EdgeInsetsDirectional.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          AppNetworkImage(
                            imageUrl: item.product.images.first,
                            width: 80,
                            height: 95,
                            borderRadius: BorderRadius.circular(10),
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.checkroom,
                          ),
                          const SizedBox(width: 12),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 18),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => widget.cartController.removeItem(item.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('المقاس: ${item.selectedSize}', style: const TextStyle(fontSize: 11)),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('اللون: ${item.selectedColor}', style: const TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.totalPrice.toStringAsFixed(0)} ج.م',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    // Stepper
                                    Container(
                                      height: 32,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () => widget.cartController.updateQuantity(item.id, item.quantity - 1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              child: Icon(Icons.remove, size: 16),
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          InkWell(
                                            onTap: () => widget.cartController.updateQuantity(item.id, item.quantity + 1),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Promo Code Box
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: 'أدخل كود الخصم (مثال: FASHION20)',
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _applyPromo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('تطبيق'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Order Summary Card
                Container(
                  padding: const EdgeInsetsDirectional.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ملخص الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      _buildSummaryRow('مجموع المنتجات (${state.totalItems} قطع)', '${state.subtotal.toStringAsFixed(0)} ج.م'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'مصاريف الشحن والتوصيل',
                        state.shippingFee == 0 ? 'مجاني' : '${state.shippingFee.toStringAsFixed(0)} ج.م',
                        isHighlight: state.shippingFee == 0,
                      ),
                      if (_promoApplied) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'خصم الكوبون (%20)',
                          '- ${_promoDiscount.toStringAsFixed(0)} ج.م',
                          isDiscount: true,
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الإجمالي النهائي:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${finalTotal.toStringAsFixed(0)} ج.م',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checkout,
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text('متابعة الدفع والشحن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false, bool isDiscount = false}) {
    Color? textColor;
    if (isHighlight) textColor = Colors.green.shade700;
    if (isDiscount) textColor = Colors.red.shade700;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
