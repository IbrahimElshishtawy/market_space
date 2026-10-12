import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/utils/responsive_utils.dart';

class MarketBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onAddListingTap;

  const MarketBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
    this.onAddListingTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactPhone;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10.0,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.lightBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: isCompact ? 60.0 : 66.0,
          child: Row(
            children: [
              // 1. الرئيسية (Home)
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  isCompact: isCompact,
                ),
              ),

              // 2. جولات فيديو (Video Tours)
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.play_circle_outline_rounded,
                  label: 'جولات فيديو',
                  isCompact: isCompact,
                  hasLiveDot: true,
                ),
              ),

              // 3. Center Action (+ أضف إعلانك)
              Expanded(
                child: _buildCenterAddButton(isCompact),
              ),

              // 4. الرسائل (Messages with badge)
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.chat_outlined,
                  label: 'الرسائل',
                  isCompact: isCompact,
                  badgeCount: 2,
                ),
              ),

              // 5. حسابي (Profile)
              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  label: 'حسابي',
                  isCompact: isCompact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isCompact,
    bool hasLiveDot = false,
    int? badgeCount,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: () => onIndexChanged?.call(index),
      borderRadius: AppRadii.md,
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
                  icon,
                  size: isCompact ? 22.0 : 25.0,
                  color: color,
                ),
                if (hasLiveDot)
                  Positioned(
                    top: -1,
                    right: -2,
                    child: Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (badgeCount != null)
                  Positioned(
                    top: -4,
                    right: -7,
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      constraints: const BoxConstraints(minWidth: 15.0, minHeight: 15.0),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 10.0 : 11.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(bool isCompact) {
    return InkWell(
      onTap: onAddListingTap,
      borderRadius: AppRadii.full,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isCompact ? 36.0 : 42.0,
            height: isCompact ? 36.0 : 42.0,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: isCompact ? 22.0 : 26.0,
            ),
          ),
          const SizedBox(height: 2.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'أضف إعلانك',
              style: TextStyle(
                fontSize: isCompact ? 9.0 : 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
