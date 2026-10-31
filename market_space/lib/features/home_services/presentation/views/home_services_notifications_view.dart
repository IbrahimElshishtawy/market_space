import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';

class ServiceNotificationItem {
  final String id;
  final String title;
  final String body;
  final String category; // 'BOOKING', 'TECHNICIAN', 'OFFER', 'SUPPORT'
  final DateTime timestamp;
  final String? deepLink;
  bool isRead;

  ServiceNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.deepLink,
    this.isRead = false,
  });
}

class HomeServicesNotificationsView extends StatefulWidget {
  const HomeServicesNotificationsView({super.key});

  @override
  State<HomeServicesNotificationsView> createState() =>
      _HomeServicesNotificationsViewState();
}

class _HomeServicesNotificationsViewState
    extends State<HomeServicesNotificationsView> {
  String _selectedCategory = 'ALL';

  final List<ServiceNotificationItem> _notifications = [
    ServiceNotificationItem(
      id: 'notif-1',
      title: 'الفني تم تعيينه بنجاح',
      body: 'تم تعيين المهندس أحمد محمود لحجز غسيل التكييف (HS-BK-88421).',
      category: 'TECHNICIAN',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      deepLink: '/home-services/booking-detail?id=HS-BK-88421',
      isRead: false,
    ),
    ServiceNotificationItem(
      id: 'notif-2',
      title: 'تأكيد موعد حجز الصيانة',
      body: 'تم قبول طلب الحجز الخاص بك لموعد الغد من الساعة 12:00 م حتى 2:00 م.',
      category: 'BOOKING',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      deepLink: '/home-services/booking-detail?id=HS-BK-88421',
      isRead: false,
    ),
    ServiceNotificationItem(
      id: 'notif-3',
      title: 'عرض الصيف: خصم 20% على تكييفات منزلك',
      body: 'احصل على فحص وتنظيف شامل لجميع تكييفات المنزل بأسعار تبدأ من 220 ج.م.',
      category: 'OFFER',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      deepLink: '/home-services/service-detail?id=srv-ac-wash',
      isRead: true,
    ),
    ServiceNotificationItem(
      id: 'notif-4',
      title: 'اكتمال الخدمة والتقييم',
      body: 'تم إتمام صيانة خلاطات ومحابس المياه (HS-BK-77190). يرجى تقييم الفني.',
      category: 'BOOKING',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      deepLink: '/home-services/booking-detail?id=HS-BK-77190',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedCategory == 'ALL') return true;
      return n.category == _selectedCategory;
    }).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Column(
      children: [
        // Category Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildChip('ALL', 'الكل'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildChip('BOOKING', 'الحجوزات'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildChip('TECHNICIAN', 'الفنيين'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildChip('OFFER', 'العروض'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildChip('SUPPORT', 'الدعم'),
                    ],
                  ),
                ),
              ),
              if (unreadCount > 0)
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var n in _notifications) {
                        n.isRead = true;
                      }
                    });
                  },
                  child: const Text('قراءة الكل', style: TextStyle(fontSize: 12.0)),
                ),
            ],
          ),
        ),

        // Notifications List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    120.0,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildNotificationCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = key;
        });
      },
    );
  }

  Widget _buildNotificationCard(ServiceNotificationItem item) {
    IconData icon;
    Color iconColor;

    switch (item.category) {
      case 'BOOKING':
        icon = Icons.calendar_today_rounded;
        iconColor = Colors.blue;
        break;
      case 'TECHNICIAN':
        icon = Icons.handyman_rounded;
        iconColor = Colors.green;
        break;
      case 'OFFER':
        icon = Icons.local_offer_rounded;
        iconColor = Colors.orange;
        break;
      case 'SUPPORT':
        icon = Icons.support_agent_rounded;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: item.isRead ? AppColors.lightBorder : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() {
            item.isRead = true;
          });
          if (item.deepLink != null) {
            context.push(item.deepLink!);
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22.0),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: item.isRead ? FontWeight.bold : FontWeight.w800,
                  color: AppColors.neutral,
                ),
              ),
            ),
            if (!item.isRead)
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4.0),
            Text(
              item.body,
              style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 6.0),
            Text(
              _formatTimeAgo(item.timestamp),
              style: const TextStyle(fontSize: 10.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64.0, color: Colors.grey),
            SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد إشعارات حالياً',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'ستظهر هنا كافة إشعارات تحديثات الحجز وتعيين الفنيين والعروض الحصرية.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}
