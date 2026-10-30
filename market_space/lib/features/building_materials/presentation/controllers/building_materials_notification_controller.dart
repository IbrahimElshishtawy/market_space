import 'package:flutter/foundation.dart';

import '../../../../core/notifications/data/models/app_notification.dart';
import '../../../../core/notifications/data/repositories/notification_repository.dart';

enum BuildingMaterialsNotificationFilter {
  all('الكل'),
  unread('غير مقروءة'),
  orders('الطلبات والشحن'),
  pricesAndOffers('الأسعار والعروض'),
  suppliers('الموردين'),
  payments('المدفوعات');

  final String label;
  const BuildingMaterialsNotificationFilter(this.label);
}

class BuildingMaterialsNotificationState {
  final bool isLoading;
  final List<AppNotification> allNotifications;
  final BuildingMaterialsNotificationFilter activeFilter;
  final int unreadCount;
  final String? errorMessage;

  const BuildingMaterialsNotificationState({
    this.isLoading = false,
    this.allNotifications = const [],
    this.activeFilter = BuildingMaterialsNotificationFilter.all,
    this.unreadCount = 0,
    this.errorMessage,
  });

  List<AppNotification> get filteredNotifications {
    switch (activeFilter) {
      case BuildingMaterialsNotificationFilter.all:
        return allNotifications;
      case BuildingMaterialsNotificationFilter.unread:
        return allNotifications.where((n) => !n.isRead).toList();
      case BuildingMaterialsNotificationFilter.orders:
        return allNotifications
            .where((n) => n.type.contains('order') || n.type.contains('shipment'))
            .toList();
      case BuildingMaterialsNotificationFilter.pricesAndOffers:
        return allNotifications
            .where((n) => n.type.contains('price') || n.type.contains('offer'))
            .toList();
      case BuildingMaterialsNotificationFilter.suppliers:
        return allNotifications
            .where((n) => n.type.contains('supplier') || n.type.contains('rfq') || n.type.contains('quote'))
            .toList();
      case BuildingMaterialsNotificationFilter.payments:
        return allNotifications
            .where((n) => n.type.contains('payment') || n.type.contains('invoice'))
            .toList();
    }
  }

  BuildingMaterialsNotificationState copyWith({
    bool? isLoading,
    List<AppNotification>? allNotifications,
    BuildingMaterialsNotificationFilter? activeFilter,
    int? unreadCount,
    String? errorMessage,
  }) {
    return BuildingMaterialsNotificationState(
      isLoading: isLoading ?? this.isLoading,
      allNotifications: allNotifications ?? this.allNotifications,
      activeFilter: activeFilter ?? this.activeFilter,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }
}

class BuildingMaterialsNotificationController
    extends ValueNotifier<BuildingMaterialsNotificationState> {
  static const String sectionId = 'building_materials';
  final NotificationRepository repository;

  BuildingMaterialsNotificationController({NotificationRepository? repository})
    : repository = repository ?? NotificationRepositoryImpl(),
      super(const BuildingMaterialsNotificationState(isLoading: true)) {
    loadNotifications();
  }

  void loadNotifications() {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = repository.getNotificationsForSection(sectionId);
      final unread = repository.getUnreadCountForSection(sectionId);
      value = value.copyWith(
        isLoading: false,
        allNotifications: list,
        unreadCount: unread,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(BuildingMaterialsNotificationFilter filter) {
    value = value.copyWith(activeFilter: filter);
  }

  void markAsRead(String notificationId) {
    repository.markAsRead(notificationId);
    loadNotifications();
  }

  void markAllAsRead() {
    repository.markAllAsReadForSection(sectionId);
    loadNotifications();
  }
}
