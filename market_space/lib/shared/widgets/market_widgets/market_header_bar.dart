import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class MarketHeaderBar extends StatelessWidget {
  final String selectedCity;
  final VoidCallback? onCityTap;
  final VoidCallback? onNotificationsTap;

  const MarketHeaderBar({
    super.key,
    this.selectedCity = 'الرياض / دبي',
    this.onCityTap,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompactPhone;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalScreenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Brand Logo & Name
          Expanded(child: _buildBrand(context, isCompact)),

          const SizedBox(width: AppSpacing.xs),

          // City selector dropdown
          _buildCitySelector(context, isCompact),

          const SizedBox(width: AppSpacing.xs),

          // Notification icon with unread badge
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildBrand(BuildContext context, bool isCompact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCompact ? 34.0 : 38.0,
          height: isCompact ? 34.0 : 38.0,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: const Center(
            child: Text(
              'ب',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
                fontFamily: 'sans-serif',
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'بازار جو',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: isCompact ? 16.0 : 18.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 1.0),
              Text(
                'عقارات • تشطيب ومُوَن • خدمات',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: isCompact ? 9.0 : 10.5,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCitySelector(BuildContext context, bool isCompact) {
    return InkWell(
      onTap: onCityTap,
      borderRadius: AppRadii.full,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8.0 : 10.0,
          vertical: 5.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: AppRadii.full,
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15.0,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4.0),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isCompact ? 75.0 : 95.0,
              ),
              child: Text(
                selectedCity,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: isCompact ? 11.0 : 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 2.0),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16.0,
              color: AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.lightTextPrimary,
            size: 24.0,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 38.0, minHeight: 38.0),
          visualDensity: VisualDensity.compact,
        ),
        Positioned(
          top: 6.0,
          right: 6.0,
          child: Container(
            width: 8.5,
            height: 8.5,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
