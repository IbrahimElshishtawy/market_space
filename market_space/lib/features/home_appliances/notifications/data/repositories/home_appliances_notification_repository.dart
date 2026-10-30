import 'package:market_space/core/notifications/data/models/app_notification.dart';

abstract class HomeAppliancesNotificationRepository {
  Future<List<AppNotification>> getNotifications({String? userId});
  Future<int> getUnreadCount({String? userId});
  Future<bool> markAsRead(String notificationId);
  Future<bool> markAllAsRead({String? userId});
  Future<bool> deleteNotification(String notificationId);
}

class MockHomeAppliancesNotificationRepository
    implements HomeAppliancesNotificationRepository {
  final List<AppNotification> _notificationsStore = [
    AppNotification(
      id: 'notif-ha-1',
      sectionId: 'home_appliances',
      type: 'order_status',
      title: 'تم شحن طلب الأجهزة!',
      body:
          'شحنتك رقم HA-2025-01 (غسالة ملابس أوتماتيك 9 كيلو) في الطريق إليك.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      targetId: 'ord-101',
      targetRoute: '/home-appliances/orders',
    ),
    AppNotification(
      id: 'notif-ha-2',
      sectionId: 'home_appliances',
      type: 'promo',
      title: 'عروض التقسيط الميسر بدون فوائد',
      body: 'استمتع بتقسيط شاشات وثلاجات شارب حتى 12 شهر مع البنوك المعتمدة.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      targetRoute: '/home-appliances',
    ),
    AppNotification(
      id: 'notif-ha-3',
      sectionId: 'home_appliances',
      type: 'price_drop',
      title: 'خصم خاص على أجهزة المطبخ!',
      body: 'انخفض سعر مايكروويف إل جي 42 لتر بقيمة 800 ج.م لفترة محدودة.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      targetRoute: '/home-appliances',
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_notificationsStore);
  }

  @override
  Future<int> getUnreadCount({String? userId}) async {
    return _notificationsStore.where((n) => !n.isRead).length;
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _notificationsStore.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notificationsStore[index] = _notificationsStore[index].copyWith(
        isRead: true,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> markAllAsRead({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (var i = 0; i < _notificationsStore.length; i++) {
      if (!_notificationsStore[i].isRead) {
        _notificationsStore[i] = _notificationsStore[i].copyWith(isRead: true);
      }
    }
    return true;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _notificationsStore.removeWhere((n) => n.id == notificationId);
    return true;
  }
}
