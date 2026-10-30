import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/building_material_product_model.dart';
import 'most_requested_materials_layout.dart';

class MaterialCard extends StatelessWidget {
  final BuildingMaterialProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onOrderTap;

  const MaterialCard({
    super.key,
    required this.product,
    this.onTap,
    this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  child: SafeNetworkImage(
                    imageUrl: product.imageUrl,
                    height: MostRequestedMaterialsLayout.imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.foundation_rounded,
                  ),
                ),

                // Top-Left Badge: Category Pill
                Positioned(
                  top: 6.0,
                  left: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral.withValues(alpha: 0.85),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Text(
                      product.categoryTag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Top-Right Badge: Rating ⭐ 4.8
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral.withValues(alpha: 0.85),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13.0,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Text & Price Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightTextPrimary,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 3.0),

                    // Description
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: AppColors.lightTextSecondary,
                        height: 1.3,
                      ),
                    ),

                    const Spacer(),

                    // Price & Action Button Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price (Right in RTL)
                        Flexible(
                          child: Text(
                            product.priceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706), // Amber/Orange price
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Action Button (Left in RTL)
                        InkWell(
                          onTap: onOrderTap,
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: AppColors.neutral,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16.0,
                                color: Colors.white,
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
