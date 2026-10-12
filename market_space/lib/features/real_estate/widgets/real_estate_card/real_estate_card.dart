import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/real_estate_listing_model.dart';
import 'real_estate_card_layout.dart';
import 'real_estate_card_specs.dart';

class RealEstateCard extends StatelessWidget {
  final RealEstateListingModel item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDetailsTap;

  const RealEstateCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: RealEstateCardLayout.margin(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.lg,
        child: InkWell(
          onTap: onTap ?? onDetailsTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Image Header Section
              _buildImageHeader(),

              // 2. Card Content Body
              Padding(
                padding: RealEstateCardLayout.contentPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 4.0),

                    // Subtitle / Location
                    Text(
                      item.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextMuted,
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    // Price
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.priceFormatted,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          if (item.pricePeriod != null) ...[
                            const TextSpan(text: ' / '),
                            TextSpan(
                              text: item.pricePeriod,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12.0),

                    // Specs Row
                    RealEstateCardSpecs(item: item),

                    const SizedBox(height: 14.0),

                    // Action Details Button
                    _buildDetailsButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return SizedBox(
      height: RealEstateCardLayout.imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          SafeNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            fallbackIcon: Icons.apartment_rounded,
          ),

          // Top Left Tag (للإيجار / للبيع)
          Positioned(
            top: 12.0,
            left: 12.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral,
                borderRadius: AppRadii.sm,
              ),
              child: Text(
                item.type.label.replaceAll('شقق ', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Top Right Favorite Button
          Positioned(
            top: 12.0,
            right: 12.0,
            child: InkWell(
              onTap: onFavoriteTap,
              borderRadius: AppRadii.full,
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18.0,
                  color: item.isFavorite ? AppColors.primary : Colors.white,
                ),
              ),
            ),
          ),

          // Bottom Right Photo Badge
          Positioned(
            bottom: 12.0,
            right: 12.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: AppRadii.full,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.currentPhotoIndex} / ${item.totalPhotos}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 13.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    return Container(
      width: double.infinity,
      height: 44.0,
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: AppRadii.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDetailsTap,
          borderRadius: AppRadii.md,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'التفاصيل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.0),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
