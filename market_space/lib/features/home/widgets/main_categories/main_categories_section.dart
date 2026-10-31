import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_category_data.dart';
import 'main_categories_layout.dart';
import 'main_category_card.dart';

class MainCategoriesSection extends StatelessWidget {
  final List<HomeCategoryData> categories;
  final ValueChanged<HomeCategoryData>? onCategoryTap;
  final VoidCallback? onViewAllTap;

  const MainCategoriesSection({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: MainCategoriesLayout.padding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(4.0),
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  'الأقسام الرئيسية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Dynamic Grid of Category Cards (2 per row)
          Column(
            children: [
              for (int i = 0; i < categories.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: MainCategoryCard(
                        category: categories[i],
                        onTap: () => onCategoryTap?.call(categories[i]),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    if (i + 1 < categories.length)
                      Expanded(
                        child: MainCategoryCard(
                          category: categories[i + 1],
                          onTap: () => onCategoryTap?.call(categories[i + 1]),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
