import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_dependencies.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_network_image.dart';

class ServiceProviderDetailPage extends StatelessWidget {
  final String providerId;

  const ServiceProviderDetailPage({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final catalogCtrl = dependencies.homeServicesCatalogController;
    final favCtrl = dependencies.homeServicesFavoritesController;

    final provider = catalogCtrl.featuredProviders.firstWhere(
      (p) => p.id == providerId,
      orElse: () => catalogCtrl.featuredProviders.first,
    );

    final providerServices = catalogCtrl.services.where(
      (s) => s.availableProviderIds.contains(provider.id),
    ).toList();

    return ListenableBuilder(
      listenable: favCtrl,
      builder: (context, _) {
        final isFav = favCtrl.isProviderFavorite(provider.id);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.backgroundOf(context),
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
              elevation: 0.5,
              iconTheme: IconThemeData(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.neutral,
              ),
              title: Text(
                provider.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.neutral,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav
                        ? Colors.red
                        : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextPrimary
                            : AppColors.neutral),
                  ),
                  onPressed: () => favCtrl.toggleProvider(provider),
                ),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Header Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : Colors.white,
                      borderRadius: AppRadii.lg,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadii.lg,
                              child: AppNetworkImage(
                                imageUrl: provider.logoUrl,
                                width: 70.0,
                                height: 70.0,
                                fit: BoxFit.cover,
                                fallbackIcon: Icons.business_rounded,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          provider.name,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (provider.isVerified)
                                        const Icon(Icons.verified_rounded, color: Colors.blue, size: 20.0),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'خبرة ${provider.experienceYears} عاماً • ${provider.completedJobsCount}+ عملية صيانة ناجحة',
                                    style: const TextStyle(fontSize: 12.0, color: AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18.0),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '${provider.rating} (${provider.reviewsCount} تقييم)',
                                        style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24.0),

                        Text(
                          provider.description,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextPrimary
                                : AppColors.neutral,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 12.0),

                        // Working hours & areas
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 16.0, color: AppColors.primary),
                            const SizedBox(width: 6.0),
                            Text(
                              'أوقات العمل: ${provider.workingHours}',
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16.0, color: AppColors.primary),
                            const SizedBox(width: 6.0),
                            Expanded(
                              child: Text(
                                'المناطق المغطاة: ${provider.coverageAreas.join("، ")}',
                                style: const TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Warranty & Guarantees
                  if (provider.warrantyDescription != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: AppRadii.lg,
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security_rounded, color: Colors.green.shade700, size: 28.0),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الضمان وسياسة الجودة',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  provider.warrantyDescription!,
                                  style: TextStyle(fontSize: 12.0, color: Colors.green.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Services by this provider
                  const Text(
                    'الخدمات المتاحة لدى هذا المزود',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  ...providerServices.map((service) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.lg,
                        side: const BorderSide(color: AppColors.lightBorder),
                      ),
                      elevation: 0,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: AppRadii.md,
                          child: AppNetworkImage(
                            imageUrl: service.images.isNotEmpty ? service.images.first : '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.handyman_rounded,
                          ),
                        ),
                        title: Text(
                          service.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                        ),
                        subtitle: Text(
                          service.formattedPrice,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            minimumSize: const Size(60, 32),
                          ),
                          onPressed: () {
                            context.push('/home-services/book?serviceId=${service.id}&providerId=${provider.id}');
                          },
                          child: const Text('احجز معه'),
                        ),
                        onTap: () {
                          context.push('/home-services/service-detail?id=${service.id}');
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
