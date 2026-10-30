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
import '../../navigation/real_estate_navigation_config.dart';
import '../../widgets/real_estate_card/real_estate_card.dart';
import '../../widgets/real_estate_filter_bar/real_estate_filter_bar.dart';
import '../../widgets/real_estate_filter_sheet/real_estate_filter_sheet.dart';
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
  int _tabIndex = 0;
  bool _isNavVisible = true;

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

    final config = RealEstateNavigationConfig.config;
    final item = config.items[index];

    if (item.id == 're-reels' || item.destination == '/real-estate/reels') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/real-estate/reels');
      }
    } else if (item.id == 're-map' || item.destination == '/real-estate/map') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/real-estate/map');
      }
    } else if (item.id == 're-fav' ||
        item.destination == '/real-estate/favorites') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/real-estate/favorites');
      }
    } else if (item.id == 're-notif' ||
        item.destination == '/real-estate/notifications') {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/real-estate/notifications');
      }
    }
  }

  void _handleAddProperty() {
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
                  'إضافة عقار جديد',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'اختر نوع الإعلان الذي ترغب بنشره في سياق العقارات:',
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(
                    Icons.home_work_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('إعلان عقار للبيع'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.key_outlined,
                    color: AppColors.secondary,
                  ),
                  title: const Text('إعلان عقار للإيجار'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.maybeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
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

              return NotificationListener<UserScrollNotification>(
                onNotification: _onUserScroll,
                child: RefreshIndicator(
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
                            if (GoRouter.maybeOf(context) != null) {
                              context.push('/real-estate/notifications');
                            }
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
                          onFilterTap: _openFilterSheet,
                        ),
                      ),

                      // 3. Filter Chips Bar (الكل، شقق للبيع، شقق للإيجار)
                      SliverToBoxAdapter(
                        child: RealEstateFilterBar(
                          selectedType: state.filter.selectedType,
                          onTypeSelected: _controller.setFilterType,
                          onSortTap: _openFilterSheet,
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
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = state.listings[index];
                            return RealEstateCard(
                              item: item,
                              onFavoriteTap: () =>
                                  _controller.toggleFavorite(item.id),
                              onDetailsTap: () => _openListingDetail(item.id),
                            );
                          }, childCount: state.listings.length),
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
          config: RealEstateNavigationConfig.config,
          currentIndex: _tabIndex,
          onTabSelected: _onTabSelected,
          onFloatingActionPressed: _handleAddProperty,
          notificationController: dependencies?.notificationController,
          isVisible: _isNavVisible,
        ),
      ),
    );
  }

  void _openListingDetail(String id) {
    context.push('${RouteNames.realEstateDetail}?id=$id');
  }

  Future<void> _openFilterSheet() async {
    final updatedFilter = await RealEstateFilterSheet.show(
      context,
      initialFilter: _controller.value.filter,
    );

    if (updatedFilter != null) {
      _controller.updateFilter(updatedFilter);
    }
  }
}
