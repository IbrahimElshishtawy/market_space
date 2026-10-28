import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/building_materials_controller.dart';
import '../../widgets/categories_grid/categories_grid.dart';
import '../../widgets/contractor_projects_banner/contractor_projects_banner.dart';
import '../../widgets/daily_price_banner/daily_price_banner.dart';
import '../../widgets/header/building_materials_header.dart';
import '../../widgets/most_requested_materials/most_requested_materials_grid.dart';
import '../../widgets/search_bar/building_materials_search_bar.dart';

class BuildingMaterialsPage extends StatefulWidget {
  final BuildingMaterialsController? controller;

  const BuildingMaterialsPage({
    super.key,
    this.controller,
  });

  @override
  State<BuildingMaterialsPage> createState() => _BuildingMaterialsPageState();
}

class _BuildingMaterialsPageState extends State<BuildingMaterialsPage> {
  late final BuildingMaterialsController _controller;

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

  Future<void> _handleRefresh() async {
    await _controller.loadData();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
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

              return RefreshIndicator(
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
                        onCartTap: () => _showSnackBar('سلة المشتريات'),
                        onNotificationsTap: () =>
                            _showSnackBar('التنبيهات الإشعارات'),
                      ),
                    ),

                    // 2. Search & Filter Bar
                    SliverToBoxAdapter(
                      child: BuildingMaterialsSearchBar(
                        onChanged: (query) =>
                            _controller.setSearchQuery(query),
                        onFilterTap: () => _showSnackBar('فتح تصفية المواد'),
                      ),
                    ),

                    // 3. Hero Daily Price Banner ("تحديث يومي")
                    if (state.dailyPriceBanner != null)
                      SliverToBoxAdapter(
                        child: DailyPriceBanner(
                          banner: state.dailyPriceBanner!,
                          onOrderTap: () =>
                              _showSnackBar('طلب كمية أسمنت بسعر اليوم'),
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
                            if (cat.id == 'cat-steel' ||
                                cat.title.contains('حديد')) {
                              if (GoRouter.maybeOf(context) != null) {
                                context.push(RouteNames.steelRebarListing);
                              } else {
                                _showSnackBar('قسم: ${cat.title}');
                              }
                            } else {
                              _showSnackBar('قسم: ${cat.title}');
                            }
                          },
                          onViewAllTap: () =>
                              _showSnackBar('عرض جميع أقسام مواد البناء'),
                        ),
                      ),

                    // 5. Most Requested Materials Grid
                    if (state.mostRequestedProducts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: MostRequestedMaterialsGrid(
                          products: state.mostRequestedProducts,
                          onProductTap: (prod) =>
                              _showSnackBar('تفاصيل: ${prod.title}'),
                          onOrderTap: (prod) =>
                              _showSnackBar('طلب توريد: ${prod.title}'),
                          onViewAllTap: () =>
                              _showSnackBar('عرض جميع الخامات الأكثر طلباً'),
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
                          onRequestQuoteTap: () =>
                              _showSnackBar('طلب مقايسة خاصة بمشروعك'),
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24.0),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
