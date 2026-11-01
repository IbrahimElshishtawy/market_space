import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/appliance_category_model.dart';
import 'appliances_category_card.dart';
import 'appliances_category_grid_layout.dart';

class AppliancesCategoryGrid extends StatelessWidget {
  final List<ApplianceCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String>? onCategoryTap;
  final VoidCallback? onViewAllTap;

  const AppliancesCategoryGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategoryTap,
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
          // Section Header Row (تصفّح حسب الفئة - عرض الكل)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفّح حسب الفئة',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.neutral,
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(4.0),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // 2-Column Grid of 8 Category Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppliancesCategoryGridLayout.crossAxisCount,
              mainAxisSpacing: AppliancesCategoryGridLayout.gridSpacing,
              crossAxisSpacing: AppliancesCategoryGridLayout.gridSpacing,
              childAspectRatio: AppliancesCategoryGridLayout.childAspectRatio,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategoryId == cat.id;

              return AppliancesCategoryCard(
                category: cat,
                isSelected: isSelected,
                onTap: () => onCategoryTap?.call(cat.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
