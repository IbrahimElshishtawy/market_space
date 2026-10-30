import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/notifications/data/models/app_notification.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../navigation/building_materials_navigation_config.dart';
import '../controllers/building_materials_notification_controller.dart';

class BuildingMaterialsNotificationsPage extends StatefulWidget {
  const BuildingMaterialsNotificationsPage({super.key});

  @override
  State<BuildingMaterialsNotificationsPage> createState() =>
      _BuildingMaterialsNotificationsPageState();
}

class _BuildingMaterialsNotificationsPageState
    extends State<BuildingMaterialsNotificationsPage> {
  int _selectedBottomNavIndex = 4; // الإشعارات

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dependencies = AppDependencies.maybeOf(context);
      dependencies?.buildingMaterialsNotificationController.loadNotifications();
    });
  }

  void _onBottomNavSelected(int index) {
    if (index == _selectedBottomNavIndex) return;
    setState(() => _selectedBottomNavIndex = index);

    final config = BuildingMaterialsNavigationConfig.config;
    final item = config.items[index];
    context.go(item.destination);
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final controller = dependencies.buildingMaterialsNotificationController;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'إشعارات مواد البناء',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.buildingMaterials);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => controller.markAllAsRead(),
              child: const Text(
                'قراءة الكل',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emerald700),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: BuildingMaterialsNavigationConfig.config,
          currentIndex: _selectedBottomNavIndex,
          onTabSelected: _onBottomNavSelected,
        ),
        body: ValueListenableBuilder<BuildingMaterialsNotificationState>(
          valueListenable: controller,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            final notifications = state.filteredNotifications;

            return Column(
              children: [
                // شريط الفلاتر الأفقية
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: BuildingMaterialsNotificationFilter.values.map((filter) {
                        final isSelected = filter == state.activeFilter;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(filter.label),
                            selected: isSelected,
                            selectedColor: AppColors.emerald100,
                            backgroundColor: AppColors.slate100,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.emerald800 : AppColors.slate800,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.emerald600 : Colors.transparent,
                            ),
                            onSelected: (_) => controller.setFilter(filter),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.slate200),

                // قائمة الإشعارات
                Expanded(
                  child: notifications.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: AppEmptyState(
                              title: 'لا توجد إشعارات',
                              message: 'كل إشعارات طلبياتك، تحديثات أسعار الحديد والأسمنت، وعروض الموردين ستظهر هنا.',
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => controller.loadNotifications(),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              return _buildNotificationCard(controller, item);
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildingMaterialsNotificationController controller,
    AppNotification item,
  ) {
    final iconData = _getNotificationIcon(item.type);
    final iconColor = _getNotificationColor(item.type);

    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
        borderRadius: AppRadii.md,
        border: Border.all(
          color: item.isRead ? AppColors.slate200 : AppColors.emerald300,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.slate900,
                ),
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.emerald600,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              item.body,
              style: TextStyle(fontSize: 12, color: AppColors.slate600, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(item.createdAt),
              style: TextStyle(fontSize: 10, color: AppColors.slate400),
            ),
          ],
        ),
        onTap: () {
          if (!item.isRead) {
            controller.markAsRead(item.id);
          }
          if (item.targetRoute != null && item.targetRoute!.isNotEmpty) {
            context.push(item.targetRoute!);
          } else if (item.type.contains('order')) {
            context.push(RouteNames.buildingMaterialsOrders);
          }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    if (type.contains('order') || type.contains('shipment')) {
      return Icons.local_shipping_rounded;
    } else if (type.contains('price') || type.contains('offer')) {
      return Icons.trending_down_rounded;
    } else if (type.contains('supplier') || type.contains('rfq')) {
      return Icons.business_center_rounded;
    } else if (type.contains('payment')) {
      return Icons.receipt_long_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  Color _getNotificationColor(String type) {
    if (type.contains('order') || type.contains('shipment')) {
      return const Color(0xFF2563EB);
    } else if (type.contains('price') || type.contains('offer')) {
      return Colors.amber.shade800;
    } else if (type.contains('supplier') || type.contains('rfq')) {
      return Colors.purple.shade700;
    } else if (type.contains('payment')) {
      return AppColors.emerald700;
    }
    return AppColors.slate700;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
