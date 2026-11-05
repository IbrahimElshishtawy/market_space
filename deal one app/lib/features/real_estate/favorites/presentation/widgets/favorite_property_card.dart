import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/features/real_estate/favorites/data/models/favorite_property_model.dart';
import 'package:market_space/shared/widgets/market_widgets/safe_network_image.dart';

class FavoritePropertyCard extends StatelessWidget {
  final FavoritePropertyModel item;
  final VoidCallback onRemoveTap;
  final VoidCallback onDetailsTap;

  const FavoritePropertyCard({
    super.key,
    required this.item,
    required this.onRemoveTap,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final property = item.property;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.lg,
        child: InkWell(
          onTap: onDetailsTap,
          borderRadius: AppRadii.lg,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: AppRadii.md,
                  child: SizedBox(
                    width: 100.0,
                    height: 100.0,
                    child: SafeNetworkImage(
                      imageUrl: property.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.apartment_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Remove Favorite Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              borderRadius: AppRadii.xs,
                            ),
                            child: Text(
                              property.priceFormatted +
                                  (property.pricePeriod != null
                                      ? ' / ${property.pricePeriod}'
                                      : ''),
                              style: TextStyle(
                                color: isDark ? AppColors.darkOnPrimary : Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onRemoveTap,
                            borderRadius: BorderRadius.circular(20.0),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),

                      // Title
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 3.0),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13.0,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 2.0),
                          Expanded(
                            child: Text(
                              property.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.0,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),

                      // Specs Chips Row
                      Row(
                        children: [
                          _buildSpecBadge(context, '${property.bedsCount} غرف'),
                          const SizedBox(width: 4.0),
                          _buildSpecBadge(context, '${property.areaM2} م²'),
                          const SizedBox(width: 4.0),
                          _buildSpecBadge(context, property.finishType),
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

  Widget _buildSpecBadge(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.0,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
