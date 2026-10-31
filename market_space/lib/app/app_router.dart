import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home_services/presentation/pages/home_services_page.dart';
import '../features/home_services/presentation/pages/home_service_detail_page.dart';
import '../features/home_services/presentation/pages/service_provider_detail_page.dart';
import '../features/home_services/presentation/pages/home_services_booking_wizard_page.dart';
import '../features/home_services/presentation/pages/home_service_booking_detail_page.dart';
import '../features/home_services/presentation/pages/technician_tracking_page.dart';
import 'package:market_space/features/home_services/presentation/pages/ac_service_detail_page.dart';

import '../core/routing/route_guards.dart';
import '../core/routing/route_names.dart';
import '../core/theme/app_spacing.dart';
import '../features/building_materials/presentation/pages/building_material_category_detail_page.dart';
import '../features/building_materials/presentation/pages/building_material_product_detail_page.dart';
import '../features/building_materials/presentation/pages/building_materials_cart_page.dart';
import '../features/building_materials/presentation/pages/building_materials_categories_page.dart';
import '../features/building_materials/presentation/pages/building_materials_checkout_page.dart';
import '../features/building_materials/presentation/pages/building_materials_notifications_page.dart';
import '../features/building_materials/presentation/pages/building_materials_order_detail_page.dart';
import '../features/building_materials/presentation/pages/building_materials_orders_page.dart';
import '../features/building_materials/presentation/pages/building_materials_page.dart';
import '../features/building_materials/presentation/pages/rfq_create_page.dart';
import '../features/building_materials/presentation/pages/steel_rebar_listing_page.dart';
import '../features/navigation/presentation/pages/global_navigation_scaffold.dart';
import '../features/notifications/presentation/pages/global_notifications_page.dart';
import '../features/home_appliances/cart/presentation/pages/home_appliances_cart_page.dart';
import '../features/home_appliances/categories/presentation/pages/home_appliances_categories_page.dart';
import '../features/home_appliances/checkout/presentation/pages/home_appliances_checkout_page.dart';
import '../features/home_appliances/notifications/presentation/pages/home_appliances_notifications_page.dart';
import '../features/home_appliances/orders/presentation/pages/home_appliances_orders_page.dart';
import '../features/home_appliances/presentation/pages/appliance_category_listing_page.dart';
import '../features/home_appliances/presentation/pages/home_appliances_page.dart';
import '../features/real_estate/favorites/presentation/pages/real_estate_favorites_page.dart';
import '../features/real_estate/map/presentation/pages/real_estate_map_page.dart';
import '../features/real_estate/notifications/presentation/pages/real_estate_notifications_page.dart';
import '../features/real_estate/presentation/pages/real_estate_detail_page.dart';
import '../features/real_estate/presentation/pages/real_estate_page.dart';
import '../features/real_estate/reels/presentation/pages/reel_analytics_page.dart';
import '../features/real_estate/reels/presentation/pages/reel_publish_page.dart';
import '../features/real_estate/reels/presentation/pages/reels_page.dart';
import '../shared/widgets/app_error_view.dart';
import 'app_dependencies.dart';
import 'app_localization.dart';

