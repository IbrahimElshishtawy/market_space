import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import 'package:market_space/core/routing/route_names.dart';
import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/core/theme/app_spacing.dart';
import 'package:market_space/features/home_appliances/data/mock/mock_home_appliances_data.dart';
import 'package:market_space/features/home_appliances/navigation/home_appliances_navigation_config.dart';
import 'package:market_space/features/home_appliances/widgets/appliances_search_bar/appliances_search_bar.dart';

class HomeAppliancesCategoriesPage extends StatefulWidget {
  const HomeAppliancesCategoriesPage({super.key});

  @override
  State<HomeAppliancesCategoriesPage> createState() =>
      _HomeAppliancesCategoriesPageState();
}

class _HomeAppliancesCategoriesPageState
    extends State<HomeAppliancesCategoriesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);
    final categories = MockHomeAppliancesData.categories.where((cat) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return cat.title.toLowerCase().contains(q);
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: Text(
            'أقسام الأجهزة المنزلية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          elevation: 0.5,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
        ),
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AppliancesSearchBar(
                    onChanged: (q) => setState(() => _searchQuery = q),
                    onFilterTap: () {},
                  ),
                ),
              ),

              // Categories Grid
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final cat = categories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: AppRadii.lg,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 6.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: AppRadii.lg,
                        child: InkWell(
                          onTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.push(
                                '${RouteNames.applianceCategoryListing}?categoryId=${cat.id}',
                              );
                            }
                          },
                          borderRadius: AppRadii.lg,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat.iconData,
                                    size: 28.0,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  cat.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                                  ),
                                ),
                                if (cat.itemCount != null) ...[
                                  const SizedBox(height: 2.0),
                                  Text(
                                    '${cat.itemCount} أجهزة',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: categories.length),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 90.0)),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: HomeAppliancesNavigationConfig.config,
          currentIndex: 1, // 2nd tab is "الأقسام"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.homeAppliances);
            } else if (index == 2 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/cart');
            } else if (index == 3 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/orders');
            } else if (index == 4 && GoRouter.maybeOf(context) != null) {
              context.push('/home-appliances/notifications');
            }
          },
          notificationController: dependencies?.notificationController,
          isVisible: true,
        ),
      ),
    );
  }
}
