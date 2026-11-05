import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import 'building_materials_search_bar_layout.dart';

class BuildingMaterialsSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSearchTap;

  const BuildingMaterialsSearchBar({
    super.key,
    this.onChanged,
    this.onFilterTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Search Field (Right in RTL)
          Expanded(
            child: Container(
              height: BuildingMaterialsSearchBarLayout.height,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: AppRadii.md,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: TextField(
                onChanged: onChanged,
                onTap: onSearchTap,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'أبحث عن مواد البناء "أسمنت، حديد، طوب"',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.neutralLight,
                    size: 22.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Filter Button (Left in RTL)
          InkWell(
            onTap: onFilterTap,
            borderRadius: AppRadii.md,
            child: Container(
              width: BuildingMaterialsSearchBarLayout.filterButtonWidth,
              height: BuildingMaterialsSearchBarLayout.height,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: AppRadii.md,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.filter_alt_outlined,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
