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
    return Container(
      height: CategoriesGridLayout.itemHeight,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryTint : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.lightBorder,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon on right (RTL layout)
              Icon(
                category.icon,
                size: 20.0,
                color: isSelected ? AppColors.primary : AppColors.neutralLight,
              ),

              // Title in center/right
              Expanded(
                child: Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.lightTextPrimary,
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
