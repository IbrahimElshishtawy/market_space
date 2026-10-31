import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../activity/presentation/pages/my_activity_page.dart';
import '../../../explore/presentation/pages/explore_page.dart';
import '../../../favorites/presentation/pages/global_favorites_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../home/widgets/home_nav_bar/home_nav_bar.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class GlobalNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const GlobalNavigationScaffold({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<GlobalNavigationScaffold> createState() => _GlobalNavigationScaffoldState();
}

class _GlobalNavigationScaffoldState extends State<GlobalNavigationScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavIndexChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomePage(showBottomNav: false),
            ExplorePage(),
            MyActivityPage(),
            GlobalFavoritesPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: HomeNavBar(
          currentIndex: _currentIndex,
          onIndexChanged: _onNavIndexChanged,
          isVisible: true,
        ),
      ),
    );
  }
}
