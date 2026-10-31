import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:market_space/features/home_services/presentation/views/home_services_notifications_view.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../navigation/home_services_navigation_config.dart';
import '../views/home_services_bookings_view.dart';
import '../views/home_services_catalog_view.dart';
import '../views/home_services_favorites_view.dart';
import '../views/home_services_home_view.dart';

class HomeServicesPage extends StatefulWidget {
  final int initialTabIndex;

  const HomeServicesPage({super.key, this.initialTabIndex = 0});

  @override
  State<HomeServicesPage> createState() => _HomeServicesPageState();
}

class _HomeServicesPageState extends State<HomeServicesPage> {
  late int _tabIndex;
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex;
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isNavVisible) {
        setState(() {
          _isNavVisible = false;
        });
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isNavVisible) {
        setState(() {
          _isNavVisible = true;
        });
      }
    }
    return false;
  }

  void _onTabSelected(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void _switchTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.neutral,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
              ),
              tooltip: 'الموقع الحالي: القاهرة',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'المنطقة المحددة لخدمات الصيانة: القاهرة الكبرى',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: NotificationListener<UserScrollNotification>(
            onNotification: _onUserScroll,
            child: IndexedStack(
              index: _tabIndex,
              children: [
                // Tab 0: Home View
                HomeServicesHomeView(onExploreServicesTap: () => _switchTab(1)),
                // Tab 1: Catalog View
                const HomeServicesCatalogView(),
                // Tab 2: Bookings View
                HomeServicesBookingsView(
                  onExploreServicesTap: () => _switchTab(1),
                ),
                // Tab 3: Favorites View
                HomeServicesFavoritesView(
                  onExploreServicesTap: () => _switchTab(1),
                ),
                // Tab 4: Notifications View
                const HomeServicesNotificationsView(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: HomeServicesNavigationConfig.config,
          currentIndex: _tabIndex,
          onTabSelected: _onTabSelected,
          onFloatingActionPressed: () {
            // Quick action to start new booking
            context.push('/home-services/book');
          },
          notificationController: dependencies?.notificationController,
          isVisible: _isNavVisible,
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_tabIndex) {
      case 0:
        return 'الخدمات المنزلية والصيانة';
      case 1:
        return 'دليل الخدمات والفنيين';
      case 2:
        return 'حجوزاتي';
      case 3:
        return 'المفضلة';
      case 4:
        return 'إشعارات الصيانة';
      default:
        return 'الخدمات المنزلية';
    }
  }
}