class AppRouter {
  static GoRouter createRouter({
    RouteGuard? routeGuard,
    String initialLocation = RouteNames.root,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) async {
        if (routeGuard != null) {
          return await routeGuard.evaluateRedirect(context, state.uri.path);
        }
        return null;
      },
      errorBuilder: (context, state) {
        final strings = AppLocalization.of(context);
        return Scaffold(
          body: AppErrorView(
            title: strings.pageNotFound,
            message: state.uri.path,
            retryButtonLabel: strings.backToHome,
            onRetry: () => context.go(RouteNames.root),
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.root,
          name: RouteNames.rootName,
          builder: (context, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return GlobalNavigationScaffold(initialIndex: tab);
          },
        ),
        GoRoute(
          path: RouteNames.explore,
          name: RouteNames.exploreName,
          builder: (context, state) {
            return const GlobalNavigationScaffold(initialIndex: 1);
          },
        ),
        GoRoute(
          path: RouteNames.myActivity,
          name: RouteNames.myActivityName,
          builder: (context, state) {
            return const GlobalNavigationScaffold(initialIndex: 2);
          },
        ),
        GoRoute(
          path: RouteNames.favorites,
          name: RouteNames.favoritesName,
          builder: (context, state) {
            return const GlobalNavigationScaffold(initialIndex: 3);
          },
        ),
        GoRoute(
          path: RouteNames.profile,
          name: RouteNames.profileName,
          builder: (context, state) {
            return const GlobalNavigationScaffold(initialIndex: 4);
          },
        ),
        GoRoute(
          path: RouteNames.globalNotifications,
          name: RouteNames.globalNotificationsName,
          builder: (context, state) {
            return const GlobalNotificationsPage();
          },
        ),
        GoRoute(
          path: RouteNames.realEstate,
          name: RouteNames.realEstateName,
          builder: (context, state) {
            return const RealEstatePage();
          },
        ),
        GoRoute(
          path: '/real-estate/map',
          name: 'real_estate_map',
          builder: (context, state) {
            return const RealEstateMapPage();
          },
        ),
        GoRoute(
          path: '/real-estate/favorites',
          name: 'real_estate_favorites',
          builder: (context, state) {
            return const RealEstateFavoritesPage();
          },
        ),
        GoRoute(
          path: '/real-estate/notifications',
          name: 'real_estate_notifications',
          builder: (context, state) {
            return const RealEstateNotificationsPage();
          },
        ),
        GoRoute(
          path: '/real-estate/reels',
          name: 'real_estate_reels',
          builder: (context, state) {
            return const ReelsPage();
          },
        ),
        GoRoute(
          path: '/real-estate/reels/analytics',
          name: 'real_estate_reels_analytics',
          builder: (context, state) {
            final ownerId = state.uri.queryParameters['ownerId'] ?? 'adv-1';
            return ReelAnalyticsPage(ownerId: ownerId);
          },
        ),
        GoRoute(
          path: '/real-estate/reels/publish',
          name: 'real_estate_reels_publish',
          builder: (context, state) {
            return const ReelPublishPage();
          },
        ),
        GoRoute(
          path: RouteNames.realEstateDetail,
          name: RouteNames.realEstateDetailName,
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? 'aqar-1';
            return RealEstateDetailPage(listingId: id);
          },
        ),
        GoRoute(
          path: RouteNames.homeServices,
          name: RouteNames.homeServicesName,
          builder: (context, state) {
            return const HomeServicesPage();
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesCatalog,
          name: RouteNames.homeServicesCatalogName,
          builder: (context, state) {
            return const HomeServicesPage(initialTabIndex: 1);
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesBookings,
          name: RouteNames.homeServicesBookingsName,
          builder: (context, state) {
            return const HomeServicesPage(initialTabIndex: 2);
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesFavorites,
          name: RouteNames.homeServicesFavoritesName,
          builder: (context, state) {
            return const HomeServicesPage(initialTabIndex: 3);
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesNotifications,
          name: RouteNames.homeServicesNotificationsName,
          builder: (context, state) {
            return const HomeServicesPage(initialTabIndex: 4);
          },
        ),
        GoRoute(
          path: RouteNames.homeServiceDetail,
          name: RouteNames.homeServiceDetailName,
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? 'srv-ac-wash';
            return HomeServiceDetailPage(serviceId: id);
          },
        ),
        GoRoute(
          path: RouteNames.homeServiceProviderDetail,
          name: RouteNames.homeServiceProviderDetailName,
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? 'prov-fixit';
            return ServiceProviderDetailPage(providerId: id);
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesBookingWizard,
          name: RouteNames.homeServicesBookingWizardName,
          builder: (context, state) {
            final serviceId = state.uri.queryParameters['serviceId'];
            final providerId = state.uri.queryParameters['providerId'];
            return HomeServicesBookingWizardPage(
              serviceId: serviceId,
              providerId: providerId,
            );
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesBookingDetail,
          name: RouteNames.homeServicesBookingDetailName,
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? 'HS-BK-88421';
            return HomeServiceBookingDetailPage(bookingId: id);
          },
        ),
        GoRoute(
          path: RouteNames.homeServicesTechnicianTracking,
          name: RouteNames.homeServicesTechnicianTrackingName,
          builder: (context, state) {
            final id = state.uri.queryParameters['id'] ?? 'HS-BK-88421';
            return TechnicianTrackingPage(bookingId: id);
          },
        ),
        GoRoute(
          path: RouteNames.acServiceDetail,
          name: RouteNames.acServiceDetailName,
          builder: (context, state) {
            return const AcServiceDetailPage();
          },
        ),
        GoRoute(
          path: RouteNames.homeAppliances,
          name: RouteNames.homeAppliancesName,
          builder: (context, state) {
            return const HomeAppliancesPage();
          },
        ),
        GoRoute(
          path: '/home-appliances/categories',
          name: 'home_appliances_categories',
          builder: (context, state) {
            return const HomeAppliancesCategoriesPage();
          },
        ),
        GoRoute(
          path: '/home-appliances/cart',
          name: 'home_appliances_cart',
          builder: (context, state) {
            return const HomeAppliancesCartPage();
          },
        ),
        GoRoute(
          path: '/home-appliances/checkout',
          name: 'home_appliances_checkout',
          builder: (context, state) {
            return const HomeAppliancesCheckoutPage();
          },
        ),
        GoRoute(
          path: '/home-appliances/orders',
          name: 'home_appliances_orders',
          builder: (context, state) {
            return const HomeAppliancesOrdersPage();
          },
        ),
        GoRoute(
          path: '/home-appliances/notifications',
          name: 'home_appliances_notifications',
          builder: (context, state) {
            return const HomeAppliancesNotificationsPage();
          },
        ),
        GoRoute(
          path: RouteNames.applianceCategoryListing,
          name: RouteNames.applianceCategoryListingName,
          builder: (context, state) {
            final categoryId =
                state.uri.queryParameters['categoryId'] ?? 'cat-tv';
            return ApplianceCategoryListingPage(categoryId: categoryId);
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterials,
          name: RouteNames.buildingMaterialsName,
          builder: (context, state) {
            return const BuildingMaterialsPage();
          },
        ),
        GoRoute(
          path: RouteNames.steelRebarListing,
          name: RouteNames.steelRebarListingName,
          builder: (context, state) {
            return const SteelRebarListingPage();
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialCategoryDetail,
          name: RouteNames.buildingMaterialCategoryDetailName,
          builder: (context, state) {
            final categoryId =
                state.uri.queryParameters['categoryId'] ?? 'cat-steel';
            return BuildingMaterialCategoryDetailPage(categoryId: categoryId);
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsCategories,
          name: RouteNames.buildingMaterialsCategoriesName,
          builder: (context, state) {
            return const BuildingMaterialsCategoriesPage();
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsCart,
          name: RouteNames.buildingMaterialsCartName,
          builder: (context, state) {
            return const BuildingMaterialsCartPage();
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsCheckout,
          name: RouteNames.buildingMaterialsCheckoutName,
          builder: (context, state) {
            return const BuildingMaterialsCheckoutPage();
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsOrders,
          name: RouteNames.buildingMaterialsOrdersName,
          builder: (context, state) {
            return const BuildingMaterialsOrdersPage();
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsOrderDetail,
          name: RouteNames.buildingMaterialsOrderDetailName,
          builder: (context, state) {
            final orderId =
                state.uri.queryParameters['orderId'] ?? 'ord-bm-901';
            return BuildingMaterialsOrderDetailPage(orderId: orderId);
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsNotifications,
          name: RouteNames.buildingMaterialsNotificationsName,
          builder: (context, state) {
            return const BuildingMaterialsNotificationsPage();
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsProductDetail,
          name: RouteNames.buildingMaterialsProductDetailName,
          builder: (context, state) {
            final productId =
                state.uri.queryParameters['productId'] ?? 'prod-steel-ezz-12';
            return BuildingMaterialProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: RouteNames.buildingMaterialsRfq,
          name: RouteNames.buildingMaterialsRfqName,
          builder: (context, state) {
            return const RfqCreatePage();
          },
        ),
      ],
    );
  }
}

class FoundationRootPlaceholder extends StatelessWidget {
  const FoundationRootPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final strings = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Language',
            onPressed: () => dependencies.localeController.toggleLocale(),
          ),
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Theme',
            onPressed: () => dependencies.themeController.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 64.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                strings.appTitle,
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Environment: ${dependencies.appConfig.environment.identifierName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
