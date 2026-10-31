import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../navigation/home_appliances_navigation_config.dart';
import '../../widgets/appliances_category_grid/appliances_category_grid.dart';
import '../../widgets/appliances_financing_banner/appliances_financing_banner.dart';
import '../../widgets/appliances_header/appliances_header.dart';
import '../../widgets/appliances_hero_banner/appliances_hero_banner.dart';
import '../../widgets/appliances_products_grid/appliances_products_grid.dart';
import '../../widgets/appliances_search_bar/appliances_search_bar.dart';
import '../controllers/home_appliances_controller.dart';

class HomeAppliancesPage extends StatefulWidget {
  final HomeAppliancesController? controller;

  const HomeAppliancesPage({super.key, this.controller});

  @override
  State<HomeAppliancesPage> createState() => _HomeAppliancesPageState();
}

class _HomeAppliancesPageState extends State<HomeAppliancesPage> {
  late final HomeAppliancesController _controller;
  int _tabIndex = 0;
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? HomeAppliancesController();
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

    final config = HomeAppliancesNavigationConfig.config;
    final item = config.items[index];

    if (item.id == 'ha-categories' ||
        item.destination == '/home-appliances/categories') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/home-appliances/categories');
      }
    } else if (item.id == 'ha-cart' ||
        item.destination == '/home-appliances/cart') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/home-appliances/cart');
      }
    } else if (item.id == 'ha-orders' ||
        item.destination == '/home-appliances/orders') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/home-appliances/orders');
      }
    } else if (item.id == 'ha-notifications' ||
        item.destination == '/home-appliances/notifications') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/home-appliances/notifications');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _openCategoryListing(String categoryId) {
    if (GoRouter.maybeOf(context) != null) {
      context.push(
        '${RouteNames.applianceCategoryListing}?categoryId=$categoryId',
      );
    } else {
      _controller.setCategoryFilter(categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<HomeAppliancesState>(
          valueListenable: _controller,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state.errorMessage != null) {
              return Center(
                child: AppErrorView(
                  message: state.errorMessage!,
                  onRetry: _controller.loadData,
                ),
              );
            }

            return NotificationListener<UserScrollNotification>(
              onNotification: _onUserScroll,
              child: RefreshIndicator(
                color: AppColors.neutral,
                onRefresh: _controller.loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Header Bar
                    SliverToBoxAdapter(
                      child: AppliancesHeader(
                        onNotificationTap: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.push('/home-appliances/notifications');
                          }
                        },
                        onCartTap: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.push('/home-appliances/cart');
                          }
                        },
                      ),
                    ),

                    // 2. Search & Filter Bar
                    SliverToBoxAdapter(
                      child: AppliancesSearchBar(
                        onChanged: _controller.setSearchQuery,
                        onFilterTap: _showFilterSheet,
                      ),
                    ),

                    // 3. Hero Promo Deal Banner
                    if (state.heroBanner != null)
                      SliverToBoxAdapter(
                        child: AppliancesHeroBanner(
                          banner: state.heroBanner!,
                          onCtaTap: () => _showSnackBar(
                            'جاري عرض العروض والتخفيضات اليومية',
                          ),
                        ),
                      ),

                    // 4. Category Grid (8 categories)
                    SliverToBoxAdapter(
                      child: AppliancesCategoryGrid(
                        categories: state.categories,
                        selectedCategoryId: state.filter.selectedCategoryId,
                        onCategoryTap: _openCategoryListing,
                        onViewAllTap: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.push('/home-appliances/categories');
                          }
                        },
                      ),
                    ),

                    // 5. ValU / Aman Financing Installment Banner
                    SliverToBoxAdapter(
                      child: AppliancesFinancingBanner(
                        onKnowLimitTap: () => _showSnackBar(
                          'جاري الاستعلام عن حد التقسيط المتاح مع ValU وأمان',
                        ),
                      ),
                    ),

                    // 6. Products Grid (Most requested items)
                    if (state.products.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppEmptyState(
                            title: 'لا توجد أجهزة مطابقة',
                            message: 'جرّب تغيير كلمات البحث أو الفئة لتصفح المزيد من الأجهزة',
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: AppliancesProductsGrid(
                          products: state.products,
                          onProductTap: (id) =>
                              _showSnackBar('تم فتح تفاصيل المنتج'),
                          onAddToCartTap: (id) {
                            _controller.toggleCart(id);
                            _showSnackBar('تمت إضافة المنتج إلى السلة بنجاح');
                          },
                          onViewAllTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.push('/home-appliances/categories');
                            }
                          },
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 90.0)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        config: HomeAppliancesNavigationConfig.config,
        currentIndex: _tabIndex,
        onTabSelected: _onTabSelected,
        notificationController: dependencies?.notificationController,
        isVisible: _isNavVisible,
        showFloatingAction: false,
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تصفية الأجهزة الكهربائية',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'تصفية حسب الماركة، السعر، مدة الضمان، أو نظام التقسيط.',
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('تطبيق الفلتر'),
              ),
            ],
          ),
        );
      },
    );
  }
}
