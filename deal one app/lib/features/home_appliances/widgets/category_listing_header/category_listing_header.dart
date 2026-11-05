import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import 'category_listing_header_layout.dart';

class CategoryListingHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackTap;

  const CategoryListingHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Navigation Row (Back Button Right, Title Center)
          Row(
            children: [
              const SizedBox(width: CategoryListingHeaderLayout.backButtonSize),

              // Title (Center)
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                  ),
                ),
              ),

              // Back Chevron Button (Right in RTL layout)
              InkWell(
                onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                borderRadius: AppRadii.full,
                child: Container(
                  width: CategoryListingHeaderLayout.backButtonSize,
                  height: CategoryListingHeaderLayout.backButtonSize,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    size: 20.0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4.0),

          // Subtitle (Center)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
