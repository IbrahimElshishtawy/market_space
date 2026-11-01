import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_header_data.dart';
import 'home_header_layout.dart';

class HomeHeader extends StatelessWidget {
  final HomeHeaderData data;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationsTap;

  const HomeHeader({
    super.key,
    required this.data,
    this.onAvatarTap,
    this.onCartTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: HomeHeaderLayout.padding(context),
      child: Row(
        children: [
          // Action Button (Notifications only) on the left (RTL)
          _buildActionButton(
            context: context,
            icon: Icons.notifications_rounded,
            onTap: onNotificationsTap,
            badgeCount: data.unreadNotificationsCount,
            showBadgeDot: true,
          ),

          const SizedBox(width: 8.0),

          // App Branding (Deal One) + Location on the right (RTL)
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.appName,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        data.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    Icon(
                      Icons.location_on_outlined,
                      size: 13.0,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
    int badgeCount = 0,
    bool showBadgeDot = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HomeHeaderLayout.actionButtonRadius),
      child: Container(
        width: HomeHeaderLayout.actionButtonSize,
        height: HomeHeaderLayout.actionButtonSize,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(
            HomeHeaderLayout.actionButtonRadius,
          ),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: HomeHeaderLayout.iconSize,
              color: isDark ? AppColors.darkIconPrimary : AppColors.neutral,
            ),
            if (showBadgeDot && badgeCount > 0)
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
