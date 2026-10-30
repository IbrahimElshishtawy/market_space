import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../../data/models/real_estate_listing_model.dart';

class PropertyMapPreviewCard extends StatelessWidget {
  final RealEstateListingModel property;
  final VoidCallback onDetailsTap;
  final VoidCallback onCloseTap;

  const PropertyMapPreviewCard({
    super.key,
    required this.property,
    required this.onDetailsTap,
    required this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
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
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: AppRadii.md,
                  child: SizedBox(
                    width: 95.0,
                    height: 95.0,
                    child: SafeNetworkImage(
                      imageUrl: property.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.apartment_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Price & Close Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadii.xs,
                            ),
                            child: Text(
                              property.priceFormatted +
                                  (property.pricePeriod != null
                                      ? ' / ${property.pricePeriod}'
                                      : ''),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onCloseTap,
                            borderRadius: BorderRadius.circular(16.0),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18.0,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),

                      // Title
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 2.0),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13.0,
                            color: AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 2.0),
                          Expanded(
                            child: Text(
                              property.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),

                      // Specs Chips
                      Row(
                        children: [
                          _buildSpecPill('${property.bedsCount} غرف'),
                          const SizedBox(width: 4.0),
                          _buildSpecPill('${property.areaM2} م²'),
                          const SizedBox(width: 4.0),
                          _buildSpecPill(property.finishType),
                          const Spacer(),
                          const Text(
                            'التفاصيل >',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
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

  Widget _buildSpecPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9.5,
          color: AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
