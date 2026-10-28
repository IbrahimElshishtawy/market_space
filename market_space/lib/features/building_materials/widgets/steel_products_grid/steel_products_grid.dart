import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/steel_rebar_product_model.dart';
import 'steel_brand_card.dart';
import 'steel_products_grid_layout.dart';

class SteelProductsGrid extends StatelessWidget {
  final List<SteelRebarProductModel> products;
  final ValueChanged<SteelRebarProductModel>? onProductTap;
  final ValueChanged<SteelRebarProductModel>? onOrderTap;
  final VoidCallback? onViewAllTap;

  const SteelProductsGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onOrderTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Right "المنتجات المتاحة", Left "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المنتجات المتاحة',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(4.0),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2x2 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: SteelProductsGridLayout.cardHeight,
              crossAxisSpacing: SteelProductsGridLayout.crossAxisSpacing,
              mainAxisSpacing: SteelProductsGridLayout.mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              final prod = products[index];
              return SteelBrandCard(
                product: prod,
                onTap: () => onProductTap?.call(prod),
                onOrderTap: () => onOrderTap?.call(prod),
              );
            },
          ),
        ],
      ),
    );
  }
}
