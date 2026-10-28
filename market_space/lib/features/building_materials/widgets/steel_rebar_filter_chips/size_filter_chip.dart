import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import 'steel_rebar_filter_chips_layout.dart';

class SizeFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const SizeFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.lg,
      child: Container(
        height: SteelRebarFilterChipsLayout.chipHeight,
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
            if (!isSelected && label != 'الكل') ...[
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16.0,
                color: AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4.0),
            ],
            Text(
              label,
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
  }
}
