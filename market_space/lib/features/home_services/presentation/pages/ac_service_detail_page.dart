import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../widgets/ac_filter_chips/ac_filter_chips_bar.dart';
import '../../widgets/ac_parts_grid/ac_parts_grid_section.dart';
import '../../widgets/ac_promo_banner/ac_promo_banner.dart';
import '../../widgets/ac_service_header/ac_service_header.dart';
import '../../widgets/ac_services_list/ac_services_list_section.dart';
import '../controllers/ac_service_controller.dart';

class AcServiceDetailPage extends StatefulWidget {
  final AcServiceController? controller;

  const AcServiceDetailPage({super.key, this.controller});

  @override
  State<AcServiceDetailPage> createState() => _AcServiceDetailPageState();
}

class _AcServiceDetailPageState extends State<AcServiceDetailPage> {
  late final AcServiceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AcServiceController();
    _controller.loadData();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
          child: ValueListenableBuilder<AcServiceState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading && state.promoBanner == null) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null && state.promoBanner == null) {
                return AppErrorView(
                  title: 'خطأ في تحميل الخدمات',
                  message: state.errorMessage!,
                  onRetry: _controller.loadData,
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _controller.loadData,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Header (Title, Subtitle, Back button)
                    SliverToBoxAdapter(
                      child: AcServiceHeader(
                        onBackTap: () => Navigator.of(context).maybePop(),
                      ),
                    ),

                    // 2. Filter Chips Bar (الكل, صيانة وتنظيف, شحن فريون)
                    if (state.filterChips.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AcFilterChipsBar(
                          chips: state.filterChips,
                          selectedChip: state.selectedFilter,
                          onChipSelected: (chip) =>
                              _controller.selectFilter(chip),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 6.0)),

                    // 3. Promo Hero Banner (15% Discount)
                    if (state.promoBanner != null)
                      SliverToBoxAdapter(
                        child: AcPromoBanner(
                          banner: state.promoBanner!,
                          onCtaTap: () =>
                              _showFeedback('تم تفعيل خصم 15% على طلبك'),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 4.0)),

                    // 4. Services List Section ("اختر الخدمة المناسبة")
                    if (state.services.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AcServicesListSection(
                          services: state.services,
                          onServiceTap: (srv) =>
                              _showFeedback('تم اختيار: ${srv.title}'),
                          onBookTap: (srv) =>
                              _showFeedback('جاري حجز موعد لخدمة: ${srv.title}'),
                          onViewAllTap: () =>
                              _controller.selectFilter('الكل'),
                        ),
                      )
                    else if (!state.isLoading)
                      const SliverToBoxAdapter(
                        child: AppEmptyState(
                          title: 'لا توجد خدمات متاحة',
                          message: 'جرّب اختيار فلتر آخر',
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 6.0)),

                    // 5. Spare Parts & Accessories Section ("قطع غيار وملحقات التكييف")
                    if (state.parts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AcPartsGridSection(
                          parts: state.parts,
                          onPartTap: (part) =>
                              _showFeedback('عرض تفاصيل: ${part.title}'),
                          onAddToCartTap: (part) =>
                              _showFeedback('تمت إضافة ${part.title} إلى السلة'),
                          onViewAllTap: () =>
                              _showFeedback('تصفح جميع قطع الغيار'),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40.0)),
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
