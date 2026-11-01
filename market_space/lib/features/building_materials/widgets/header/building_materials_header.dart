import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import 'building_materials_header_layout.dart';

class BuildingMaterialsHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final String avatarUrl;
  final int unreadNotificationsCount;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationsTap;

  const BuildingMaterialsHeader({
    super.key,
    this.userName = 'مصطفي هيكل',
    this.userLocation = 'الغربية - طنطا',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    this.unreadNotificationsCount = 1,
    this.onAvatarTap,
    this.onCartTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Right User Info: Name, Location, Avatar (Start in RTL)
          InkWell(
            onTap: onAvatarTap,
            borderRadius: AppRadii.full,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: AppRadii.full,
                  child: SafeNetworkImage(
                    imageUrl: avatarUrl,
                    width: BuildingMaterialsHeaderLayout.avatarSize,
                    height: BuildingMaterialsHeaderLayout.avatarSize,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14.0,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          userLocation,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Left Action Buttons: Notifications & Cart (End in RTL)
          _buildActionButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: unreadNotificationsCount,
            onTap: onNotificationsTap,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildActionButton(
            icon: Icons.shopping_basket_outlined,
            onTap: onCartTap,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    int badgeCount = 0,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: BuildingMaterialsHeaderLayout.actionButtonSize,
          height: BuildingMaterialsHeaderLayout.actionButtonSize,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: AppRadii.md,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            icon: Icon(
              icon,
              size: BuildingMaterialsHeaderLayout.actionIconSize,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Container(
              width: 9.0,
              height: 9.0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
