import 'package:flutter/material.dart';

import '../../../core/navigation/config/navigation_item_config.dart';
import '../../../core/navigation/config/section_navigation_config.dart';
import '../../../core/routing/route_names.dart';

class FashionNavigationConfig {
  static const String sectionId = 'fashion';

  static const SectionNavigationConfig config = SectionNavigationConfig(
    sectionId: sectionId,
    sectionName: 'الملابس والأزياء',
    items: [
      NavigationItemConfig(
        id: 'fashion-home',
        label: 'الرئيسية',
        activeIcon: Icons.checkroom_rounded,
        inactiveIcon: Icons.checkroom_outlined,
        destination: RouteNames.fashion,
      ),
      NavigationItemConfig(
        id: 'fashion-categories',
        label: 'الأقسام',
        activeIcon: Icons.category_rounded,
        inactiveIcon: Icons.category_outlined,
        destination: '/fashion/categories',
      ),
      NavigationItemConfig(
        id: 'fashion-cart',
        label: 'السلة',
        activeIcon: Icons.shopping_bag_rounded,
        inactiveIcon: Icons.shopping_bag_outlined,
        destination: '/fashion/cart',
      ),
      NavigationItemConfig(
        id: 'fashion-favorites',
        label: 'المفضلة',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_border_rounded,
        destination: '/fashion/favorites',
      ),
      NavigationItemConfig(
        id: 'fashion-notifications',
        label: 'الإشعارات',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
        destination: '/fashion/notifications',
        badgeKey: 'fashion',
      ),
    ],
  );
}
