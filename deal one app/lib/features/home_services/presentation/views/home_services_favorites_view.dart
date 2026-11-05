import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_network_image.dart';

class HomeServicesFavoritesView extends StatefulWidget {
  final VoidCallback onExploreServicesTap;

  const HomeServicesFavoritesView({
    super.key,
    required this.onExploreServicesTap,
  });

  @override
  State<HomeServicesFavoritesView> createState() => _HomeServicesFavoritesViewState();
}

class _HomeServicesFavoritesViewState extends State<HomeServicesFavoritesView> {
  int _selectedSegment = 0; // 0 = Services, 1 = Providers

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final favCtrl = dependencies.homeServicesFavoritesController;

    return ListenableBuilder(
      listenable: favCtrl,
      builder: (context, _) {
        final services = favCtrl.favoriteServices;
        final providers = favCtrl.favoriteProviders;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            // Segmented Switcher
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                  borderRadius: AppRadii.lg,
                ),
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedSegment = 0),
                        borderRadius: AppRadii.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: _selectedSegment == 0
                                ? (isDark ? AppColors.darkBackground : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppRadii.md,
                            boxShadow: _selectedSegment == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                      blurRadius: 4.0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'الخدمات المحفوظة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: _selectedSegment == 0 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedSegment == 0
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.primary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.neutral),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedSegment = 1),
                        borderRadius: AppRadii.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: _selectedSegment == 1
                                ? (isDark ? AppColors.darkSurfaceSecondary : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppRadii.md,
                            boxShadow: _selectedSegment == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                      blurRadius: 4.0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'مزودو الخدمة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: _selectedSegment == 1 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedSegment == 1
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.primary)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.neutral),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content List
            Expanded(
              child: _selectedSegment == 0
                  ? (services.isEmpty
                      ? _buildEmptyState('لا توجد خدمات محفوظة حالياً', isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.md,
                            120.0,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: services.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final s = services[index];
                            return ListTile(
                              tileColor: isDark ? AppColors.darkSurface : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.lg,
                                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              leading: ClipRRect(
                                borderRadius: AppRadii.md,
                                child: AppNetworkImage(
                                  imageUrl: s.images.isNotEmpty ? s.images.first : '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  fallbackIcon: Icons.handyman_rounded,
                                ),
                              ),
                              title: Text(
                                s.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                                ),
                              ),
                              subtitle: Text(
                                '${s.formattedPrice} • ${s.estimatedDuration}',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                                    onPressed: () => favCtrl.toggleService(s),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                                      foregroundColor: isDark ? AppColors.darkOnPrimary : Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      minimumSize: const Size(60, 32),
                                    ),
                                    onPressed: () {
                                      context.push('/home-services/book?serviceId=${s.id}');
                                    },
                                    child: const Text('احجز'),
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.push('/home-services/service-detail?id=${s.id}');
                              },
                            );
                          },
                        ))
                  : (providers.isEmpty
                      ? _buildEmptyState('لا توجد شركات أو مقدمي خدمة محفوظين', isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.md,
                            120.0,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: providers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final p = providers[index];
                            return ListTile(
                              tileColor: isDark ? AppColors.darkSurface : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.lg,
                                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              ),
                              leading: ClipRRect(
                                borderRadius: AppRadii.md,
                                child: AppNetworkImage(
                                  imageUrl: p.logoUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  fallbackIcon: Icons.business_rounded,
                                ),
                              ),
                              title: Text(
                                p.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                                ),
                              ),
                              subtitle: Text(
                                '${p.rating} ★ (${p.reviewsCount} تقييم) • ${p.specialties.join(", ")}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: isDark ? AppColors.darkTextSecondary : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                                onPressed: () => favCtrl.toggleProvider(p),
                              ),
                              onTap: () {
                                context.push('/home-services/provider-detail?id=${p.id}');
                              },
                            );
                          },
                        )),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String title, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 64.0, color: Colors.grey),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'يمكنك حفظ الخدمات والمزودين المفضلين للوصول إليهم والحجز بضغطة زر واحدة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                foregroundColor: isDark ? AppColors.darkOnPrimary : Colors.white,
              ),
              onPressed: widget.onExploreServicesTap,
              child: const Text('تصفح الخدمات الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
