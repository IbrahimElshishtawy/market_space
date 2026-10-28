import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/appliance_product_model.dart';
import 'appliance_product_card.dart';
import 'appliances_products_grid_layout.dart';

class AppliancesProductsGrid extends StatelessWidget {
  final List<ApplianceProductModel> products;
  final ValueChanged<String>? onProductTap;
  final ValueChanged<String>? onAddToCartTap;
  final VoidCallback? onViewAllTap;

  const AppliancesProductsGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onAddToCartTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row (الأكثر طلباً في طنطا - عرض الكل)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الأكثر طلباً في طنطا',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral,
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(4.0),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // 2-Column Products Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppliancesProductsGridLayout.crossAxisCount,
              mainAxisSpacing: AppliancesProductsGridLayout.gridSpacing,
              crossAxisSpacing: AppliancesProductsGridLayout.gridSpacing,
              childAspectRatio: AppliancesProductsGridLayout.childAspectRatio,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ApplianceProductCard(
                product: product,
                onTap: () => onProductTap?.call(product.id),
                onAddToCartTap: () => onAddToCartTap?.call(product.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
