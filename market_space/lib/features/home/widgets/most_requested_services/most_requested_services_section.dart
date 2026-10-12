import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/home_service_data.dart';
import 'most_requested_services_layout.dart';
import 'service_card.dart';

class MostRequestedServicesSection extends StatelessWidget {
  final List<HomeServiceData> services;
  final ValueChanged<HomeServiceData>? onServiceTap;
  final VoidCallback? onViewAllTap;

  const MostRequestedServicesSection({
    super.key,
    required this.services,
    this.onServiceTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: MostRequestedServicesLayout.padding(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(4.0),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const Flexible(
                child: Text(
                  'الخدمات الأكثر طلباً',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8.0),

        // Horizontal Cards List
        SizedBox(
          height: 235.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12.0),
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(
                service: service,
                onTap: () => onServiceTap?.call(service),
              );
            },
          ),
        ),
      ],
    );
  }
}
