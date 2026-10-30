import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/navigation/config/section_navigation_registry.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/navigation_tab_item.dart';
import 'package:market_space/core/notifications/data/repositories/notification_repository.dart';
import 'package:market_space/core/notifications/presentation/state/notification_controller.dart';
import 'package:market_space/features/building_materials/navigation/building_materials_navigation_config.dart';
import 'package:market_space/features/real_estate/navigation/real_estate_navigation_config.dart';

void main() {
  group('Multi-Section Navigation Configurations', () {
    test('All 4 section configurations have exactly 5 items', () {
      final configs = SectionNavigationRegistry.allConfigs;
      expect(configs.length, equals(4));

      for (final config in configs) {
        expect(config.items.length, equals(5));
      }
    });

    test('All 4 section configurations include FloatingActionConfig for adding listings', () {
      for (final config in SectionNavigationRegistry.allConfigs) {
        expect(config.floatingAction, isNotNull);
        expect(config.floatingAction!.label, contains('أضف'));
      }
    });
  });

  group('AppBottomNavigation Widget Tests', () {
    testWidgets(
      'renders exactly 5 navigation tab items and FAB for Real Estate',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavigation(
                config: RealEstateNavigationConfig.config,
              ),
            ),
          ),
        );

        expect(find.byType(NavigationTabItem), findsNWidgets(5));
        expect(find.text('الرئيسية'), findsOneWidget);
        expect(find.text('الريلز'), findsOneWidget);
        expect(find.text('الخريطة'), findsOneWidget);
        expect(find.text('المفضلة'), findsOneWidget);
        expect(find.text('الإشعارات'), findsOneWidget);
        expect(find.text('أضف عقارك'), findsOneWidget);
      },
    );

    testWidgets('renders 5 items and generic FAB for Building Materials', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              config: BuildingMaterialsNavigationConfig.config,
            ),
          ),
        ),
      );

      expect(find.byType(NavigationTabItem), findsNWidgets(5));
      expect(find.text('أضف إعلانك'), findsOneWidget);
      expect(find.text('السلة'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
    });

    testWidgets('displays correct section-isolated unread notification badge', (
      WidgetTester tester,
    ) async {
      final repository = NotificationRepositoryImpl();
      final controller = NotificationController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              config: RealEstateNavigationConfig.config,
              notificationController: controller,
            ),
          ),
        ),
      );

      // Real Estate has 3 unread notifications in mock dataset
      expect(find.text('3'), findsOneWidget);
    });
  });
}
