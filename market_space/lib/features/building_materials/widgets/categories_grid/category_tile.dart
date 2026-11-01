import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../data/models/building_material_category_model.dart';
import 'categories_grid_layout.dart';

class CategoryTile extends StatelessWidget {
  final BuildingMaterialCategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryTile({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: CategoriesGridLayout.itemHeight,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryTint)
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lg,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              // Title on right (Start in RTL)
              Expanded(
                child: Text(
                  category.title,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              // Icon on left (End in RTL)
              Icon(
                category.icon,
                size: 20.0,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextPrimary : AppColors.neutral),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
