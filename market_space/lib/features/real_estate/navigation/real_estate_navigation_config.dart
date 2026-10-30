import 'package:flutter/material.dart';

import '../../../core/navigation/config/floating_action_config.dart';
import '../../../core/navigation/config/navigation_item_config.dart';
import '../../../core/navigation/config/section_navigation_config.dart';
import '../../../core/routing/route_names.dart';

class RealEstateNavigationConfig {
  static const String sectionId = 'real_estate';

  static const SectionNavigationConfig config = SectionNavigationConfig(
    sectionId: sectionId,
    sectionName: 'العقارات',
    floatingAction: FloatingActionConfig(
      id: 're-add-property',
      label: 'أضف عقارك',
      icon: Icons.add_home_rounded,
      onPressedRoute: '/real-estate/add',
    ),
    items: [
      NavigationItemConfig(
        id: 're-home',
        label: 'الرئيسية',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
        destination: RouteNames.realEstate,
      ),
      NavigationItemConfig(
        id: 're-reels',
        label: 'الريلز',
        activeIcon: Icons.play_circle_rounded,
        inactiveIcon: Icons.play_circle_outline_rounded,
        destination: '/real-estate/reels',
      ),
      NavigationItemConfig(
        id: 're-map',
        label: 'الخريطة',
        activeIcon: Icons.map_rounded,
        inactiveIcon: Icons.map_outlined,
        destination: '/real-estate/map',
      ),
      NavigationItemConfig(
        id: 're-favorites',
        label: 'المفضلة',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_border_rounded,
        destination: '/real-estate/favorites',
      ),
      NavigationItemConfig(
        id: 're-notifications',
        label: 'الإشعارات',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
        destination: '/real-estate/notifications',
        badgeKey: 'real_estate',
      ),
    ],
  );
}
