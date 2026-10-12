import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_category_data.dart';
import 'main_categories_layout.dart';

class MainCategoryCard extends StatelessWidget {
  final HomeCategoryData category;
  final VoidCallback? onTap;

  const MainCategoryCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MainCategoriesLayout.borderRadius),
      child: Container(
        height: MainCategoriesLayout.cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            MainCategoriesLayout.borderRadius,
          ),
          border: Border.all(color: AppColors.lightBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Chevron icon
            const Icon(
              Icons.chevron_left_rounded,
              size: 18.0,
              color: AppColors.lightTextMuted,
            ),

            const SizedBox(width: 4.0),

            // Title in center/right with FittedBox & Expanded for scale down
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6.0),

            // Category Icon on right (RTL)
            Icon(
              category.icon,
              size: 22.0,
              color: category.iconColor ?? AppColors.neutral,
            ),
          ],
        ),
      ),
    );
  }
}
