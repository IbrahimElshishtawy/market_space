import 'package:flutter/material.dart';

import '../../../core/navigation/config/floating_action_config.dart';
import '../../../core/navigation/config/navigation_item_config.dart';
import '../../../core/navigation/config/section_navigation_config.dart';
import '../../../core/routing/route_names.dart';

class CarsNavigationConfig {
  static const String sectionId = 'cars';

  static const SectionNavigationConfig config = SectionNavigationConfig(
    sectionId: sectionId,
    sectionName: 'السيارات',
    floatingAction: FloatingActionConfig(
      id: 'cars-sell',
      label: 'بيع سيارتك',
      icon: Icons.add_circle_outline_rounded,
      onPressedRoute: '/cars/sell',
    ),
    items: [
      NavigationItemConfig(
        id: 'cars-home',
        label: 'الرئيسية',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
        destination: RouteNames.cars,
      ),
      NavigationItemConfig(
        id: 'cars-browse',
        label: 'السيارات',
        activeIcon: Icons.directions_car_rounded,
        inactiveIcon: Icons.directions_car_outlined,
        destination: '/cars/browse',
      ),
      NavigationItemConfig(
        id: 'cars-brands',
        label: 'الماركات',
        activeIcon: Icons.grid_view_rounded,
        inactiveIcon: Icons.grid_view_outlined,
        destination: '/cars/brands',
      ),
      NavigationItemConfig(
        id: 'cars-favorites',
        label: 'المفضلة',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_border_rounded,
        destination: '/cars/favorites',
      ),
      NavigationItemConfig(
        id: 'cars-notifications',
        label: 'الإشعارات',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
        destination: '/cars/notifications',
        badgeKey: 'cars',
      ),
    ],
  );
}
