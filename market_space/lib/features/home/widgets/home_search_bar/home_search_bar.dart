import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_search_bar_layout.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSearchTap;
  final String hintText;

  const HomeSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onSearchTap,
    this.hintText = 'أبحث عن عقار، خدمة صيانة...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: HomeSearchBarLayout.padding(context),
      child: Container(
        height: HomeSearchBarLayout.height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(HomeSearchBarLayout.cornerRadius),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Filter Icon Button on Left (RTL)
            InkWell(
              onTap: onFilterTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(HomeSearchBarLayout.cornerRadius),
                bottomRight: Radius.circular(HomeSearchBarLayout.cornerRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Icon(
                  Icons.filter_list_rounded,
                  size: 22.0,
                  color: isDark ? AppColors.darkIconPrimary : AppColors.neutral,
                ),
              ),
            ),

            // Search TextField
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 13.0,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // Search Icon on Right (RTL)
            InkWell(
              onTap: onSearchTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(HomeSearchBarLayout.cornerRadius),
                bottomLeft: Radius.circular(HomeSearchBarLayout.cornerRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 22.0,
                      color: isDark
                          ? AppColors.darkIconPrimary
                          : AppColors.neutral,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
