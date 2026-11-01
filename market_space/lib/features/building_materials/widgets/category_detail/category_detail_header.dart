import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CategoryDetailHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackTap;

  const CategoryDetailHeader({
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Title & Subtitle
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          // Right Back Button (RTL Back Arrow pointing right `>`)
          Positioned(
            right: 0,
            child: SizedBox(
              width: 38.0,
              height: 38.0,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onBackTap ?? () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20.0,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
