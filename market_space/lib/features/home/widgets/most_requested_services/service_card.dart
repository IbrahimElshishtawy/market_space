import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/home_service_data.dart';
import 'most_requested_services_layout.dart';

class ServiceCard extends StatelessWidget {
  final HomeServiceData service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        MostRequestedServicesLayout.borderRadius,
      ),
      child: Container(
        width: MostRequestedServicesLayout.cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            MostRequestedServicesLayout.borderRadius,
          ),
          border: Border.all(color: AppColors.lightBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Image with Badge
            SizedBox(
              height: MostRequestedServicesLayout.imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                        MostRequestedServicesLayout.borderRadius,
                      ),
                      topRight: Radius.circular(
                        MostRequestedServicesLayout.borderRadius,
                      ),
                    ),
                    child: SafeNetworkImage(
                      imageUrl: service.imageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.handyman_rounded,
                    ),
                  ),

                  // Overlay Badge (Top Right in RTL)
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xCC0F172A,
                        ), // Dark translucent badge
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        service.badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 2.0),

                  // Subtitle
                  Text(
                    service.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6.0),

                  // Price
                  Text(
                    service.priceText,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706), // Gold/Orange price accent
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Bottom Rating + Avatar Stack Line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar Stack with +115 count
                      Row(
                        children: [
                          _buildAvatarCircle(
                            0,
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
                          ),
                          Transform.translate(
                            offset: const Offset(-6, 0),
                            child: _buildAvatarCircle(
                              1,
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-12, 0),
                            child: Container(
                              width: 18.0,
                              height: 18.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  service.avatarStackText,
                                  style: const TextStyle(
                                    fontSize: 7.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Rating Stars
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16.0,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            service.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral,
                            ),
                          ),
                        ],
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

  Widget _buildAvatarCircle(int index, String url) {
    return Container(
      width: 18.0,
      height: 18.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.0),
        child: SafeNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fallbackIcon: Icons.person_rounded,
        ),
      ),
    );
  }
}
