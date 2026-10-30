import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/ac_service_item_model.dart';
import 'ac_services_list_layout.dart';

class AcServiceCard extends StatelessWidget {
  final AcServiceItemModel service;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const AcServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AcServicesListLayout.borderRadius,
        ),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AcServicesListLayout.borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Right Image (Start in RTL)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SafeNetworkImage(
                  imageUrl: service.imageUrl,
                  width: AcServicesListLayout.imageSize,
                  height: AcServicesListLayout.imageSize,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.ac_unit_rounded,
                ),
              ),

              const SizedBox(width: 10.0),

              // 2. Center Content: Title, Description, Rating & Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.lightTextSecondary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14.0,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          '${service.rating.toStringAsFixed(1)} (+${service.reviewsCount})',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13.0,
                          color: AppColors.neutralLight,
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          '${service.durationMinutes} دقيقة',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // 3. Left Actions: Book Button & Price (End in RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Book Button "احجز الآن"
                  InkWell(
                    onTap: onBookTap,
                    borderRadius: AppRadii.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: AppRadii.md,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12.0,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'احجز الآن',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Price
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 12.0,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 3.0),
                      Text(
                        service.priceText,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
