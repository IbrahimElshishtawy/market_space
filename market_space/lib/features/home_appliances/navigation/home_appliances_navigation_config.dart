import 'package:flutter/material.dart';

import '../../../core/navigation/config/navigation_item_config.dart';
import '../../../core/navigation/config/section_navigation_config.dart';
import '../../../core/routing/route_names.dart';

class HomeAppliancesNavigationConfig {
  static const String sectionId = 'home_appliances';

  static const SectionNavigationConfig config = SectionNavigationConfig(
    sectionId: sectionId,
    sectionName: 'الأجهزة المنزلية',
    items: [
      NavigationItemConfig(
        id: 'ha-home',
        label: 'الرئيسية',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
        destination: RouteNames.homeAppliances,
      ),
      NavigationItemConfig(
        id: 'ha-categories',
        label: 'الأقسام',
        activeIcon: Icons.category_rounded,
        inactiveIcon: Icons.category_outlined,
        destination: '/home-appliances/categories',
      ),
      NavigationItemConfig(
        id: 'ha-cart',
        label: 'السلة',
        activeIcon: Icons.shopping_bag_rounded,
        inactiveIcon: Icons.shopping_bag_outlined,
        destination: '/home-appliances/cart',
      ),
      NavigationItemConfig(
        id: 'ha-orders',
        label: 'طلباتي',
        activeIcon: Icons.receipt_long_rounded,
        inactiveIcon: Icons.receipt_long_outlined,
        destination: '/home-appliances/orders',
      ),
      NavigationItemConfig(
        id: 'ha-notifications',
        label: 'الإشعارات',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
        destination: '/home-appliances/notifications',
        badgeKey: 'home_appliances',
      ),
    ],
  );
}
