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
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const Flexible(
                child: Text(
                  'الأقسام الرئيسية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // 2x2 Grid of Category Cards
          if (categories.length >= 4)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MainCategoryCard(
                        category: categories[1], // Home Appliances
                        onTap: () => onCategoryTap?.call(categories[1]),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: MainCategoryCard(
                        category: categories[0], // Real Estate
                        onTap: () => onCategoryTap?.call(categories[0]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: MainCategoryCard(
                        category: categories[2], // Home Services
                        onTap: () => onCategoryTap?.call(categories[2]),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: MainCategoryCard(
                        category: categories[3], // Building Materials
                        onTap: () => onCategoryTap?.call(categories[3]),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: MainCategoryCard(
                    category: cat,
                    onTap: () => onCategoryTap?.call(cat),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
