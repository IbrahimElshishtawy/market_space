import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/features/home_appliances/orders/data/models/appliance_order_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  final ApplianceOrderStatus currentStatus;

  const OrderStatusTimeline({super.key, required this.currentStatus});

  static const List<ApplianceOrderStatus> _timelineSteps = [
    ApplianceOrderStatus.confirmed,
    ApplianceOrderStatus.processing,
    ApplianceOrderStatus.shipped,
    ApplianceOrderStatus.outForDelivery,
    ApplianceOrderStatus.delivered,
  ];

  int get _currentStepIndex {
    switch (currentStatus) {
      case ApplianceOrderStatus.confirmed:
        return 0;
      case ApplianceOrderStatus.processing:
        return 1;
      case ApplianceOrderStatus.shipped:
        return 2;
      case ApplianceOrderStatus.outForDelivery:
        return 3;
      case ApplianceOrderStatus.delivered:
        return 4;
      case ApplianceOrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == ApplianceOrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18.0),
            SizedBox(width: 8.0),
            Text(
              'الطلب ملغي',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final currentIdx = _currentStepIndex;

    return Row(
      children: List.generate(_timelineSteps.length, (index) {
        final step = _timelineSteps[index];
        final isCompleted = index <= currentIdx;
        final isLast = index == _timelineSteps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.neutral : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.neutral
                            : AppColors.lightBorder,
                        width: 2.0,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12.0,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    step.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCompleted
                          ? AppColors.neutral
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2.0,
                    margin: const EdgeInsets.only(bottom: 14.0),
                    color: index < currentIdx
                        ? AppColors.neutral
                        : AppColors.lightBorder,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
