import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
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
    return Padding(
      padding: HomeHeaderLayout.padding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Action Buttons (Cart & Notification) on the left (RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.shopping_basket_outlined,
                onTap: onCartTap,
                badgeCount: data.cartItemsCount,
              ),
              const SizedBox(width: 8.0),
              _buildActionButton(
                icon: Icons.notifications_rounded,
                onTap: onNotificationsTap,
                badgeCount: data.unreadNotificationsCount,
                showBadgeDot: true,
              ),
            ],
          ),

          const SizedBox(width: 8.0),

          // User Profile Info on the right (RTL)
          Flexible(
            child: InkWell(
              onTap: onAvatarTap,
              borderRadius: BorderRadius.circular(24.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                data.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2.0),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14.0,
                              color: AppColors.neutral,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      HomeHeaderLayout.avatarSize / 2,
                    ),
                    child: SizedBox(
                      width: HomeHeaderLayout.avatarSize,
                      height: HomeHeaderLayout.avatarSize,
                      child: data.avatarUrl != null
                          ? SafeNetworkImage(
                              imageUrl: data.avatarUrl!,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.person_rounded,
                            )
                          : CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onTap,
    int badgeCount = 0,
    bool showBadgeDot = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HomeHeaderLayout.actionButtonRadius),
      child: Container(
        width: HomeHeaderLayout.actionButtonSize,
        height: HomeHeaderLayout.actionButtonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            HomeHeaderLayout.actionButtonRadius,
          ),
          border: Border.all(color: AppColors.lightBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
              color: AppColors.neutral,
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
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
