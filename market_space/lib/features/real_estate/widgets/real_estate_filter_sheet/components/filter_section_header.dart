import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class FilterSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onSelectAll;

  const FilterSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Select All button on right (in RTL, far right is top left in visual order)
          if (onSelectAll != null)
            InkWell(
              onTap: onSelectAll,
              borderRadius: BorderRadius.circular(4.0),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Text(
                  'إختيار الكل',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextMuted,
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          // Icon and Title on left (in RTL, far right)
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(icon, size: 20.0, color: AppColors.neutral),
            ],
          ),
        ],
      ),
    );
  }
}
