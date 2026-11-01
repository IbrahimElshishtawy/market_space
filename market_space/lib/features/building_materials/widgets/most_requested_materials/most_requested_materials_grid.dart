import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/building_material_product_model.dart';
import 'material_card.dart';
import 'most_requested_materials_layout.dart';

class MostRequestedMaterialsGrid extends StatelessWidget {
  final List<BuildingMaterialProductModel> products;
  final ValueChanged<BuildingMaterialProductModel>? onProductTap;
  final ValueChanged<BuildingMaterialProductModel>? onOrderTap;
  final VoidCallback? onViewAllTap;

  const MostRequestedMaterialsGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onOrderTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Right "الخامات الأكثر طلباً", Left "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الخامات الأكثر طلباً',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(4.0),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2x2 Product Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: MostRequestedMaterialsLayout.cardHeight,
              crossAxisSpacing: MostRequestedMaterialsLayout.crossAxisSpacing,
              mainAxisSpacing: MostRequestedMaterialsLayout.mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              final prod = products[index];
              return MaterialCard(
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
