import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';

class CategoryFilterChipsBar extends StatelessWidget {
  final List<String> filterChips;
  final String selectedFilter;
  final ValueChanged<String>? onFilterSelected;

  const CategoryFilterChipsBar({
    super.key,
    required this.filterChips,
    required this.selectedFilter,
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filterChips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final chip = filterChips[index];
          final isSelected = chip == selectedFilter;

          return InkWell(
            onTap: () => onFilterSelected?.call(chip),
            borderRadius: AppRadii.lg,
            child: Container(
              height: 38.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neutral : Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(
                  color: isSelected ? AppColors.neutral : AppColors.lightBorder,
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 3.0,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSelected && chip != 'الكل') ...[
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.0,
                      color: AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4.0),
                  ],
                  Text(
                    chip,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
