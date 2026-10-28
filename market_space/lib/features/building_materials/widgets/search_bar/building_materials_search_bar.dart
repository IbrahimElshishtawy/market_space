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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Filter Button (Left)
          InkWell(
            onTap: onFilterTap,
            borderRadius: AppRadii.md,
            child: Container(
              width: BuildingMaterialsSearchBarLayout.filterButtonWidth,
              height: BuildingMaterialsSearchBarLayout.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.md,
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: const Center(
                child: Icon(
                  Icons.filter_list_rounded,
                  color: AppColors.neutralLight,
                  size: 22.0,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Search Field (Right)
          Expanded(
            child: Container(
              height: BuildingMaterialsSearchBarLayout.height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.md,
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: TextField(
                onChanged: onChanged,
                onTap: onSearchTap,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.lightTextPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'أبحث عن مواد البناء "أسمنت، حديد، طوب"',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.lightTextMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.neutralLight,
                    size: 22.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 12.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
