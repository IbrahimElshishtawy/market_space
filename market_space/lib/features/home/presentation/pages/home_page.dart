import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock/mock_home_data.dart';
import '../../data/models/hero_banner_data.dart';
import '../../data/models/home_category_data.dart';
import '../../data/models/home_header_data.dart';
import '../../data/models/home_service_data.dart';
import '../../widgets/hero_carousel/hero_carousel.dart';
import '../../widgets/home_header/home_header.dart';
import '../../widgets/home_nav_bar/home_nav_bar.dart';
import '../../widgets/home_search_bar/home_search_bar.dart';
import '../../widgets/main_categories/main_categories_section.dart';
import '../../widgets/most_requested_services/most_requested_services_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeHeaderData _headerData = MockHomeData.headerData;
  final List<HeroBannerData> _banners = MockHomeData.heroBanners;
  final List<HomeCategoryData> _categories = MockHomeData.categories;
  final List<HomeServiceData> _services = MockHomeData.mostRequestedServices;

  int _navIndex = 0;
  bool _isNavBarVisible = true;

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = false;
        });
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
        });
      }
    }
    return false;
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {});
    }
  }

  void _onNavIndexChanged(int index) {
    setState(() {
      _navIndex = index;
    });

    if (index != 0) {
      final tabNames = ['الرئيسية', 'استكشف', 'طلباتي', 'المفضلة', 'حسابي'];
      final tabName = index < tabNames.length ? tabNames[index] : '';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تبويب $tabName قيد التصفح حالياً'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _onCategorySelected(HomeCategoryData category) {
    if (category.id == 'cat-real-estate' || category.title == 'عقارات') {
      context.push(RouteNames.realEstate);
    } else if (category.id == 'cat-appliances' ||
        category.title.contains('أجهزة') ||
        category.title.contains('كهربائية')) {
      context.push(RouteNames.homeAppliances);
    } else if (category.id == 'cat-building-materials' ||
        category.title.contains('مواد') ||
        category.title.contains('بناء') ||
        category.title.contains('مونة') ||
        category.title.contains('أسمنت')) {
      context.push(RouteNames.buildingMaterials);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('قسم: ${category.title} قيد التطوير حالياً'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: NotificationListener<UserScrollNotification>(
            onNotification: _onUserScroll,
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _handleRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Header Bar
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      data: _headerData,
                      onAvatarTap: () {},
                      onCartTap: () {},
                      onNotificationsTap: () {},
                    ),
                  ),

                  // 2. Search Bar
                  SliverToBoxAdapter(
                    child: HomeSearchBar(
                      onFilterTap: () {},
                      onSearchTap: () =>
                          context.push(RouteNames.homeAppliances),
                    ),
                  ),

                  // 3. Hero Carousel Banner
                  SliverToBoxAdapter(
                    child: HeroCarousel(
                      banners: _banners,
                      onCtaTap: () => context.push(RouteNames.homeAppliances),
                    ),
                  ),

                  // 4. Main Categories Section
                  SliverToBoxAdapter(
                    child: MainCategoriesSection(
                      categories: _categories,
                      onCategoryTap: _onCategorySelected,
                      onViewAllTap: () =>
                          context.push(RouteNames.homeAppliances),
                    ),
                  ),

                  // 5. Most Requested Services Section
                  SliverToBoxAdapter(
                    child: MostRequestedServicesSection(
                      services: _services,
                      onServiceTap: (service) {},
                      onViewAllTap: () {},
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 140.0)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: HomeNavBar(
          currentIndex: _navIndex,
          onIndexChanged: _onNavIndexChanged,
          isVisible: _isNavBarVisible,
        ),
      ),
    );
  }
}
