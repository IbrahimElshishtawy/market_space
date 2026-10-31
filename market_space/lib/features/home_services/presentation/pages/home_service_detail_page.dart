import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/home_service_model.dart';
import '../controllers/home_services_favorites_controller.dart';

class HomeServiceDetailPage extends StatelessWidget {
  final String serviceId;

  const HomeServiceDetailPage({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final catalogCtrl = dependencies.homeServicesCatalogController;
    final favCtrl = dependencies.homeServicesFavoritesController;

    final service = catalogCtrl.services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => catalogCtrl.popularServices.first,
    );

    return ListenableBuilder(
      listenable: favCtrl,
      builder: (context, _) {
        final isFav = favCtrl.isServiceFavorite(service.id);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.lightBackground,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Collapsible App Bar with Image
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  actions: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : AppColors.neutral,
                        ),
                        onPressed: () => favCtrl.toggleService(service),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          service.images.isNotEmpty
                              ? service.images.first
                              : 'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=600',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.handyman_rounded, size: 64, color: Colors.grey),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Service Details Body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadii.full,
                              ),
                              child: Text(
                                service.pricingType.labelAr,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),

                        // Rating, duration, coverage
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 18.0),
                            const SizedBox(width: 4.0),
                            Text(
                              '${service.rating} (${service.reviewsCount} تقييم)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Icon(Icons.schedule_rounded, size: 16.0, color: Colors.grey),
                            const SizedBox(width: 4.0),
                            Text(
                              service.estimatedDuration,
                              style: const TextStyle(fontSize: 13.0, color: Colors.grey),
                            ),
                          ],
                        ),

                        const Divider(height: 32.0),

                        // Overview
                        const Text(
                          'عن الخدمة',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          service.detailedDescription,
                          style: const TextStyle(
                            fontSize: 14.0,
                            height: 1.5,
                            color: AppColors.neutral,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // What's included
                        if (service.includedTasks.isNotEmpty) ...[
                          _buildSectionTitle('ما تشمله الخدمة', Icons.check_circle_outline_rounded, Colors.green),
                          const SizedBox(height: 8.0),
                          ...service.includedTasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_rounded, color: Colors.green, size: 18.0),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(task, style: const TextStyle(fontSize: 13.0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // What's excluded
                        if (service.excludedTasks.isNotEmpty) ...[
                          _buildSectionTitle('الأعمال غير المشمولة', Icons.cancel_outlined, Colors.red),
                          const SizedBox(height: 8.0),
                          ...service.excludedTasks.map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.close_rounded, color: Colors.red, size: 18.0),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(task, style: const TextStyle(fontSize: 13.0, color: Colors.black87)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Warranty & Cancellation
                        _buildInfoCard(
                          title: 'الضمان المعتمد',
                          content: service.warrantyText ?? 'ضمان 30 يوماً على سلامة وجودة الصيانة المنفذة.',
                          icon: Icons.verified_user_outlined,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildInfoCard(
                          title: 'سياسة الإلغاء وتعديل الموعد',
                          content: service.cancellationPolicy,
                          icon: Icons.policy_outlined,
                          color: Colors.orange.shade800,
                        ),

                        // FAQs
                        if (service.faqs.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const Text(
                            'الأسئلة الشائعة',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          ...service.faqs.map(
                            (faq) => ExpansionTile(
                              title: Text(faq.question, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: Text(faq.answer, style: const TextStyle(fontSize: 13.0, color: AppColors.lightTextSecondary)),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 100.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fixed Bottom Checkout Bar
            bottomNavigationBar: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10.0,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'السعر المتوقع',
                          style: TextStyle(fontSize: 11.0, color: AppColors.lightTextSecondary),
                        ),
                        Text(
                          service.formattedPrice,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        onPressed: () {
                          context.push('/home-services/book?serviceId=${service.id}');
                        },
                        child: const Text(
                          'احجز الخدمة الآن',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.0),
        const SizedBox(width: 8.0),
        Text(
          title,
          style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppRadii.md,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22.0),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  content,
                  style: const TextStyle(fontSize: 12.0, color: AppColors.neutral),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
