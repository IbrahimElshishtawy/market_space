import 'package:flutter/material.dart';
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

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {});
    }
  }

  void _onCategorySelected(HomeCategoryData category) {
    if (category.id == 'cat-real-estate' || category.title == 'عقارات') {
      context.push(RouteNames.realEstate);
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
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
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
                    onSearchTap: () => context.push(RouteNames.realEstate),
                  ),
                ),

                // 3. Hero Carousel Banner
                SliverToBoxAdapter(
                  child: HeroCarousel(
                    banners: _banners,
                    onCtaTap: () => context.push(RouteNames.realEstate),
                  ),
                ),

                // 4. Main Categories Section
                SliverToBoxAdapter(
                  child: MainCategoriesSection(
                    categories: _categories,
                    onCategoryTap: _onCategorySelected,
                    onViewAllTap: () => context.push(RouteNames.realEstate),
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

                const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
