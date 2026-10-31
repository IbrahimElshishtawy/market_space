import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/notifications/data/models/app_notification.dart';
import '../../../../core/notifications/presentation/state/notification_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class GlobalNotificationsPage extends StatefulWidget {
  final NotificationController? controller;

  const GlobalNotificationsPage({super.key, this.controller});

  @override
  State<GlobalNotificationsPage> createState() => _GlobalNotificationsPageState();
}

class _GlobalNotificationsPageState extends State<GlobalNotificationsPage> {
  String _selectedSector = 'all';

  final List<Map<String, String>> _sectors = const [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'real_estate', 'label': 'العقارات'},
    {'id': 'building_materials', 'label': 'مواد البناء'},
    {'id': 'services', 'label': 'الخدمات المنزلية'},
    {'id': 'home_appliances', 'label': 'الأجهزة المنزلية'},
    {'id': 'cars', 'label': 'السيارات'},
    {'id': 'fashion', 'label': 'الملابس والأزياء'},
  ];

  void _handleNotificationTap(AppNotification notif) {
    final controller = widget.controller ?? AppDependencies.maybeOf(context)?.notificationController;
    if (!notif.isRead) {
      controller?.markAsRead(notif.id);
    }

    if (notif.targetRoute != null && GoRouter.maybeOf(context) != null) {
      context.push(notif.targetRoute!);
    }
  }

  void _markAllRead() {
    final controller = widget.controller ?? AppDependencies.maybeOf(context)?.notificationController;
    if (controller != null) {
      if (_selectedSector == 'all') {
        controller.markAllAsRead('real_estate');
        controller.markAllAsRead('building_materials');
        controller.markAllAsRead('services');
        controller.markAllAsRead('home_appliances');
        controller.markAllAsRead('cars');
        controller.markAllAsRead('fashion');
      } else {
        controller.markAllAsRead(_selectedSector);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? AppDependencies.of(context).notificationController;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('الإشعارات والتنبيهات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          centerTitle: false,
          actions: [
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 16.0),
              label: const Text('تحديد الكل كمقروء', style: TextStyle(fontSize: 12.0)),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Sector Tabs
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _sectors.map((sec) {
                      final isSelected = _selectedSector == sec['id'];
                      final unreadCount = sec['id'] == 'all'
                          ? controller.getUnreadCount('real_estate') +
                              controller.getUnreadCount('building_materials') +
                              controller.getUnreadCount('services') +
                              controller.getUnreadCount('home_appliances')
                          : controller.getUnreadCount(sec['id']!);

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          selected: isSelected,
                          showCheckmark: false,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sec['label']!,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.neutral,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 4.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : AppColors.primary,
                                    borderRadius: AppRadii.full,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primary : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          selectedColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.full,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : const Color(0x0F000000),
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedSector = sec['id']!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Notifications List
              Expanded(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    List<AppNotification> items;
                    if (_selectedSector == 'all') {
                      items = [
                        ...controller.getNotifications('real_estate'),
                        ...controller.getNotifications('building_materials'),
                        ...controller.getNotifications('services'),
                        ...controller.getNotifications('home_appliances'),
                        ...controller.getNotifications('cars'),
                        ...controller.getNotifications('fashion'),
                      ];
                    } else {
                      items = controller.getNotifications(_selectedSector);
                    }

                    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (items.isEmpty) {
                      return const AppEmptyState(
                        title: 'لا توجد إشعارات',
                        message: 'صندوق الإشعارات فارغ حالياً. ستظهر هنا كافة التحديثات الخاصة بالطلبات والتنبيهات.',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final notif = items[index];
                        return _buildNotificationCard(notif);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    Color sectorColor;
    String sectorName;

    switch (notif.sectionId) {
      case 'real_estate':
        sectorColor = const Color(0xFF1E293B);
        sectorName = 'العقارات';
        break;
      case 'building_materials':
        sectorColor = const Color(0xFFD97706);
        sectorName = 'مواد البناء';
        break;
      case 'services':
        sectorColor = const Color(0xFFEA580C);
        sectorName = 'الخدمات المنزلية';
        break;
      case 'home_appliances':
        sectorColor = const Color(0xFF0284C7);
        sectorName = 'الأجهزة المنزلية';
        break;
      case 'cars':
        sectorColor = const Color(0xFF0F766E);
        sectorName = 'السيارات';
        break;
      case 'fashion':
        sectorColor = const Color(0xFFBE185D);
        sectorName = 'الملابس والأزياء';
        break;
      default:
        sectorColor = AppColors.primary;
        sectorName = 'إشعار عام';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: notif.isRead ? const Color(0x14000000) : AppColors.primary.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notif),
        borderRadius: AppRadii.lg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: sectorColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_rounded, color: sectorColor, size: 20.0),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sectorName,
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: sectorColor,
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      notif.body,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
