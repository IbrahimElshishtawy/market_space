import 'package:flutter/material.dart';

import '../../../core/navigation/config/floating_action_config.dart';
import '../../../core/navigation/config/navigation_item_config.dart';
import '../../../core/navigation/config/section_navigation_config.dart';
import '../../../core/routing/route_names.dart';

class BuildingMaterialsNavigationConfig {
  static const String sectionId = 'building_materials';

  static const SectionNavigationConfig config = SectionNavigationConfig(
    sectionId: sectionId,
    sectionName: 'مواد البناء والمُوَن',
    floatingAction: FloatingActionConfig(
      id: 'bm-add',
      label: 'أضف إعلانك',
      icon: Icons.add_box_rounded,
      onPressedRoute: '/building-materials/add',
    ),
    items: [
      NavigationItemConfig(
        id: 'bm-home',
        label: 'الرئيسية',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
        destination: RouteNames.buildingMaterials,
      ),
      NavigationItemConfig(
        id: 'bm-categories',
        label: 'الأقسام',
        activeIcon: Icons.grid_view_rounded,
        inactiveIcon: Icons.grid_view_outlined,
        destination: '/building-materials/categories',
      ),
      NavigationItemConfig(
        id: 'bm-cart',
        label: 'السلة',
        activeIcon: Icons.shopping_cart_rounded,
        inactiveIcon: Icons.shopping_cart_outlined,
        destination: '/building-materials/cart',
      ),
      NavigationItemConfig(
        id: 'bm-orders',
        label: 'طلباتي',
        activeIcon: Icons.local_shipping_rounded,
        inactiveIcon: Icons.local_shipping_outlined,
        destination: '/building-materials/orders',
      ),
      NavigationItemConfig(
        id: 'bm-notifications',
        label: 'الإشعارات',
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_outlined,
        destination: '/building-materials/notifications',
        badgeKey: 'building_materials',
      ),
    ],
  );
}
