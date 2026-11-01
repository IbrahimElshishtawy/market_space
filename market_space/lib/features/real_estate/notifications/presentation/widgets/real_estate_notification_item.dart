import 'package:flutter/material.dart';

import 'package:market_space/core/notifications/data/models/app_notification.dart';
import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';

class RealEstateNotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDeleteTap;

  const RealEstateNotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark
                ? AppColors.darkSurfaceSecondary
                : AppColors.primary.withValues(alpha: 0.05))
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: AppRadii.md,
        border: Border.all(
          color: isUnread
              ? (isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.3))
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.md,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.md,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Category Badge
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightBackground),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnread
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: 20.0,
                    color: isUnread
                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Text Payload Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.neutral,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimestamp(notification.createdAt),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isUnread
                                  ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          InkWell(
                            onTap: onDeleteTap,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 2.0,
                              ),
                              child: Text(
                                'حذف',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}
