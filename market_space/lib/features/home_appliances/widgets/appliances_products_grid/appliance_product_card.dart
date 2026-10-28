import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/appliance_product_model.dart';

class ApplianceProductCard extends StatelessWidget {
  final ApplianceProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCartTap;
  final VoidCallback? onFavoriteTap;

  const ApplianceProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCartTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.lg,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Image Header Section
              SizedBox(
                height: 100.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SafeNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.devices_rounded,
                    ),

                    // Brand Badge (Top Left)
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: AppRadii.sm,
                        ),
                        child: Text(
                          product.brandName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Product Badge (Top Right)
                    if (product.badgeText != null)
                      Positioned(
                        top: 8.0,
                        right: 8.0,
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
                            product.badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Card Content Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Title
                          Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral,
                            ),
                          ),

                          const SizedBox(height: 2.0),

                          // Subtitle
                          Text(
                            product.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.lightTextMuted,
                            ),
                          ),

                          const SizedBox(height: 6.0),

                          // Prices Row
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                Text(
                                  product.priceFormatted,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                if (product.oldPriceFormatted != null) ...[
                                  const SizedBox(width: 4.0),
                                  Text(
                                    product.oldPriceFormatted!,
                                    style: const TextStyle(
                                      fontSize: 10.0,
                                      color: Color(0xFF94A3B8),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 3.0),

                          // Installment Info
                          if (product.monthlyInstallmentFormatted != null)
                            Text(
                              product.monthlyInstallmentFormatted!,
                              style: const TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6.0),

                      // Add to Cart Action Button
                      InkWell(
                        onTap: onAddToCartTap,
                        borderRadius: AppRadii.md,
                        child: Container(
                          width: double.infinity,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: product.inCart
                                ? AppColors.secondaryDark
                                : AppColors.neutral,
                            borderRadius: AppRadii.md,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.inCart ? 'تمت الإضافة' : 'أضف للسلة',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Icon(
                                product.inCart
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.shopping_cart_outlined,
                                size: 14.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
