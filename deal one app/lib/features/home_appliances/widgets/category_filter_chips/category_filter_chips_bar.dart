import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import 'category_filter_chips_layout.dart';

class CategoryFilterChipsBar extends StatelessWidget {
  final List<String> filterChips;
  final String selectedChip;
  final ValueChanged<String>? onChipSelected;

  const CategoryFilterChipsBar({
    super.key,
    this.filterChips = const ['الكل', 'السعر ˅', 'الحجم ˅', 'الماركة ˅'],
    this.selectedChip = 'الكل',
    this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: CategoryFilterChipsLayout.chipHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: filterChips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final chip = filterChips[index];
          final isSelected = selectedChip == chip;

          return InkWell(
            onTap: () => onChipSelected?.call(chip),
            borderRadius: AppRadii.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.neutral)
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: AppRadii.md,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.neutral)
                      : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Center(
                child: Text(
                  chip,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? AppColors.darkOnPrimary : Colors.white)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.neutral),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
