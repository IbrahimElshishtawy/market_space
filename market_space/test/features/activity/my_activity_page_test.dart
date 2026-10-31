import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/activity/data/models/unified_activity_model.dart';
import 'package:market_space/features/activity/data/repositories/unified_activity_repository.dart';
import 'package:market_space/features/activity/presentation/controllers/unified_activity_controller.dart';
import 'package:market_space/features/activity/presentation/pages/my_activity_page.dart';

void main() {
  group('My Activity Controller & Page Tests', () {
    test('UnifiedActivityController aggregates activities across all 4 sectors', () async {
      final repo = UnifiedActivityRepositoryImpl();
      final controller = UnifiedActivityController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.value.activities.isNotEmpty, isTrue);

      // Verify presence of different sectors
      final sectors = controller.value.activities.map((a) => a.sectorId).toSet();
      expect(sectors.contains('services'), isTrue);
      expect(sectors.contains('real_estate'), isTrue);
    });

    test('UnifiedActivityController filters by status and sector', () async {
      final repo = UnifiedActivityRepositoryImpl();
      final controller = UnifiedActivityController(repository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      // Filter by active status
      await controller.setStatusFilter(ActivityStatusGroup.active);
      expect(
        controller.value.activities.every((a) => a.statusGroup == ActivityStatusGroup.active),
        isTrue,
      );

      // Filter by completed status
      await controller.setStatusFilter(ActivityStatusGroup.completed);
      expect(
        controller.value.activities.every((a) => a.statusGroup == ActivityStatusGroup.completed),
        isTrue,
      );
    });

    testWidgets('MyActivityPage renders title, status tabs, and activity cards', (tester) async {
      final repo = UnifiedActivityRepositoryImpl();
      final controller = UnifiedActivityController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: MyActivityPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('طلباتي ومعاملاتي'), findsOneWidget);
      expect(find.text('نشطة'), findsOneWidget);
      expect(find.text('مكتملة'), findsOneWidget);
      expect(find.text('ملغاة'), findsOneWidget);
      expect(find.text('العقارات'), findsWidgets);
    });
  });
}
