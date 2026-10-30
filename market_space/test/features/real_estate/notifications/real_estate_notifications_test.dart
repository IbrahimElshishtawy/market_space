import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/notifications/presentation/controllers/real_estate_notification_controller.dart';
import 'package:market_space/features/real_estate/notifications/presentation/pages/real_estate_notifications_page.dart';
import 'package:market_space/features/real_estate/notifications/presentation/widgets/real_estate_notification_item.dart';

void main() {
  group('Real Estate Notification Controller Tests', () {
    late RealEstateNotificationController controller;

    setUp(() {
      controller = RealEstateNotificationController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('loadNotifications calculates unread count correctly', () async {
      await controller.loadNotifications();

      expect(controller.value.isLoading, isFalse);
      expect(controller.value.notifications.length, equals(3));
      expect(controller.value.unreadCount, equals(2));
    });

    test('markAsRead updates item read status', () async {
      await controller.loadNotifications();

      final firstNotif = controller.value.notifications.first;
      await controller.markAsRead(firstNotif.id);

      expect(controller.value.unreadCount, equals(1));
    });

    test('markAllAsRead marks all notifications as read', () async {
      await controller.loadNotifications();

      await controller.markAllAsRead();

      expect(controller.value.unreadCount, equals(0));
    });
  });

  group('Real Estate Notifications Page Widget Tests', () {
    testWidgets(
      'renders RealEstateNotificationsPage, items and mark all action',
      (WidgetTester tester) async {
        final controller = RealEstateNotificationController();

        await tester.pumpWidget(
          MaterialApp(
            home: RealEstateNotificationsPage(controller: controller),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(RealEstateNotificationsPage), findsOneWidget);
        expect(find.text('إشعارات العقارات'), findsOneWidget);
        expect(find.text('تحديد الكل كقراءة'), findsOneWidget);
        expect(find.byType(RealEstateNotificationItem), findsNWidgets(3));
      },
    );
  });
}
