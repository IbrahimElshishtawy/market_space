import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../data/models/appliance_category_model.dart';

class AppliancesCategoryCard extends StatelessWidget {
  final ApplianceCategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppliancesCategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                ? AppColors.darkPrimary.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.08))
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: AppRadii.md,
        border: Border.all(
          color: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.iconData,
                  size: 20.0,
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.neutral),
                ),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w700,
                      color: isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.neutral),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
