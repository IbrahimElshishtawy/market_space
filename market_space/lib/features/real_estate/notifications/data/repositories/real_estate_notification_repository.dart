import 'package:market_space/core/notifications/data/models/app_notification.dart';

abstract class RealEstateNotificationRepository {
  Future<List<AppNotification>> getRealEstateNotifications({String? userId});
  Future<int> getUnreadCount({String? userId});
  Future<bool> markAsRead(String notificationId);
  Future<bool> markAllAsRead({String? userId});
  Future<bool> deleteNotification(String notificationId);
}

class MockRealEstateNotificationRepository
    implements RealEstateNotificationRepository {
  final List<AppNotification> _notificationsStore = [
    AppNotification(
      id: 'notif-re-1',
      sectionId: 'real_estate',
      type: 'price_drop',
      title: 'انخفاض سعر عقار مفضل!',
      body: 'تم تخفيض سعر الشقة التي فضلتها في طنطا بمقدار 200,000 ج.م.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      targetId: 'aqar-3',
      targetRoute: '/real-estate/detail?id=aqar-3',
    ),
    AppNotification(
      id: 'notif-re-2',
      sectionId: 'real_estate',
      type: 'saved_search',
      title: 'عقار جديد مطابق لبحثك المحفوظ',
      body: 'تم إضافة شقة للبيع في منطقة سيجر بمواصفات مطابقة لتفضيلاتك.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      targetId: 'aqar-2',
      targetRoute: '/real-estate/detail?id=aqar-2',
    ),
    AppNotification(
      id: 'notif-re-3',
      sectionId: 'real_estate',
      type: 'status_update',
      title: 'تحديث حالة العقار',
      body: 'تم تأكيد طلب معاينة الشقة المفروشة بالقرب من جامعة طنطا.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      targetId: 'aqar-4',
      targetRoute: '/real-estate/detail?id=aqar-4',
    ),
  ];

  @override
  Future<List<AppNotification>> getRealEstateNotifications({
    String? userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
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
