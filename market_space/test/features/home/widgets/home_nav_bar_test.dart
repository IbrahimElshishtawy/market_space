import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/home/widgets/home_nav_bar/home_nav_bar.dart';
import 'package:market_space/features/home/widgets/home_nav_bar/home_nav_bar_item.dart';

void main() {
  group('HomeNavBar Widget Tests', () {
    testWidgets('renders all 5 navigation bar items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(bottomNavigationBar: HomeNavBar(currentIndex: 0)),
        ),
      );

      expect(find.byType(HomeNavBar), findsOneWidget);
      expect(find.byType(HomeNavBarItem), findsNWidgets(5));

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('استكشف'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('المفضلة'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);
    });

    testWidgets('triggers onIndexChanged when a tab is tapped', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: HomeNavBar(
              currentIndex: 0,
              onIndexChanged: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      // Tap 'استكشف' (index 1)
      await tester.tap(find.text('استكشف'));
      await tester.pump();

      expect(selectedIndex, equals(1));

      // Tap 'حسابي' (index 4)
      await tester.tap(find.text('حسابي'));
      await tester.pump();

      expect(selectedIndex, equals(4));
    });

    testWidgets('respects isVisible property for animated slide transition', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: HomeNavBar(currentIndex: 0, isVisible: false),
          ),
        ),
      );

      final animatedSlide = tester.widget<AnimatedSlide>(
        find.descendant(
          of: find.byType(HomeNavBar),
          matching: find.byType(AnimatedSlide),
        ),
      );

      expect(animatedSlide.offset, equals(const Offset(0, 1.8)));
    });
  });
}
