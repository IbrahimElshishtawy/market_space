import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/home_service_model.dart';
import '../controllers/home_services_catalog_controller.dart';
import '../controllers/home_services_favorites_controller.dart';

class HomeServicesCatalogView extends StatelessWidget {
  const HomeServicesCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final catalogCtrl = dependencies.homeServicesCatalogController;
    final favCtrl = dependencies.homeServicesFavoritesController;

    return ListenableBuilder(
      listenable: Listenable.merge([catalogCtrl, favCtrl]),
      builder: (context, _) {
        final categories = catalogCtrl.categories;
        final services = catalogCtrl.services;

        return Column(
          children: [
            // Search Bar & Filter header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: _buildSearchBar(context, catalogCtrl),
            ),

            // Horizontal Categories Scroll
            SliverCategoryFilterBar(
              categories: categories,
              selectedCategoryId: catalogCtrl.selectedCategoryId,
              onSelectCategory: catalogCtrl.selectCategory,
            ),

            // Dynamic Filters Row (Pricing Type & Clear)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(
                        catalogCtrl.selectedPricingType != null
                            ? catalogCtrl.selectedPricingType!.labelAr
                            : 'طريقة التسعير',
                      ),
                      selected: catalogCtrl.selectedPricingType != null,
                      onSelected: (_) => _showPricingFilterDialog(context, catalogCtrl),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    FilterChip(
                      label: Text(
                        catalogCtrl.selectedArea != null ? catalogCtrl.selectedArea! : 'المنطقة',
                      ),
                      selected: catalogCtrl.selectedArea != null,
                      onSelected: (_) => _showAreaFilterDialog(context, catalogCtrl),
                    ),
                    if (catalogCtrl.selectedCategoryId != null ||
                        catalogCtrl.selectedPricingType != null ||
                        catalogCtrl.selectedArea != null ||
                        catalogCtrl.searchQuery.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.xs),
                      ActionChip(
                        avatar: const Icon(Icons.refresh_rounded, size: 16.0),
                        label: const Text('إعادة ضبط'),
                        onPressed: catalogCtrl.resetFilters,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Services List
            Expanded(
              child: services.isEmpty
                  ? _buildEmptyState(context, catalogCtrl)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        120.0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: services.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _buildCatalogServiceCard(context, service, favCtrl);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeServicesCatalogController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث في كافة الخدمات والمهندسين...',
          hintStyle: const TextStyle(fontSize: 14.0, color: AppColors.lightTextSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: ctrl.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20.0),
                  onPressed: () => ctrl.setSearchQuery(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        onChanged: ctrl.setSearchQuery,
      ),
    );
  }

  Widget _buildCatalogServiceCard(
    BuildContext context,
    HomeServiceModel service,
    HomeServicesFavoritesController favCtrl,
  ) {
    final isFav = favCtrl.isServiceFavorite(service.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: AppRadii.lg,
        onTap: () {
          context.push('/home-services/service-detail?id=${service.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: AppRadii.md,
                    child: Image.network(
                      service.images.isNotEmpty
                          ? service.images.first
                          : 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=300',
                      width: 90.0,
                      height: 90.0,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 90.0,
                        height: 90.0,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.handyman_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Service Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isFav ? Colors.red : Colors.grey,
                                size: 20.0,
                              ),
                              onPressed: () => favCtrl.toggleService(service),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          service.shortDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text(
                              service.estimatedDuration,
                              style: const TextStyle(fontSize: 11.0, color: Colors.grey),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.star_rounded, size: 15.0, color: Colors.amber),
                            const SizedBox(width: 2.0),
                            Text(
                              '${service.rating} (${service.reviewsCount})',
                              style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 18.0),

              // Bottom Pricing & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadii.sm,
                        ),
                        child: Text(
                          service.pricingType.labelAr,
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        service.formattedPrice,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        ),
                        onPressed: () {
                          context.push('/home-services/service-detail?id=${service.id}');
                        },
                        child: const Text('التفاصيل'),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        onPressed: () {
                          context.push('/home-services/book?serviceId=${service.id}');
                        },
                        child: const Text('احجز الآن'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeServicesCatalogController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 64.0, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'لا توجد خدمات مطابقة لبحثك',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'جرب تغيير كلمات البحث أو إعادة ضبط الفلاتر للاطلاع على الخدمات المتاحة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: ctrl.resetFilters,
              child: const Text('إعادة ضبط الفلاتر'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPricingFilterDialog(BuildContext context, HomeServicesCatalogController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'اختر طريقة التسعير',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('الكل'),
                selected: ctrl.selectedPricingType == null,
                onTap: () {
                  ctrl.setPricingTypeFilter(null);
                  Navigator.pop(context);
                },
              ),
              ...PricingType.values.map(
                (p) => ListTile(
                  title: Text(p.labelAr),
                  selected: ctrl.selectedPricingType == p,
                  onTap: () {
                    ctrl.setPricingTypeFilter(p);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAreaFilterDialog(BuildContext context, HomeServicesCatalogController ctrl) {
    final areas = [
      'القاهرة',
      'الجيزة',
      'القاهرة الجديدة',
      'مدينة نصر',
      'المعادي',
      'الشيخ زايد',
      '6 أكتوبر',
      'الإسكندرية',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'اختر المنطقة',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('كافة المناطق'),
                selected: ctrl.selectedArea == null,
                onTap: () {
                  ctrl.setAreaFilter(null);
                  Navigator.pop(context);
                },
              ),
              ...areas.map(
                (a) => ListTile(
                  title: Text(a),
                  selected: ctrl.selectedArea == a,
                  onTap: () {
                    ctrl.setAreaFilter(a);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SliverCategoryFilterBar extends StatelessWidget {
  final List<HomeServiceCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelectCategory;

  const SliverCategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = selectedCategoryId == null;
            return ChoiceChip(
              label: const Text('كافة الأقسام'),
              selected: isAll,
              onSelected: (_) => onSelectCategory(null),
            );
          }
          final cat = categories[index - 1];
          final isSelected = selectedCategoryId == cat.id;
          return ChoiceChip(
            label: Text(cat.name),
            selected: isSelected,
            onSelected: (_) => onSelectCategory(cat.id),
          );
        },
      ),
    );
  }
}
