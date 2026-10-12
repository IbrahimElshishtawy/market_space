import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import 'real_estate_header_layout.dart';

class RealEstateHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final String avatarUrl;
  final bool hasUnreadNotifications;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onNotificationsTap;

  const RealEstateHeader({
    super.key,
    this.userName = 'مصطفي هيكل',
    this.userLocation = 'الغربية - طنطا',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    this.hasUnreadNotifications = true,
    this.onAvatarTap,
    this.onCartTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RealEstateHeaderLayout.padding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Avatar + User info
          InkWell(
            onTap: onAvatarTap,
            borderRadius: AppRadii.full,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeNetworkImage(
                  imageUrl: avatarUrl,
                  width: RealEstateHeaderLayout.avatarRadius * 2,
                  height: RealEstateHeaderLayout.avatarRadius * 2,
                  fit: BoxFit.cover,
                  borderRadius: AppRadii.full,
                  fallbackIcon: Icons.person_rounded,
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13.0,
                          color: AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          userLocation,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Left Side: Action icons (Cart + Notification Bell)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notification Bell Button
              _buildIconButton(
                icon: Icons.notifications_outlined,
                onTap: onNotificationsTap,
                badgeDot: hasUnreadNotifications,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              // Cart / Basket Button
              _buildIconButton(
                icon: Icons.shopping_basket_outlined,
                onTap: onCartTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    bool badgeDot = false,
  }) {
    return Container(
      width: RealEstateHeaderLayout.actionButtonSize,
      height: RealEstateHeaderLayout.actionButtonSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.md,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20.0, color: AppColors.neutral),
              if (badgeDot)
                Positioned(
                  top: 9.0,
                  right: 9.0,
                  child: Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
