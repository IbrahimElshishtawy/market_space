import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/ac_part_item_model.dart';
import 'ac_parts_grid_layout.dart';

class AcPartCard extends StatelessWidget {
  final AcPartItemModel part;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCartTap;

  const AcPartCard({
    super.key,
    required this.part,
    this.onTap,
    this.onAddToCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(
          AcPartsGridLayout.borderRadius,
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AcPartsGridLayout.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Brand & Rating Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AcPartsGridLayout.borderRadius),
                  ),
                  child: SafeNetworkImage(
                    imageUrl: part.imageUrl,
                    height: AcPartsGridLayout.imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.settings_input_component_rounded,
                  ),
                ),

                // Top-right Brand Badge (in RTL)
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Text(
                      part.brand,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Top-left Rating Badge (in RTL)
                Positioned(
                  top: 6.0,
                  left: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 11.0,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          part.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      part.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const Spacer(),

                    // Bottom Row: Price on Right, Action Button on Left (in RTL)
                    Row(
                      children: [
                        // Price (Right in RTL)
                        Text(
                          part.priceText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD97706),
                          ),
                        ),

                        const Spacer(),

                        // Action Button (Left in RTL)
                        InkWell(
                          onTap: onAddToCartTap,
                          borderRadius: BorderRadius.circular(6.0),
                          child: Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimary : AppColors.neutral,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 14.0,
                                color: isDark ? AppColors.darkOnPrimary : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
