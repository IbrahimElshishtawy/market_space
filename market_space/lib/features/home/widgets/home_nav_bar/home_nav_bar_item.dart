import 'package:flutter/material.dart';

import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/home_nav_item_data.dart';
import 'home_nav_bar_layout.dart';

class HomeNavBarItem extends StatelessWidget {
  final HomeNavItemData data;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  const HomeNavBarItem({
    super.key,
    required this.data,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? HomeNavBarLayout.activeColor
        : HomeNavBarLayout.inactiveColor;

    final iconSize = HomeNavBarLayout.getIconSize(isCompact);

    return InkWell(
      onTap: onTap,
      borderRadius: HomeNavBarLayout.borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (data.avatarUrl != null)
              Container(
                width: iconSize + 2.0,
                height: iconSize + 2.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular((iconSize + 2.0) / 2),
                  child: SafeNetworkImage(
                    imageUrl: data.avatarUrl!,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                    fallbackIcon: isSelected ? data.activeIcon : data.icon,
                  ),
                ),
              )
            else
              Icon(
                isSelected ? data.activeIcon : data.icon,
                size: iconSize,
                color: color,
              ),
            const SizedBox(height: 2.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.label,
                style: TextStyle(
                  fontSize: HomeNavBarLayout.getFontSize(isCompact),
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
              height: HomeNavBarLayout.indicatorHeight,
              width: HomeNavBarLayout.indicatorWidth,
              decoration: BoxDecoration(
                color: isSelected
                    ? HomeNavBarLayout.activeColor
                    : Colors.transparent,
                borderRadius: HomeNavBarLayout.indicatorRadius,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
