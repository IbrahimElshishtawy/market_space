import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/appliance_category_listing_controller.dart';
import '../../widgets/appliances_products_grid/appliance_product_card.dart';
import '../../widgets/appliances_products_grid/appliances_products_grid_layout.dart';
import '../../widgets/category_filter_chips/category_filter_chips_bar.dart';
import '../../widgets/category_listing_header/category_listing_header.dart';

class ApplianceCategoryListingPage extends StatefulWidget {
  final String categoryId;
  final ApplianceCategoryListingController? controller;

  const ApplianceCategoryListingPage({
    super.key,
    required this.categoryId,
    this.controller,
  });

  @override
  State<ApplianceCategoryListingPage> createState() =>
      _ApplianceCategoryListingPageState();
}

class _ApplianceCategoryListingPageState
    extends State<ApplianceCategoryListingPage> {
  late final ApplianceCategoryListingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ApplianceCategoryListingController();
    _controller.loadCategory(widget.categoryId);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
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
          child: ValueListenableBuilder<ApplianceCategoryListingState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null || state.categoryDetail == null) {
                return Center(
                  child: AppErrorView(
                    message:
                        state.errorMessage ??
                        'لم يتم العثور على أجهزة لهذه الفئة',
                    onRetry: () => _controller.loadCategory(widget.categoryId),
                  ),
                );
              }

              final detail = state.categoryDetail!;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.loadCategory(widget.categoryId),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Category Title Header Bar
                    SliverToBoxAdapter(
                      child: CategoryListingHeader(
                        title: detail.title,
                        subtitle: detail.subtitle,
                        onBackTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.sm),
                    ),

                    // 2. Horizontal Filter Chips Bar (الكل, السعر, الحجم, الماركة)
                    SliverToBoxAdapter(
                      child: CategoryFilterChipsBar(
                        filterChips: detail.filterChips,
                        selectedChip: state.selectedChip,
                        onChipSelected: _controller.selectFilterChip,
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.md),
                    ),

                    // 3. Category Products 2-Column Grid
                    if (state.products.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppEmptyState(
                            title: 'لا توجد أجهزة مطابقة',
                            message: 'جرّب إزالة الفلتر المطبق لمشاهدة جميع المنتجات',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = state.products[index];
                            return ApplianceProductCard(
                              product: product,
                              onTap: () =>
                                  _showSnackBar('عرض تفاصيل: ${product.title}'),
                              onAddToCartTap: () {
                                _controller.toggleCart(product.id);
                                _showSnackBar('تحديث حالة السلة للمنتج');
                              },
                            );
                          }, childCount: state.products.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    AppliancesProductsGridLayout.crossAxisCount,
                                mainAxisSpacing:
                                    AppliancesProductsGridLayout.gridSpacing,
                                crossAxisSpacing:
                                    AppliancesProductsGridLayout.gridSpacing,
                                childAspectRatio: AppliancesProductsGridLayout
                                    .childAspectRatio,
                              ),
                        ),
                      ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xl),
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
