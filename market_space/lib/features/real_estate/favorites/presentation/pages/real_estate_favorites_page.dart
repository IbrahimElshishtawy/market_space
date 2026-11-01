import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/app_dependencies.dart';
import '../../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_empty_state.dart';
import '../../../../../shared/widgets/app_error_view.dart';
import '../../../../../shared/widgets/app_loading_indicator.dart';
import '../../../navigation/real_estate_navigation_config.dart';
import '../../../widgets/real_estate_search_bar/real_estate_search_bar.dart';
import '../controllers/real_estate_favorites_controller.dart';
import '../widgets/favorite_property_card.dart';

class RealEstateFavoritesPage extends StatefulWidget {
  final RealEstateFavoritesController? controller;

  const RealEstateFavoritesPage({super.key, this.controller});

  @override
  State<RealEstateFavoritesPage> createState() =>
      _RealEstateFavoritesPageState();
}

class _RealEstateFavoritesPageState extends State<RealEstateFavoritesPage> {
  late final RealEstateFavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RealEstateFavoritesController();
    _controller.loadFavorites();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _openPropertyDetails(String id) {
    if (GoRouter.maybeOf(context) != null) {
      context.push('${RouteNames.realEstateDetail}?id=$id');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فتح تفاصيل العقار: $id'),
          duration: const Duration(seconds: 1),
        ),
      );
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
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: const Text('العقارات المفضلة'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppColors.neutral,
        ),
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<RealEstateFavoritesState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null) {
                return Center(
                  child: AppErrorView(
                    message: state.errorMessage!,
                    onRetry: _controller.loadFavorites,
                  ),
                );
              }

              final filteredList = state.filteredFavorites;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _controller.loadFavorites,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RealEstateSearchBar(
                          onChanged: _controller.setSearchQuery,
                          onFilterTap: () {},
                        ),
                      ),
                    ),

                    if (filteredList.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: AppEmptyState(
                            title: 'لا توجد عقارات في المفضلة',
                            message: 'اضغط على أيقونة القلب لعفظ العقارات المفضلة لديك وتصفحها لاحقاً',
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final fav = filteredList[index];
                          return FavoritePropertyCard(
                            item: fav,
                            onRemoveTap: () =>
                                _controller.toggleFavorite(fav.property),
                            onDetailsTap: () =>
                                _openPropertyDetails(fav.property.id),
                          );
                        }, childCount: filteredList.length),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 140.0)),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: RealEstateNavigationConfig.config,
          currentIndex: 3, // 4th tab is "المفضلة"
          onTabSelected: (index) {
            if (index == 0 && GoRouter.maybeOf(context) != null) {
              context.go(RouteNames.realEstate);
            } else if (index == 1 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/reels');
            } else if (index == 2 && GoRouter.maybeOf(context) != null) {
              context.push('/real-estate/map');
            }
          },
          onFloatingActionPressed: _handleAddProperty,
          notificationController: dependencies?.notificationController,
          isVisible: true,
        ),
      ),
    );
  }
}
