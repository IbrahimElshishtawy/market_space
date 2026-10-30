import 'package:flutter/material.dart';

import '../../../core/navigation/config/floating_action_config.dart';
import '../../../core/navigation/config/navigation_item_config.dart';
import '../../../core/navigation/config/section_navigation_config.dart';

class HomeServicesNavigationConfig {
  static const String sectionId = 'services';

  static const SectionNavigationConfig config = SectionNavigationConfig(
    sectionId: sectionId,
    sectionName: 'الخدمات والمقاولات',
    floatingAction: FloatingActionConfig(
      id: 'hs-add',
      label: 'أضف إعلانك',
      icon: Icons.add_task_rounded,
      onPressedRoute: '/home-services/add',
    ),
    items: [
      NavigationItemConfig(
        id: 'hs-home',
        label: 'الرئيسية',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
        destination: '/home-services',
      ),
      NavigationItemConfig(
        id: 'hs-services',
        label: 'الخدمات',
        activeIcon: Icons.handyman_rounded,
        inactiveIcon: Icons.handyman_outlined,
        destination: '/home-services/catalog',
      ),
      NavigationItemConfig(
        id: 'hs-bookings',
        label: 'حجوزاتي',
        activeIcon: Icons.calendar_month_rounded,
        inactiveIcon: Icons.calendar_month_outlined,
        destination: '/home-services/bookings',
      ),
      NavigationItemConfig(
        id: 'hs-favorites',
        label: 'المفضلة',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_border_rounded,
        destination: '/home-services/favorites',
      ),
      NavigationItemConfig(
        id: 'hs-notifications',
        label: 'الإشعارات',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
        destination: '/home-services/notifications',
        badgeKey: 'services',
      ),
    ],
  );
}
