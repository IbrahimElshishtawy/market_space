import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import 'real_estate_search_bar_layout.dart';

class RealEstateSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const RealEstateSearchBar({
    super.key,
    this.hintText = 'أبحث عن عقار للبيع أو الإيجار...',
    this.onChanged,
    this.onFilterTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RealEstateSearchBarLayout.padding(context),
      child: Container(
        height: RealEstateSearchBarLayout.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.lg,
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Filter icon button on the left (or end in RTL)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onFilterTap,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    size: 20.0,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ),

            // Vertical divider
            Container(width: 1.0, height: 20.0, color: AppColors.lightBorder),

            // Search text input
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 13.0,
                    color: AppColors.lightTextMuted,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 13.0,
                  ),
                ),
              ),
            ),

            // Search & Sparkle icon on right
            const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 22.0,
                    color: AppColors.neutral,
                  ),
                  SizedBox(width: 2.0),
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13.0,
                    color: AppColors.neutral,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
