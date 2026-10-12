import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../widgets/real_estate_card/real_estate_card.dart';
import '../../widgets/real_estate_filter_bar/real_estate_filter_bar.dart';
import '../../widgets/real_estate_header/real_estate_header.dart';
import '../../widgets/real_estate_search_bar/real_estate_search_bar.dart';
import '../controllers/real_estate_controller.dart';

class RealEstatePage extends StatefulWidget {
  final RealEstateController? controller;

  const RealEstatePage({super.key, this.controller});

  @override
  State<RealEstatePage> createState() => _RealEstatePageState();
}

class _RealEstatePageState extends State<RealEstatePage> {
  late final RealEstateController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RealEstateController();
    _controller.loadListings();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: ValueListenableBuilder<RealEstateState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return Center(
                  child: AppErrorView(
                    message: state.errorMessage!,
                    onRetry: _controller.loadListings,
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _controller.loadListings,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Header Bar
                    SliverToBoxAdapter(
                      child: RealEstateHeader(
                        onNotificationsTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لا توجد إشعارات جديدة حالياً'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        onCartTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('سلة التسوق فارغة'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),

                    // 2. Search & Filter Bar
                    SliverToBoxAdapter(
                      child: RealEstateSearchBar(
                        onChanged: _controller.setSearchQuery,
                        onFilterTap: _showFilterOptionsSheet,
                      ),
                    ),

                    // 3. Filter Chips Bar (الكل، شقق للبيع، شقق للإيجار)
                    SliverToBoxAdapter(
                      child: RealEstateFilterBar(
                        selectedType: state.filter.selectedType,
                        onTypeSelected: _controller.setFilterType,
                        onSortTap: _showSortSheet,
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.xs),
                    ),

                    // 4. Real Estate Listings Cards
                    if (state.listings.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppEmptyState(
                            title: 'لا توجد عقارات مطابقة',
                            message: 'جرّب تغيير كلمات البحث أو الفلتر لعرض المزيد من النتائج',
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = state.listings[index];
                          return RealEstateCard(
                            item: item,
                            onFavoriteTap: () =>
                                _controller.toggleFavorite(item.id),
                            onDetailsTap: () => _openListingDetail(item.id),
                          );
                        }, childCount: state.listings.length),
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

  void _openListingDetail(String id) {
    context.push('${RouteNames.realEstateDetail}?id=$id');
  }

  void _showFilterOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خيارات التصفية الفاخرة',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'تصفية حسب عدد الغرف، السعر، الحي والمنطقة، أوالدور.',
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('تطبيق التصفية'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ترتيب العقارات',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('الأحدث أولاً'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  title: const Text('الأقل سعراً أولاً'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  title: const Text('الأعلى سعراً أولاً'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
