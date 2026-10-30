import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/features/home_appliances/cart/data/models/appliance_cart_model.dart';
import 'package:market_space/shared/widgets/market_widgets/safe_network_image.dart';

class CartItemCard extends StatelessWidget {
  final ApplianceCartItemModel item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemoveTap;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: AppRadii.md,
              child: SizedBox(
                width: 85.0,
                height: 85.0,
                child: SafeNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.kitchen_rounded,
                ),
              ),
            ),
            const SizedBox(width: 12.0),

            // Product Details & Quantity Control
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onRemoveTap,
                        borderRadius: BorderRadius.circular(20.0),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'ماركة: ${product.brandName}',
                    style: const TextStyle(
                      fontSize: 11.0,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Price & Quantity Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.priceFormatted,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutral,
                        ),
                      ),

                      // Quantity Selector Pill (+ / -)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => onQuantityChanged(item.quantity - 1),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(20.0),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 16.0,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => onQuantityChanged(item.quantity + 1),
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(20.0),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 16.0,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
