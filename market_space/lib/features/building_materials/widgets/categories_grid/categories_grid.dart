import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/building_material_category_model.dart';
import 'categories_grid_layout.dart';
import 'category_tile.dart';

class CategoriesGrid extends StatelessWidget {
  final List<BuildingMaterialCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<BuildingMaterialCategoryModel>? onCategoryTap;
  final VoidCallback? onViewAllTap;

  const CategoriesGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategoryTap,
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
          // Section Header: Right "أقسام مواد البناء", Left "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أقسام مواد البناء',
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

          // Grid 2x3
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: CategoriesGridLayout.itemHeight,
              crossAxisSpacing: CategoriesGridLayout.crossAxisSpacing,
              mainAxisSpacing: CategoriesGridLayout.mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return CategoryTile(
                category: cat,
                isSelected: cat.id == selectedCategoryId,
                onTap: () => onCategoryTap?.call(cat),
              );
            },
          ),
        ],
      ),
    );
  }
}
