import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import 'appliances_header_layout.dart';

class AppliancesHeader extends StatelessWidget {
  final String userName;
  final String userLocation;
  final String avatarUrl;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onAvatarTap;

  const AppliancesHeader({
    super.key,
    this.userName = 'مصطفي هيكل',
    this.userLocation = 'الغربية - طنطا',
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    this.notificationCount = 1,
    this.onNotificationTap,
    this.onCartTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Action Buttons: Cart & Notification (Left side in RTL layout)
          Row(
            children: [
              // Cart Icon Button
              InkWell(
                onTap: onCartTap,
                borderRadius: AppRadii.full,
                child: Container(
                  width: AppliancesHeaderLayout.iconButtonSize,
                  height: AppliancesHeaderLayout.iconButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.md,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.neutral,
                    size: 20.0,
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              // Notification Bell Button with Red Badge
              Stack(
                children: [
                  InkWell(
                    onTap: onNotificationTap,
                    borderRadius: AppRadii.full,
                    child: Container(
                      width: AppliancesHeaderLayout.iconButtonSize,
                      height: AppliancesHeaderLayout.iconButtonSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadii.md,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.neutral,
                        size: 20.0,
                      ),
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // User Info & Avatar (Right side in RTL layout)
          InkWell(
            onTap: onAvatarTap,
            borderRadius: AppRadii.full,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userLocation,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.lightTextMuted,
                          ),
                        ),
                        const SizedBox(width: 3.0),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13.0,
                          color: AppColors.lightTextMuted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 10.0),
                ClipRRect(
                  borderRadius: AppRadii.full,
                  child: SizedBox(
                    width: AppliancesHeaderLayout.avatarSize,
                    height: AppliancesHeaderLayout.avatarSize,
                    child: SafeNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.person_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
