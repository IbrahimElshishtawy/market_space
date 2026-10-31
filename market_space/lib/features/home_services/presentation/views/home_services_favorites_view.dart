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

        return Column(
          children: [
            // Segmented Switcher
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
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
                            color: _selectedSegment == 0 ? Colors.white : Colors.transparent,
                            borderRadius: AppRadii.md,
                            boxShadow: _selectedSegment == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
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
                              color: _selectedSegment == 0 ? AppColors.primary : AppColors.neutral,
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
                            color: _selectedSegment == 1 ? Colors.white : Colors.transparent,
                            borderRadius: AppRadii.md,
                            boxShadow: _selectedSegment == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
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
                              color: _selectedSegment == 1 ? AppColors.primary : AppColors.neutral,
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
                      ? _buildEmptyState('لا توجد خدمات محفوظة حالياً')
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
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.lg,
                                side: const BorderSide(color: AppColors.lightBorder),
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${s.formattedPrice} • ${s.estimatedDuration}',
                                style: const TextStyle(fontSize: 12.0, color: AppColors.primary),
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
                      ? _buildEmptyState('لا توجد شركات أو مقدمي خدمة محفوظين')
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
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.lg,
                                side: const BorderSide(color: AppColors.lightBorder),
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${p.rating} ★ (${p.reviewsCount} تقييم) • ${p.specialties.join(", ")}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.0),
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

  Widget _buildEmptyState(String title) {
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
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'يمكنك حفظ الخدمات والمزودين المفضلين للوصول إليهم والحجز بضغطة زر واحدة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: widget.onExploreServicesTap,
              child: const Text('تصفح الخدمات الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
