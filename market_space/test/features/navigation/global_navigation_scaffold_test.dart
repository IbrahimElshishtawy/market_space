import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/activity/presentation/pages/my_activity_page.dart';
import 'package:market_space/features/explore/presentation/pages/explore_page.dart';
import 'package:market_space/features/favorites/presentation/pages/global_favorites_page.dart';
import 'package:market_space/features/home/presentation/pages/home_page.dart';
import 'package:market_space/features/home/widgets/home_nav_bar/home_nav_bar.dart';
import 'package:market_space/features/navigation/presentation/pages/global_navigation_scaffold.dart';
import 'package:market_space/features/profile/presentation/pages/profile_page.dart';

void main() {
  group('GlobalNavigationScaffold Widget Tests', () {
    testWidgets('renders all 5 tabs and floating bottom navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalNavigationScaffold(initialIndex: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Home NavBar should be present
      expect(find.byType(HomeNavBar), findsOneWidget);
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('استكشف'), findsOneWidget);
      expect(find.text('طلباتي'), findsOneWidget);
      expect(find.text('المفضلة'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Verify HomePage is in IndexedStack
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('switching tabs updates active page in IndexedStack without rebuilding state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GlobalNavigationScaffold(initialIndex: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Explore tab
      await tester.tap(find.text('استكشف'));
      await tester.pumpAndSettle();
      expect(find.byType(ExplorePage), findsOneWidget);

      // Tap My Activity tab
      await tester.tap(find.text('طلباتي'));
      await tester.pumpAndSettle();
      expect(find.byType(MyActivityPage), findsOneWidget);

      // Tap Favorites tab
      await tester.tap(find.text('المفضلة'));
      await tester.pumpAndSettle();
      expect(find.byType(GlobalFavoritesPage), findsOneWidget);

      // Tap Profile tab
      await tester.tap(find.text('حسابي'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      // Tap Home tab to return
      await tester.tap(find.text('الرئيسية'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
