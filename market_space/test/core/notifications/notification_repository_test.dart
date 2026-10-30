import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/notifications/data/models/app_notification.dart';
import 'package:market_space/core/notifications/data/repositories/notification_repository.dart';

void main() {
  group('NotificationRepository Unit Tests', () {
    late NotificationRepository repository;

    setUp(() {
      repository = NotificationRepositoryImpl();
    });

    test(
      'filters notifications by section ID without leaking across sections',
      () {
        final realEstateNotifs = repository.getNotificationsForSection(
          'real_estate',
        );
        final buildingMaterialNotifs = repository.getNotificationsForSection(
          'building_materials',
        );

        expect(
          realEstateNotifs.every((n) => n.sectionId == 'real_estate'),
          isTrue,
        );
        expect(
          buildingMaterialNotifs.every(
            (n) => n.sectionId == 'building_materials',
          ),
          isTrue,
        );
      },
    );

    test('calculates correct unread count per section', () {
      expect(repository.getUnreadCountForSection('real_estate'), equals(3));
      expect(
        repository.getUnreadCountForSection('building_materials'),
        equals(5),
      );
      expect(repository.getUnreadCountForSection('services'), equals(1));
      expect(repository.getUnreadCountForSection('home_appliances'), equals(0));
    });

    test(
      'marking notification as read decreases unread count for its section',
      () {
        final realEstateNotifs = repository.getNotificationsForSection(
          'real_estate',
        );
        final firstNotif = realEstateNotifs.first;

        repository.markAsRead(firstNotif.id);

        expect(repository.getUnreadCountForSection('real_estate'), equals(2));
        // Unrelated section unread count remains unchanged
        expect(
          repository.getUnreadCountForSection('building_materials'),
          equals(5),
        );
      },
    );

    test(
      'marking all as read clears unread count for specific section only',
      () {
        repository.markAllAsReadForSection('building_materials');

        expect(
          repository.getUnreadCountForSection('building_materials'),
          equals(0),
        );
        expect(repository.getUnreadCountForSection('real_estate'), equals(3));
      },
    );

    test('adding new notification updates unread counts reactively', () {
      final newNotif = AppNotification(
        id: 'new-1',
        sectionId: 'home_appliances',
        type: 'discount',
        title: 'عرض جديد على التكييفات',
        body: 'خصم 20% لفترة محدودة',
        createdAt: DateTime.now(),
        isRead: false,
      );

      repository.addNotification(newNotif);

      expect(repository.getUnreadCountForSection('home_appliances'), equals(1));
    });
  });
}
