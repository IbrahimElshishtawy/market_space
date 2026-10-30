import 'package:flutter/material.dart';

import '../../config/navigation_item_config.dart';
import 'navigation_badge.dart';
import 'navigation_layout.dart';

class NavigationTabItem extends StatelessWidget {
  final NavigationItemConfig item;
  final bool isSelected;
  final bool isCompact;
  final int badgeCount;
  final VoidCallback onTap;

  const NavigationTabItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isCompact,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? NavigationLayout.activeColor
        : NavigationLayout.inactiveColor;

    final iconSize = NavigationLayout.getIconSize(isCompact);

    return InkWell(
      onTap: onTap,
      borderRadius: NavigationLayout.borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  size: iconSize,
                  color: color,
                ),
                NavigationBadge(count: badgeCount),
              ],
            ),
            const SizedBox(height: 2.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: NavigationLayout.getFontSize(isCompact),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: color,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 3.0),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: NavigationLayout.indicatorHeight,
              width: NavigationLayout.indicatorWidth,
              decoration: BoxDecoration(
                color: isSelected
                    ? NavigationLayout.activeColor
                    : Colors.transparent,
                borderRadius: NavigationLayout.indicatorRadius,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
