import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../data/models/car_brand_model.dart';
import '../../data/models/car_filter_model.dart';
import '../../data/models/car_listing_model.dart';
import '../../navigation/cars_navigation_config.dart';
import '../controllers/cars_controller.dart';
import '../widgets/car_filter_sheet.dart';
import '../widgets/car_listing_card.dart';

class CarsPage extends StatefulWidget {
  final CarsController? controller;

  const CarsPage({super.key, this.controller});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  late final CarsController _controller;
  late final TextEditingController _searchFieldController;
  int _tabIndex = 0;
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CarsController();
    _searchFieldController = TextEditingController(
      text: _controller.value.filter.searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isNavVisible) setState(() => _isNavVisible = false);
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isNavVisible) setState(() => _isNavVisible = true);
    }
    return false;
  }

  void _openFilterSheet(CarsState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CarFilterSheet(
        initialFilter: state.filter,
        availableBrands: state.brands.map((b) => b.name).toList(),
        onApply: (filter) {
          _controller.applyFilter(filter);
        },
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() => _tabIndex = index);
    if (index == 0) return;

    if (index == 1) {
      // Browse
      _controller.applyFilter(const CarFilterModel());
    } else if (index == 2) {
      // Brands
      _openFilterSheet(_controller.value);
    } else if (index == 3) {
      // Favorites
      context.push(RouteNames.favorites);
    } else if (index == 4) {
      // Notifications
      context.push(RouteNames.globalNotifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
            SizedBox(width: 8.0),
            Text(
              'سوق السيارات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'تصفية وبحث متقدم',
            onPressed: () => _openFilterSheet(_controller.value),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ رابط قسم السيارات')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: NotificationListener<UserScrollNotification>(
          onNotification: _onUserScroll,
          child: ValueListenableBuilder<CarsState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading && state.cars.isEmpty) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null && state.cars.isEmpty) {
                return AppErrorView(
                  title: 'تعذر تحميل بيانات السيارات',
                  message: state.errorMessage!,
                  onRetry: () => _controller.loadInitialData(),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.loadInitialData(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Search Bar & Filter Button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 46.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadii.md,
                                  border: Border.all(color: AppColors.lightBorder),
                                ),
                                child: TextField(
                                  controller: _searchFieldController,
                                  decoration: InputDecoration(
                                    hintText: 'ابحث عن ماركة، موديل، أو محافظة...',
                                    hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.lightTextSecondary),
                                    prefixIcon: const Icon(Icons.search_rounded, size: 20.0, color: AppColors.primary),
                                    suffixIcon: _searchFieldController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 18.0),
                                            onPressed: () {
                                              _searchFieldController.clear();
                                              _controller.setSearchQuery('');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                                  ),
                                  onSubmitted: (q) => _controller.setSearchQuery(q),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            InkWell(
                              onTap: () => _openFilterSheet(state),
                              borderRadius: AppRadii.md,
                              child: Container(
                                height: 46.0,
                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: state.filter.hasActiveFilters
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: AppRadii.md,
                                  border: Border.all(
                                    color: state.filter.hasActiveFilters
                                        ? AppColors.primary
                                        : AppColors.lightBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list_rounded,
                                      size: 18.0,
                                      color: state.filter.hasActiveFilters
                                          ? Colors.white
                                          : AppColors.neutral,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'فلترة',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                        color: state.filter.hasActiveFilters
                                            ? Colors.white
                                            : AppColors.neutral,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Condition Quick Filter Chips (الكل / جديدة / مستعملة)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickChip(
                                label: 'الكل (${state.cars.length})',
                                isSelected: state.filter.condition == null && state.filter.bodyType == null && state.filter.brand == null,
                                onTap: () => _controller.applyFilter(const CarFilterModel()),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _buildQuickChip(
                                label: 'سيارات جديدة (زيرو)',
                                isSelected: state.filter.condition == CarCondition.newCar,
                                onTap: () => _controller.setCondition(
                                  state.filter.condition == CarCondition.newCar ? null : CarCondition.newCar,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _buildQuickChip(
                                label: 'سيارات مستعملة',
                                isSelected: state.filter.condition == CarCondition.used,
                                onTap: () => _controller.setCondition(
                                  state.filter.condition == CarCondition.used ? null : CarCondition.used,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _buildQuickChip(
                                label: 'SUV ودفع رباعي',
                                isSelected: state.filter.bodyType == CarBodyType.suv,
                                onTap: () => _controller.setBodyType(
                                  state.filter.bodyType == CarBodyType.suv ? null : CarBodyType.suv,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _buildQuickChip(
                                label: 'سيدان',
                                isSelected: state.filter.bodyType == CarBodyType.sedan,
                                onTap: () => _controller.setBodyType(
                                  state.filter.bodyType == CarBodyType.sedan ? null : CarBodyType.sedan,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _buildQuickChip(
                                label: 'كهربائية',
                                isSelected: state.filter.bodyType == CarBodyType.electric,
                                onTap: () => _controller.setBodyType(
                                  state.filter.bodyType == CarBodyType.electric ? null : CarBodyType.electric,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Featured Cars Horizontal Carousel
                    if (state.featuredCars.isNotEmpty && !state.filter.hasActiveFilters) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.md,
                            AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'عروض سيارات مميزة',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral,
                                ),
                              ),
                              Text(
                                '${state.featuredCars.length} سيارات مميزة',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 245.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsetsDirectional.only(
                              start: AppSpacing.md,
                              bottom: AppSpacing.sm,
                            ),
                            itemCount: state.featuredCars.length,
                            itemBuilder: (context, idx) {
                              final car = state.featuredCars[idx];
                              return CarListingCard(
                                car: car,
                                isHorizontal: true,
                                onTap: () {
                                  context.push('${RouteNames.cars}/detail?id=${car.id}');
                                },
                                onFavoriteToggle: () => _controller.toggleFavorite(car.id),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    // 4. Car Brands Section
                    if (state.brands.isNotEmpty && !state.filter.hasActiveFilters) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'تصفح حسب أشهر الماركات',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _openFilterSheet(state),
                                child: const Text('عرض الكل'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 70.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
                            itemCount: state.brands.length,
                            itemBuilder: (context, idx) {
                              final brand = state.brands[idx];
                              final isSelected = state.filter.brand == brand.name;
                              return _buildBrandChip(brand, isSelected);
                            },
                          ),
                        ),
                      ),
                    ],

                    // 5. Listings Section Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.filter.hasActiveFilters ? 'نتائج التصفية والبحث' : 'أحدث السيارات المعروضة',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                            Text(
                              '${state.cars.length} إعلان متاح',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 6. Listings Grid or Empty State
                    if (state.cars.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: AppEmptyState(
                            title: 'لا توجد سيارات مطابقة',
                            message: 'جرّب تعديل خيارات البحث أو إعادة ضبط الفلاتر للاطلاع على كل السيارات.',
                            action: ElevatedButton(
                              onPressed: () => _controller.applyFilter(const CarFilterModel()),
                              child: const Text('إعادة ضبط الفلاتر'),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          100.0, // space for bottom nav bar
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, idx) {
                              final car = state.cars[idx];
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.md),
                                child: CarListingCard(
                                  car: car,
                                  onTap: () {
                                    context.push('${RouteNames.cars}/detail?id=${car.id}');
                                  },
                                  onFavoriteToggle: () => _controller.toggleFavorite(car.id),
                                ),
                              );
                            },
                            childCount: state.cars.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        config: CarsNavigationConfig.config,
        currentIndex: _tabIndex,
        isVisible: _isNavVisible,
        onTabSelected: _onTabSelected,
        onFloatingActionPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('إضافة إعلان سيارة جديد قيد التفعيل')),
          );
        },
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.sm,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: AppRadii.sm,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.neutral,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandChip(CarBrandModel brand, bool isSelected) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          _controller.setBrand(isSelected ? null : brand.name);
        },
        borderRadius: AppRadii.md,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: AppRadii.md,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14.0,
                backgroundColor: AppColors.lightBackground,
                child: Text(
                  brand.name[0],
                  style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand.nameAr,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.neutral,
                    ),
                  ),
                  Text(
                    '${brand.availableListingsCount} إعلان',
                    style: const TextStyle(fontSize: 9.5, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
