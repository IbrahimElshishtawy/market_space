import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';

class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<String> onSelected;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return InkWell(
          onTap: () => onSelected(option),
          borderRadius: AppRadii.md,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.neutral.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: AppRadii.md,
              border: Border.all(
                color: isSelected ? AppColors.neutral : AppColors.lightBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 3.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.neutral : AppColors.neutralLight,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
