import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../models/home_feed_models.dart';

class ServiceProviderCard extends StatelessWidget {
  final ServiceProviderItem item;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;

  const ServiceProviderCard({
    super.key,
    required this.item,
    this.onActionTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactPhone;
    final horizontalPadding = context.horizontalScreenPadding;

    final (icon, iconColor, bgColor) = _resolveCategoryVisuals(item.categoryKey);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.xs + 1,
      ),
      padding: EdgeInsets.all(isCompact ? 10.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Action button (Left side in RTL)
            InkWell(
              onTap: onActionTap,
              borderRadius: AppRadii.md,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10.0 : 14.0,
                  vertical: isCompact ? 7.0 : 8.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: AppRadii.md,
                ),
                child: Text(
                  item.actionLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 10.5 : 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + verified check
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isCompact ? 12.0 : 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      if (item.isVerified) ...[
                        const SizedBox(width: 3.0),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14.0,
                          color: AppColors.secondary,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 2.0),

                  // Subtitle
                  Text(
                    item.serviceDesc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isCompact ? 10.0 : 11.0,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 5.0),

                  // Rating + Perk text
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14.0,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        '${item.rating} (${item.reviewsCount} تقييم)',
                        style: TextStyle(
                          fontSize: isCompact ? 9.5 : 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Text(
                        '• ${item.perkText}',
                        style: TextStyle(
                          fontSize: isCompact ? 9.5 : 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Visual Category Icon on Right
            Container(
              width: isCompact ? 42.0 : 48.0,
              height: isCompact ? 42.0 : 48.0,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: AppRadii.md,
              ),
              child: Icon(
                icon,
                size: isCompact ? 22.0 : 26.0,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color, Color) _resolveCategoryVisuals(String categoryKey) {
    switch (categoryKey) {
      case 'finishing':
        return (
          Icons.format_paint_rounded,
          AppColors.primary,
          AppColors.primaryTint,
        );
      case 'plumbing':
        return (
          Icons.plumbing_rounded,
          AppColors.secondary,
          AppColors.secondaryTint,
        );
      case 'moving':
        return (
          Icons.local_shipping_rounded,
          AppColors.info,
          AppColors.infoTint,
        );
      default:
        return (
          Icons.handyman_rounded,
          AppColors.tertiary,
          AppColors.tertiaryTint,
        );
    }
  }
}
