import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/notifications/data/repositories/notification_repository.dart';
import 'package:market_space/core/notifications/presentation/state/notification_controller.dart';
import 'package:market_space/features/notifications/presentation/pages/global_notifications_page.dart';

void main() {
  group('Global Notifications Controller & Page Tests', () {
    test('NotificationController provides unread counts and notifications', () {
      final repo = NotificationRepositoryImpl();
      final controller = NotificationController(repository: repo);

      final reNotifs = controller.getNotifications('real_estate');
      expect(reNotifs.isNotEmpty, isTrue);

      final unread = controller.getUnreadCount('real_estate');
      expect(unread, greaterThanOrEqualTo(0));
    });

    test('NotificationController marks notification as read', () {
      final repo = NotificationRepositoryImpl();
      final controller = NotificationController(repository: repo);

      final reNotifs = controller.getNotifications('real_estate');
      final first = reNotifs.first;
      controller.markAsRead(first.id);

      final updated = controller.getNotifications('real_estate');
      expect(updated.firstWhere((n) => n.id == first.id).isRead, isTrue);
    });

    testWidgets('GlobalNotificationsPage renders title, filter tabs, and items', (tester) async {
      final repo = NotificationRepositoryImpl();
      final controller = NotificationController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: GlobalNotificationsPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الإشعارات والتنبيهات'), findsOneWidget);
      expect(find.text('تحديد الكل كمقروء'), findsOneWidget);
      expect(find.text('الكل'), findsWidgets);
      expect(find.text('العقارات'), findsWidgets);
      expect(find.text('مواد البناء'), findsWidgets);
      expect(find.text('الخدمات المنزلية'), findsWidgets);
      expect(find.text('الأجهزة المنزلية'), findsWidgets);
    });
  });
}
