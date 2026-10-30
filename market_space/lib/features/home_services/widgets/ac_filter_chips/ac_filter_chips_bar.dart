import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'ac_filter_chips_layout.dart';

class AcFilterChipsBar extends StatelessWidget {
  final List<String> chips;
  final String selectedChip;
  final ValueChanged<String>? onChipSelected;

  const AcFilterChipsBar({
    super.key,
    required this.chips,
    this.selectedChip = 'الكل',
    this.onChipSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AcFilterChipsLayout.chipHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AcFilterChipsLayout.paddingHorizontal,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AcFilterChipsLayout.horizontalSpacing),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final isSelected = chip == selectedChip;
          final hasDropdown = chip != 'الكل';

          return InkWell(
            onTap: () => onChipSelected?.call(chip),
            borderRadius: BorderRadius.circular(
              AcFilterChipsLayout.borderRadius,
            ),
            child: Container(
              height: AcFilterChipsLayout.chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neutral : Colors.white,
                borderRadius: BorderRadius.circular(
                  AcFilterChipsLayout.borderRadius,
                ),
                border: Border.all(
                  color: isSelected ? AppColors.neutral : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chip,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (hasDropdown) ...[
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.0,
                      color: isSelected
                          ? Colors.white
                          : AppColors.lightTextSecondary,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
