import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../../../data/models/real_estate_detail_model.dart';

class ReelOwnerHeader extends StatelessWidget {
  final AdvertiserModel advertiser;
  final VoidCallback? onContactTap;

  const ReelOwnerHeader({
    super.key,
    required this.advertiser,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Owner Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: 38.0,
            height: 38.0,
            child: SafeNetworkImage(
              imageUrl: advertiser.avatarUrl,
              fit: BoxFit.cover,
              fallbackIcon: Icons.person_rounded,
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Owner Name, Verified Badge & Contact Button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      advertiser.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4.0,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.info,
                    size: 15.0,
                  ),
                  const SizedBox(width: 8.0),

                  // Contact Primary Pill Button directly beside advertiser name
                  InkWell(
                    onTap: onContactTap,
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            color: Colors.white,
                            size: 12.0,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'تواصل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              Text(
                advertiser.role,
                style: const TextStyle(color: Colors.white70, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
