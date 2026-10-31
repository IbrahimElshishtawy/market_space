import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/profile/data/models/user_profile_model.dart';
import 'package:market_space/features/profile/data/repositories/profile_repository.dart';
import 'package:market_space/features/profile/presentation/controllers/profile_controller.dart';
import 'package:market_space/features/profile/presentation/pages/profile_page.dart';

void main() {
  group('Profile Controller & Page Tests', () {
    test('ProfileController loads profile data', () async {
      final repo = ProfileRepositoryImpl();
      final controller = ProfileController(repository: repo);
      await controller.loadProfileData();

      expect(controller.value.user, isNotNull);
      expect(controller.value.user!.fullName.isNotEmpty, isTrue);
      expect(controller.value.addresses.isNotEmpty, isTrue);
      expect(controller.value.notificationPreferences, isNotNull);
    });

    test('ProfileController updates personal info', () async {
      final repo = ProfileRepositoryImpl();
      final controller = ProfileController(repository: repo);
      await controller.loadProfileData();

      await controller.updateProfile(
        fullName: 'أحمد محمود',
        email: 'ahmed.m@example.com',
        phone: '01012345678',
        city: 'القاهرة',
      );

      expect(controller.value.user!.fullName, 'أحمد محمود');
      expect(controller.value.user!.email, 'ahmed.m@example.com');
      expect(controller.value.user!.city, 'القاهرة');
    });

    test('ProfileController adds and deletes saved address', () async {
      final repo = ProfileRepositoryImpl();
      final controller = ProfileController(repository: repo);
      await controller.loadProfileData();

      final initialCount = controller.value.addresses.length;
      final newAddr = SavedAddress(
        id: 'addr-test-${DateTime.now().millisecondsSinceEpoch}',
        title: 'موقع العمل الجديد',
        type: AddressType.work,
        addressLine: 'التجمع الخامس، القاهرة الجديدة',
        city: 'القاهرة',
        governorate: 'القاهرة',
      );

      await controller.addAddress(newAddr);
      expect(controller.value.addresses.length, initialCount + 1);

      await controller.deleteAddress(newAddr.id);
      expect(controller.value.addresses.length, initialCount);
    });

    test('ProfileController updates notification preferences', () async {
      final repo = ProfileRepositoryImpl();
      final controller = ProfileController(repository: repo);
      await controller.loadProfileData();

      const newPrefs = NotificationPreferences(
        orderUpdates: false,
        promotionalOffers: true,
        bookingUpdates: false,
        priceAlerts: false,
      );

      await controller.updateNotificationPreferences(newPrefs);
      expect(controller.value.notificationPreferences.orderUpdates, isFalse);
      expect(controller.value.notificationPreferences.promotionalOffers, isTrue);
      expect(controller.value.notificationPreferences.bookingUpdates, isFalse);
    });

    testWidgets('ProfilePage renders user profile, address section, and settings', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = ProfileRepositoryImpl();
      final controller = ProfileController(repository: repo);
      await controller.loadProfileData();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ProfilePage(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(controller.value.user!.fullName), findsOneWidget);
      expect(find.text('العناوين المحفوظة ومواقع المشاريع'), findsOneWidget);
      expect(find.text('طرق الدفع المعتمدة'), findsOneWidget);
      expect(find.text('تفضيلات الإشعارات'), findsOneWidget);
      expect(find.text('إعدادات التطبيق والمعلومات'), findsOneWidget);
    });
  });
}
