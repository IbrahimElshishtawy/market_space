import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../navigation/building_materials_navigation_config.dart';
import '../controllers/building_materials_controller.dart';
import '../../widgets/categories_grid/categories_grid.dart';
import '../../widgets/contractor_projects_banner/contractor_projects_banner.dart';
import '../../widgets/daily_price_banner/daily_price_banner.dart';
import '../../widgets/header/building_materials_header.dart';
import '../../widgets/most_requested_materials/most_requested_materials_grid.dart';
import '../../widgets/search_bar/building_materials_search_bar.dart';

class BuildingMaterialsPage extends StatefulWidget {
  final BuildingMaterialsController? controller;

  const BuildingMaterialsPage({super.key, this.controller});

  @override
  State<BuildingMaterialsPage> createState() => _BuildingMaterialsPageState();
}

class _BuildingMaterialsPageState extends State<BuildingMaterialsPage> {
  late final BuildingMaterialsController _controller;
  int _tabIndex = 0;
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? BuildingMaterialsController();
    _controller.loadData();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
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

    if (GoRouter.maybeOf(context) == null) return;

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        context.push(RouteNames.buildingMaterialsCategories);
        break;
      case 2:
        context.push(RouteNames.buildingMaterialsCart);
        break;
      case 3:
        context.push(RouteNames.buildingMaterialsOrders);
        break;
      case 4:
        context.push(RouteNames.buildingMaterialsNotifications);
        break;
    }
  }

  Future<void> _handleRefresh() async {
    await _controller.loadData();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<BuildingMaterialsState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return AppErrorView(
                  title: 'خطأ في تحميل البيانات',
                  message: state.errorMessage!,
                  onRetry: _controller.loadData,
                );
              }

              return NotificationListener<UserScrollNotification>(
                onNotification: _onUserScroll,
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _handleRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // 1. Header (User Info, Cart, Notifications)
                      SliverToBoxAdapter(
                        child: BuildingMaterialsHeader(
                          onAvatarTap: () => _showSnackBar('الملف الشخصي'),
                          onCartTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.push(RouteNames.buildingMaterialsCart);
                            }
                          },
                          onNotificationsTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.push(
                                RouteNames.buildingMaterialsNotifications,
                              );
                            }
                          },
                        ),
                      ),

                      // 2. Search & Filter Bar
                      SliverToBoxAdapter(
                        child: BuildingMaterialsSearchBar(
                          onChanged: (query) =>
                              _controller.setSearchQuery(query),
                          onFilterTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.push(
                                RouteNames.buildingMaterialsCategories,
                              );
                            }
                          },
                        ),
                      ),

                      // 3. Hero Daily Price Banner ("تحديث يومي")
                      if (state.dailyPriceBanner != null)
                        SliverToBoxAdapter(
                          child: DailyPriceBanner(
                            banner: state.dailyPriceBanner!,
                            onOrderTap: () {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(
                                  '${RouteNames.buildingMaterialsProductDetail}?productId=prod-cement-swe-ord',
                                );
                              }
                            },
                          ),
                        ),

                      // 4. Building Materials Categories Grid
                      if (state.categories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: CategoriesGrid(
                            categories: state.categories,
                            selectedCategoryId: state.selectedCategoryId,
                            onCategoryTap: (cat) {
                              _controller.selectCategory(cat.id);
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(
                                  '${RouteNames.buildingMaterialsCategories}?categoryId=${cat.id}',
                                );
                              }
                            },
                            onViewAllTap: () {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(
                                  RouteNames.buildingMaterialsCategories,
                                );
                              }
                            },
                          ),
                        ),

                      // 5. Most Requested Materials Grid
                      if (state.mostRequestedProducts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: MostRequestedMaterialsGrid(
                            products: state.mostRequestedProducts,
                            onProductTap: (prod) {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(
                                  '${RouteNames.buildingMaterialsProductDetail}?productId=${prod.id}',
                                );
                              }
                            },
                            onOrderTap: (prod) {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(
                                  '${RouteNames.buildingMaterialsProductDetail}?productId=${prod.id}',
                                );
                              }
                            },
                            onViewAllTap: () {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(
                                  RouteNames.buildingMaterialsCategories,
                                );
                              }
                            },
                          ),
                        )
                      else if (!state.isLoading)
                        const SliverToBoxAdapter(
                          child: AppEmptyState(
                            title: 'لا توجد خامات متاحة',
                            message: 'جرّب البحث عن مواد بناء أخرى',
                          ),
                        ),

                      // 6. Contractor Projects Banner
                      if (state.contractorBanner != null)
                        SliverToBoxAdapter(
                          child: ContractorProjectsBanner(
                            banner: state.contractorBanner!,
                            onRequestQuoteTap: () {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(RouteNames.buildingMaterialsRfq);
                              }
                            },
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 140.0)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: BuildingMaterialsNavigationConfig.config,
          currentIndex: _tabIndex,
          onTabSelected: _onTabSelected,
          notificationController: dependencies?.notificationController,
          isVisible: _isNavVisible,
        ),
      );
  }
}
