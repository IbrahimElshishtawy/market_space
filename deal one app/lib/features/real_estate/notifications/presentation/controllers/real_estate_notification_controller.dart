import 'package:flutter/foundation.dart';

import 'package:market_space/core/notifications/data/models/app_notification.dart';
import 'package:market_space/features/real_estate/notifications/data/repositories/real_estate_notification_repository.dart';

class RealEstateNotificationState {
  final bool isLoading;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? errorMessage;

  const RealEstateNotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  RealEstateNotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return RealEstateNotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }
}

class RealEstateNotificationController
    extends ValueNotifier<RealEstateNotificationState> {
  final RealEstateNotificationRepository repository;
  bool _isDisposed = false;

  RealEstateNotificationController({
    RealEstateNotificationRepository? repository,
  }) : repository = repository ?? MockRealEstateNotificationRepository(),
       super(const RealEstateNotificationState(isLoading: true)) {
    loadNotifications();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadNotifications() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await repository.getRealEstateNotifications();
      if (_isDisposed) return;
      final unread = list.where((n) => !n.isRead).length;
      value = value.copyWith(
        isLoading: false,
        notifications: list,
        unreadCount: unread,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل إشعارات العقارات: $e',
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_isDisposed) return;
    await repository.markAsRead(notificationId);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    if (_isDisposed) return;
    await repository.markAllAsRead();
    await loadNotifications();
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_isDisposed) return;
    await repository.deleteNotification(notificationId);
    await loadNotifications();
  }
}
