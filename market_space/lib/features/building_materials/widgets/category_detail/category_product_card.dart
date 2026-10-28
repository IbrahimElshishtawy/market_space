import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/category_product_item_model.dart';

class CategoryProductCard extends StatelessWidget {
  final CategoryProductItemModel product;
  final VoidCallback? onTap;
  final VoidCallback? onOrderTap;

  const CategoryProductCard({
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
                    height: 110.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.foundation_rounded,
                  ),
                ),

                // Top-Left Brand Logo Badge
                Positioned(
                  top: 6.0,
                  left: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Text(
                      product.brandName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Top-Right Quality Badge
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: AppRadii.sm,
                    ),
                    child: Text(
                      product.badgeText,
                      style: const TextStyle(
                        color: AppColors.neutral,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    const SizedBox(height: 2.0),

                    Text(
                      product.filterTag,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),

                    const Spacer(),

                    // Price & Order Action Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Action Icon
                        InkWell(
                          onTap: onOrderTap,
                          borderRadius: AppRadii.full,
                          child: Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: const BoxDecoration(
                              color: AppColors.neutral,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.local_shipping_rounded,
                                size: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Price
                        Flexible(
                          child: Text(
                            product.priceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
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
