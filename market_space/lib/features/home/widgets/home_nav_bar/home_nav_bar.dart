import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_utils.dart';
import '../../data/mock/mock_home_data.dart';
import '../../data/models/home_nav_item_data.dart';
import 'home_nav_bar_item.dart';
import 'home_nav_bar_layout.dart';

class HomeNavBar extends StatelessWidget {
  final List<HomeNavItemData> items;
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final bool isVisible;

  const HomeNavBar({
    super.key,
    this.items = MockHomeData.navItems,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactPhone;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      offset: isVisible ? Offset.zero : const Offset(0, 1.8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: isVisible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.only(
            left: HomeNavBarLayout.horizontalMargin,
            right: HomeNavBarLayout.horizontalMargin,
            bottom: HomeNavBarLayout.bottomMargin,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: HomeNavBarLayout.backgroundColor,
              borderRadius: HomeNavBarLayout.borderRadius,
              boxShadow: HomeNavBarLayout.containerShadow,
              border: HomeNavBarLayout.containerBorder,
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: HomeNavBarLayout.getBarHeight(isCompact),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    return Expanded(
                      child: HomeNavBarItem(
                        data: item,
                        isSelected: currentIndex == index,
                        isCompact: isCompact,
                        onTap: () => onIndexChanged?.call(index),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
