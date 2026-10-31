import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/home_service_booking_model.dart';
import '../../data/models/home_service_model.dart';
import '../../data/models/service_provider_model.dart';
import '../controllers/home_services_catalog_controller.dart';
import '../controllers/home_services_favorites_controller.dart';

class HomeServicesHomeView extends StatelessWidget {
  final VoidCallback onExploreServicesTap;

  const HomeServicesHomeView({
    super.key,
    required this.onExploreServicesTap,
  });

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final catalogCtrl = dependencies.homeServicesCatalogController;
    final bookingCtrl = dependencies.homeServicesBookingController;
    final favCtrl = dependencies.homeServicesFavoritesController;

    return ListenableBuilder(
      listenable: Listenable.merge([catalogCtrl, bookingCtrl, favCtrl]),
      builder: (context, _) {
        if (catalogCtrl.isLoading && catalogCtrl.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final upcoming = bookingCtrl.upcomingBooking;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _buildSearchBar(context, catalogCtrl),
              ),
            ),

            // 2. Promotional Banners
            SliverToBoxAdapter(
              child: _buildPromoBanners(context),
            ),

            // 3. Upcoming Booking (if any)
            if (upcoming != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: _buildUpcomingBookingCard(context, upcoming),
                ),
              ),

            // 4. Categories Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'أقسام الخدمات المنزلية',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                    TextButton(
                      onPressed: onExploreServicesTap,
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Categories Grid / Horizontal Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 110.0,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: catalogCtrl.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final cat = catalogCtrl.categories[index];
                    return _buildCategoryChip(context, cat, catalogCtrl);
                  },
                ),
              ),
            ),

            // 5. Popular Services
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'الخدمات الأكثر طلباً',
                'خدمات موثوقة حظيت بأعلى تقييمات العملاء',
                onSeeAll: onExploreServicesTap,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 270.0,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: catalogCtrl.popularServices.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final service = catalogCtrl.popularServices[index];
                    return _buildServiceCard(context, service, favCtrl);
                  },
                ),
              ),
            ),

            // 6. Featured Providers
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'أفضل شركات ومقدمي الخدمة المعتمدين',
                'شركات مرخصة وتضمن حقوق العملاء وجودة التنفيذ',
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 195.0,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: catalogCtrl.featuredProviders.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final provider = catalogCtrl.featuredProviders[index];
                    return _buildProviderCard(context, provider);
                  },
                ),
              ),
            ),

            // 7. Recommended / New Services
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                'خدمات مضافة حديثاً وعروض موسمية',
                'حلول صيانة دورية لمنزلك',
                onSeeAll: onExploreServicesTap,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 270.0,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: catalogCtrl.newServices.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final service = catalogCtrl.newServices[index];
                    return _buildServiceCard(context, service, favCtrl);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن خدمة، تخصص، أو فني...',
          hintStyle: const TextStyle(fontSize: 14.0, color: AppColors.lightTextSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: ctrl.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20.0),
                  onPressed: () => ctrl.setSearchQuery(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        ),
        onChanged: ctrl.setSearchQuery,
      ),
    );
  }

  Widget _buildPromoBanners(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppRadii.lg,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: AppRadii.full,
                  ),
                  child: const Text(
                    'عرض خاص 20% خصم',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'غسيل وصيانة تكييفات',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'فحص كامل لضغط الفريون مع تنظيف كيميائي معتمد',
                  style: TextStyle(fontSize: 12.0, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.ac_unit_rounded,
              color: Colors.white,
              size: 38.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookingCard(BuildContext context, HomeServiceBookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: AppRadii.lg,
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_filled_rounded, size: 18.0, color: Colors.amber.shade900),
                  const SizedBox(width: 6.0),
                  Text(
                    'حجز قادم — ${booking.id}',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: booking.status.statusColor.withValues(alpha: 0.15),
                  borderRadius: AppRadii.full,
                ),
                child: Text(
                  booking.status.labelAr,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: booking.status.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            booking.serviceTitle,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'الموعد: ${booking.scheduledDate.year}/${booking.scheduledDate.month}/${booking.scheduledDate.day} — ${booking.scheduledTimeSlot}',
            style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
          ),
          if (booking.technicianName != null) ...[
            const SizedBox(height: 4.0),
            Text(
              'الفني: ${booking.technicianName}',
              style: const TextStyle(fontSize: 12.0, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.amber.shade900),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
              ),
              onPressed: () {
                context.push('/home-services/booking-detail?id=${booking.id}');
              },
              child: Text(
                'عرض تفاصيل الحجز ومتابعة الفني',
                style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    HomeServiceCategoryModel cat,
    HomeServicesCatalogController ctrl,
  ) {
    final isSelected = ctrl.selectedCategoryId == cat.id;

    return InkWell(
      onTap: () {
        ctrl.selectCategory(cat.id);
        onExploreServicesTap();
      },
      borderRadius: AppRadii.lg,
      child: Container(
        width: 86.0,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(cat.iconName),
                color: AppColors.primary,
                size: 24.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              cat.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('المزيد'),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    HomeServiceModel service,
    HomeServicesFavoritesController favCtrl,
  ) {
    final isFav = favCtrl.isServiceFavorite(service.id);

    return Container(
      width: 220.0,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image & Favorite Button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Image.network(
                  service.images.isNotEmpty
                      ? service.images.first
                      : 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=400',
                  height: 110.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 110.0,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.handyman_rounded, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 6.0,
                left: 6.0,
                child: CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red : Colors.grey,
                      size: 18.0,
                    ),
                    onPressed: () => favCtrl.toggleService(service),
                  ),
                ),
              ),
              Positioned(
                bottom: 6.0,
                right: 6.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: AppRadii.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14.0),
                      const SizedBox(width: 2.0),
                      Text(
                        service.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  service.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.0, color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 6.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.formattedPrice,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.push('/home-services/service-detail?id=${service.id}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadii.md,
                        ),
                        child: const Text(
                          'احجز',
                          style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, ServiceProviderModel provider) {
    return Container(
      width: 240.0,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: AppRadii.md,
                child: Image.network(
                  provider.logoUrl,
                  width: 44.0,
                  height: 44.0,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 44.0,
                    height: 44.0,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.business_rounded, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (provider.isVerified)
                          const Icon(Icons.verified_rounded, color: Colors.blue, size: 16.0),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14.0),
                        const SizedBox(width: 2.0),
                        Text(
                          '${provider.rating} (${provider.reviewsCount})',
                          style: const TextStyle(fontSize: 11.0, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            provider.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.0, color: AppColors.lightTextSecondary),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'يبدأ من ${provider.startingPrice.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  context.push('/home-services/provider-detail?id=${provider.id}');
                },
                child: const Text('الملف التعريفي', style: TextStyle(fontSize: 12.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'plumbing_rounded':
        return Icons.plumbing_rounded;
      case 'bolt_rounded':
        return Icons.bolt_rounded;
      case 'ac_unit_rounded':
        return Icons.ac_unit_rounded;
      case 'clean_hands_rounded':
        return Icons.clean_hands_rounded;
      case 'format_paint_rounded':
        return Icons.format_paint_rounded;
      case 'carpenter_rounded':
        return Icons.carpenter_rounded;
      case 'kitchen_rounded':
        return Icons.kitchen_rounded;
      case 'pest_control_rounded':
        return Icons.pest_control_rounded;
      case 'local_shipping_rounded':
        return Icons.local_shipping_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }
}
