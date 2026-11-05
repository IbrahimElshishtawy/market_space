import 'package:flutter/foundation.dart';

import 'package:market_space/core/notifications/data/models/app_notification.dart';
import 'package:market_space/features/home_appliances/notifications/data/repositories/home_appliances_notification_repository.dart';

class HomeAppliancesNotificationState {
  final bool isLoading;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? errorMessage;

  const HomeAppliancesNotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  HomeAppliancesNotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return HomeAppliancesNotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }
}

class HomeAppliancesNotificationController
    extends ValueNotifier<HomeAppliancesNotificationState> {
  final HomeAppliancesNotificationRepository repository;
  bool _isDisposed = false;

  HomeAppliancesNotificationController({
    HomeAppliancesNotificationRepository? repository,
  }) : repository = repository ?? MockHomeAppliancesNotificationRepository(),
       super(const HomeAppliancesNotificationState(isLoading: true)) {
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
      final list = await repository.getNotifications();
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
        errorMessage: 'فشل تحميل إشعارات الأجهزة: $e',
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
