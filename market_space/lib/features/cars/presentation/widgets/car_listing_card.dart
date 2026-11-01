import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/car_listing_model.dart';

class CarListingCard extends StatelessWidget {
  final CarListingModel car;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isHorizontal;

  const CarListingCard({
    super.key,
    required this.car,
    this.onTap,
    this.onFavoriteToggle,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildVerticalCard(context);
  }

  Widget _buildVerticalCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.lg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: SafeNetworkImage(
                        imageUrl: car.images.isNotEmpty ? car.images.first : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Condition Badge
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: car.condition == CarCondition.newCar ? AppColors.accent : Colors.black87,
                        borderRadius: AppRadii.sm,
                      ),
                      child: Text(
                        car.condition.titleAr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    end: AppSpacing.sm,
                    child: Material(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            car.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: car.isFavorite ? Colors.red : (isDark ? AppColors.darkTextPrimary : AppColors.neutral),
                            size: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Body Type Chip
                  PositionedDirectional(
                    bottom: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: AppRadii.xs,
                      ),
                      child: Text(
                        car.bodyType.titleAr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Car Details Section
              Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand & Model & Year
                    Text(
                      car.fullTitle,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),

                    // Price
                    Text(
                      car.formattedPrice,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Specs Row: Mileage, Transmission, Fuel
                    Row(
                      children: [
                        _buildSpecTag(
                          context: context,
                          icon: Icons.speed_rounded,
                          label: car.condition == CarCondition.newCar ? 'زيرو' : '${car.mileageKm} كم',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildSpecTag(
                          context: context,
                          icon: Icons.settings_rounded,
                          label: car.transmission.titleAr,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildSpecTag(
                          context: context,
                          icon: Icons.local_gas_station_rounded,
                          label: car.fuelType.titleAr,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Location & Action Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14.0,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  '${car.governorate}، ${car.city}',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          car.listingStatus,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
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
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280.0,
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.lg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                    child: SizedBox(
                      height: 140.0,
                      width: double.infinity,
                      child: SafeNetworkImage(
                        imageUrl: car.images.isNotEmpty ? car.images.first : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 8.0,
                    start: 8.0,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: car.condition == CarCondition.newCar ? AppColors.accent : Colors.black87,
                        borderRadius: AppRadii.xs,
                      ),
                      child: Text(
                        car.condition.titleAr,
                        style: const TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 8.0,
                    end: 8.0,
                    child: Material(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavoriteToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            car.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: car.isFavorite ? Colors.red : (isDark ? AppColors.darkTextPrimary : AppColors.neutral),
                            size: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.fullTitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      car.formattedPrice,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        _buildSpecTag(
                          context: context,
                          icon: Icons.speed_rounded,
                          label: car.condition == CarCondition.newCar ? 'زيرو' : '${car.mileageKm} كم',
                        ),
                        const SizedBox(width: 4.0),
                        _buildSpecTag(
                          context: context,
                          icon: Icons.location_on_outlined,
                          label: car.governorate,
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
    );
  }

  Widget _buildSpecTag({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightBackground,
        borderRadius: AppRadii.xs,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.0,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 3.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
