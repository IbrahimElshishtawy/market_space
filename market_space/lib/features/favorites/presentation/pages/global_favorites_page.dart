import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../controllers/unified_favorites_controller.dart';
import '../../data/models/unified_favorite_item_model.dart';

class GlobalFavoritesPage extends StatefulWidget {
  final UnifiedFavoritesController? controller;

  const GlobalFavoritesPage({super.key, this.controller});

  @override
  State<GlobalFavoritesPage> createState() => _GlobalFavoritesPageState();
}

class _GlobalFavoritesPageState extends State<GlobalFavoritesPage> {
  late final UnifiedFavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? UnifiedFavoritesController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _navigateToDetail(String route) {
    if (GoRouter.maybeOf(context) != null) {
      context.push(route);
    }
  }

  void _handleAddToCart(BuildContext context, UnifiedFavoriteItem item) {
    final dependencies = AppDependencies.maybeOf(context);
    if (item.sectorId == 'building_materials' && dependencies != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة "${item.title}" إلى سلة مواد البناء'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (item.sectorId == 'home_appliances' && dependencies != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة "${item.title}" إلى سلة الأجهزة المنزلية'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _navigateToDetail(item.deepLinkRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<UnifiedFavoritesState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.loadFavorites(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'المفضلة',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral,
                                  ),
                                ),
                                if (state.favorites.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: AppRadii.full,
                                    ),
                                    child: Text(
                                      '${state.favorites.length} عناصر محفوظة',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            const Text(
                              'جميع العقارات، المواد، الخدمات والأجهزة التي قمت بحفظها',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sector Filter Pills
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: FavoriteSectorFilter.values.map((sector) {
                            final isSelected = state.selectedSector == sector;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ChoiceChip(
                                selected: isSelected,
                                showCheckmark: false,
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      sector.icon,
                                      size: 15.0,
                                      color: isSelected ? Colors.white : AppColors.neutral,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      sector.label,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.neutral,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadii.full,
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : const Color(0x1A000000),
                                  ),
                                ),
                                onSelected: (_) => _controller.setSectorFilter(sector),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                    // Content Body
                    if (state.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: AppLoadingIndicator()),
                      )
                    else if (state.errorMessage != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppErrorView(
                          title: 'حدث خطأ في تحميل المفضلة',
                          message: state.errorMessage!,
                          onRetry: () => _controller.loadFavorites(),
                        ),
                      )
                    else if (state.favorites.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AppEmptyState(
                          title: 'قائمة المفضلة فارغة',
                          message: state.selectedSector == FavoriteSectorFilter.all
                              ? 'لم تقم بحفظ أي عنصر في المفضلة بعد. تصفح الأقسام واضغط على أيقونة القلب لحفظ العناصر هنا.'
                              : 'لا توجد عناصر محفوظة في قسم "${state.selectedSector.label}".',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = state.favorites[index];
                              return _buildFavoriteCard(context, item);
                            },
                            childCount: state.favorites.length,
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, UnifiedFavoriteItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(item.deepLinkRoute),
        borderRadius: AppRadii.lg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: AppRadii.md,
                    child: SafeNetworkImage(
                      imageUrl: item.imageUrl,
                      width: 85.0,
                      height: 85.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: AppRadii.xs,
                              ),
                              child: Text(
                                item.sectorName,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ),
                            // Remove from favorite button
                            IconButton(
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                                size: 22.0,
                              ),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              tooltip: 'إزالة من المفضلة',
                              onPressed: () => _controller.removeFavorite(item),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          item.title,
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
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.formattedPrice,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14.0,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2.0),
                                  Text(
                                    item.rating!.toString(),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 18.0, thickness: 0.8),
              // Bottom Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToDetail(item.deepLinkRoute),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14.0),
                    label: const Text('عرض التفاصيل', style: TextStyle(fontSize: 12.0)),
                  ),
                  if (item.canAddToCart)
                    ElevatedButton.icon(
                      onPressed: () => _handleAddToCart(context, item),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 14.0),
                      label: const Text(
                        'إضافة للسلة',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                      ),
                    )
                  else if (item.canBookService)
                    ElevatedButton.icon(
                      onPressed: () => _navigateToDetail(item.deepLinkRoute),
                      icon: const Icon(Icons.calendar_month_rounded, size: 14.0),
                      label: const Text(
                        'احجز الآن',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => _navigateToDetail(item.deepLinkRoute),
                      icon: const Icon(Icons.contact_phone_rounded, size: 14.0),
                      label: const Text(
                        'طلب تواصل أو معاينة',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neutral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
                      ),
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
