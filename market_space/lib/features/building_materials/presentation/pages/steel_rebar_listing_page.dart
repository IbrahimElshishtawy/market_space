import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/steel_rebar_controller.dart';
import '../../widgets/steel_daily_price_banner/steel_daily_price_banner.dart';
import '../../widgets/steel_products_grid/steel_products_grid.dart';
import '../../widgets/steel_rebar_filter_chips/steel_rebar_filter_chips_bar.dart';
import '../../widgets/steel_rebar_header/steel_rebar_header.dart';

class SteelRebarListingPage extends StatefulWidget {
  final SteelRebarController? controller;

  const SteelRebarListingPage({super.key, this.controller});

  @override
  State<SteelRebarListingPage> createState() => _SteelRebarListingPageState();
}

class _SteelRebarListingPageState extends State<SteelRebarListingPage> {
  late final SteelRebarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SteelRebarController();
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
          child: ValueListenableBuilder<SteelRebarState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return AppErrorView(
                  title: 'خطأ في تحميل أسعار وواردات الحديد',
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
                    // 1. Steel Header Section
                    SliverToBoxAdapter(
                      child: SteelRebarHeader(
                        onBackTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),

                    // 2. Horizontal Size Filter Chips
                    if (state.availableSizes.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SteelRebarFilterChipsBar(
                          sizes: state.availableSizes,
                          selectedSize: state.selectedSize,
                          onSizeSelected: (size) =>
                              _controller.selectSize(size),
                        ),
                      ),

                    // 3. Daily Steel Price Banner
                    if (state.dailyPrice != null)
                      SliverToBoxAdapter(
                        child: SteelDailyPriceBanner(
                          dailyPrice: state.dailyPrice!,
                          onOrderTap: () =>
                              _showSnackBar('طلب توريد كمية حديد'),
                          onPriceLogTap: () =>
                              _showSnackBar('عرض سجل أسعار الحديد اليومية'),
                        ),
                      ),

                    // 4. Products Grid Section ("المنتجات المتاحة")
                    if (state.products.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SteelProductsGrid(
                          products: state.products,
                          onProductTap: (prod) =>
                              _showSnackBar('تفاصيل: ${prod.title}'),
                          onOrderTap: (prod) =>
                              _showSnackBar('طلب توريد: ${prod.title}'),
                          onViewAllTap: () =>
                              _showSnackBar('عرض جميع منتجات الحديد'),
                        ),
                      )
                    else
                      const SliverToBoxAdapter(
                        child: AppEmptyState(
                          title: 'لا توجد مصانع متاحة لهذا المقاس',
                          message: 'اختر مقاساً آخر لتصفح الأسعار',
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
