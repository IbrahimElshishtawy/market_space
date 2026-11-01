import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import 'appliances_search_bar_layout.dart';

class AppliancesSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const AppliancesSearchBar({
    super.key,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'ابحث عن جهاز، ماركة، أو موديل...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        height: AppliancesSearchBarLayout.height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            // Filter Funnel Button (Left)
            InkWell(
              onTap: onFilterTap,
              borderRadius: AppRadii.md,
              child: Container(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                  size: 20.0,
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // Search TextField Input
            Expanded(
              child: TextField(
                onChanged: onChanged,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 13.0,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // Search Icon (Right)
            Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
              size: 22.0,
            ),
          ],
        ),
      ),
    );
  }
}
