import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/category_detail_controller.dart';
import '../../widgets/category_detail/category_detail_header.dart';
import '../../widgets/category_detail/category_filter_chips_bar.dart';
import '../../widgets/category_detail/category_price_banner.dart';
import '../../widgets/category_detail/category_products_grid.dart';

class BuildingMaterialCategoryDetailPage extends StatefulWidget {
  final String categoryId;
  final CategoryDetailController? controller;

  const BuildingMaterialCategoryDetailPage({
    super.key,
    required this.categoryId,
    this.controller,
  });

  @override
  State<BuildingMaterialCategoryDetailPage> createState() =>
      _BuildingMaterialCategoryDetailPageState();
}

class _BuildingMaterialCategoryDetailPageState
    extends State<BuildingMaterialCategoryDetailPage> {
  late final CategoryDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        CategoryDetailController(categoryId: widget.categoryId);
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
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: ValueListenableBuilder<CategoryDetailState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return AppErrorView(
                  title: 'خطأ في تحميل تفاصيل القسم',
                  message: state.errorMessage!,
                  onRetry: _controller.loadData,
                );
              }

              final detail = state.categoryDetail;
              if (detail == null) {
                return const AppEmptyState(
                  title: 'القسم غير متاح',
                  message: 'يرجى العودة واختيار قسم آخر',
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
                    // 1. Header
                    SliverToBoxAdapter(
                      child: CategoryDetailHeader(
                        title: detail.title,
                        subtitle: detail.subtitle,
                        onBackTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),

                    // 2. Filter Chips
                    if (detail.filterChips.isNotEmpty)
                      SliverToBoxAdapter(
                        child: CategoryFilterChipsBar(
                          filterChips: detail.filterChips,
                          selectedFilter: state.selectedFilter,
                          onFilterSelected: (filter) =>
                              _controller.selectFilter(filter),
                        ),
                      ),

                    // 3. Category Daily Price Banner
                    SliverToBoxAdapter(
                      child: CategoryPriceBanner(
                        detail: detail,
                        onOrderTap: () => _showSnackBar(
                          'طلب توريد كمية من قسم ${detail.title}',
                        ),
                        onPriceLogTap: () => _showSnackBar(
                          'عرض سجل أسعار ${detail.title} اليومية',
                        ),
                      ),
                    ),

                    // 4. Products Grid
                    if (detail.products.isNotEmpty)
                      SliverToBoxAdapter(
                        child: CategoryProductsGrid(
                          products: detail.products,
                          onProductTap: (prod) =>
                              _showSnackBar('تفاصيل: ${prod.title}'),
                          onOrderTap: (prod) =>
                              _showSnackBar('طلب توريد: ${prod.title}'),
                          onViewAllTap: () => _showSnackBar(
                            'عرض جميع منتجات قسم ${detail.title}',
                          ),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(
                        child: AppEmptyState(
                          title: 'لا توجد منتجات لهذا الفلتر',
                          message: 'اختر تصنيفاً آخر لتصفح العروض والأسعار',
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
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
