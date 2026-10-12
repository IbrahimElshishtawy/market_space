import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../../data/models/real_estate_detail_model.dart';
import 'advertiser_profile_card_layout.dart';

class AdvertiserProfileCard extends StatelessWidget {
  final AdvertiserModel advertiser;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onCallTap;

  const AdvertiserProfileCard({
    super.key,
    required this.advertiser,
    this.onWhatsAppTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadii.md,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Avatar Image
          ClipRRect(
            borderRadius: AppRadii.full,
            child: SizedBox(
              width: AdvertiserProfileCardLayout.avatarSize,
              height: AdvertiserProfileCardLayout.avatarSize,
              child: SafeNetworkImage(
                imageUrl: advertiser.avatarUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.person_rounded,
              ),
            ),
          ),

          const SizedBox(width: 10.0),

          // Name and Role Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advertiser.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  advertiser.role,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8.0),

          // Action Buttons Column (WhatsApp & Call)
          Column(
            children: [
              // WhatsApp Button (Green)
              InkWell(
                onTap: onWhatsAppTap,
                borderRadius: AppRadii.sm,
                child: Container(
                  height: AdvertiserProfileCardLayout.buttonHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: AppRadii.sm,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 14.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        'واتساب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6.0),

              // Call Button (Dark Navy)
              InkWell(
                onTap: onCallTap,
                borderRadius: AppRadii.sm,
                child: Container(
                  height: AdvertiserProfileCardLayout.buttonHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: AppColors.neutral,
                    borderRadius: AppRadii.sm,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_in_talk_outlined,
                        size: 14.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        'أتصال',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
