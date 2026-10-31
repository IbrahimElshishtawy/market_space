import 'package:flutter/widgets.dart';

import '../core/config/app_config.dart';
import '../core/localization/locale_controller.dart';
import '../core/logging/app_logger.dart';
import '../core/mock_data/mock_data_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/notifications/data/repositories/notification_repository.dart';
import '../core/notifications/presentation/state/notification_controller.dart';
import '../core/platform/platform_info.dart';
import '../core/security/token_provider.dart';
import '../core/storage/preferences_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/activity/presentation/controllers/unified_activity_controller.dart';
import '../features/building_materials/presentation/controllers/building_materials_cart_controller.dart';
import '../features/building_materials/presentation/controllers/building_materials_notification_controller.dart';
import '../features/building_materials/presentation/controllers/building_materials_order_controller.dart';
import '../features/explore/presentation/controllers/explore_controller.dart';
import '../features/favorites/presentation/controllers/unified_favorites_controller.dart';
import '../features/home_appliances/cart/presentation/controllers/home_appliances_cart_controller.dart';
import '../features/home_appliances/notifications/presentation/controllers/home_appliances_notification_controller.dart';
import '../features/home_appliances/orders/presentation/controllers/home_appliances_order_controller.dart';
import '../features/home_services/data/repositories/home_services_booking_repository.dart';
import '../features/home_services/data/repositories/home_services_favorites_repository.dart';
import '../features/home_services/data/repositories/home_services_repository.dart';
import '../features/home_services/presentation/controllers/home_services_booking_controller.dart';
import '../features/home_services/presentation/controllers/home_services_catalog_controller.dart';
import '../features/home_services/presentation/controllers/home_services_favorites_controller.dart';
import '../features/cars/data/repositories/cars_repository.dart';
import '../features/cars/presentation/controllers/cars_controller.dart';
import '../features/fashion/data/repositories/fashion_repository.dart';
import '../features/fashion/presentation/controllers/fashion_cart_controller.dart';
import '../features/fashion/presentation/controllers/fashion_controller.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/real_estate/favorites/presentation/controllers/real_estate_favorites_controller.dart';
import '../features/real_estate/notifications/presentation/controllers/real_estate_notification_controller.dart';
import '../shared/state/sector_controller.dart';
import 'app_theme.dart';

class AppDependencies {
  final AppConfig appConfig;
  final AppLogger logger;
  final NetworkInfo networkInfo;
  final PreferencesService preferencesService;
  final SecureStorageService secureStorageService;
  final TokenProvider tokenProvider;
  final ApiClient apiClient;
  final MockDataProvider mockDataProvider;
  final PlatformInfo platformInfo;
  final LocaleController localeController;
  final ThemeController themeController;
  final SectorController sectorController;
  final NotificationRepository notificationRepository;
  final NotificationController notificationController;
  final RealEstateFavoritesController realEstateFavoritesController;
  final RealEstateNotificationController realEstateNotificationController;
  final HomeAppliancesCartController homeAppliancesCartController;
  final HomeAppliancesOrderController homeAppliancesOrderController;
  final HomeAppliancesNotificationController
  homeAppliancesNotificationController;
  final BuildingMaterialsCartController buildingMaterialsCartController;
  final BuildingMaterialsOrderController buildingMaterialsOrderController;
  final BuildingMaterialsNotificationController
  buildingMaterialsNotificationController;
  final HomeServicesRepository homeServicesRepository;
  final HomeServicesBookingRepository homeServicesBookingRepository;
  final HomeServicesFavoritesRepository homeServicesFavoritesRepository;
  final HomeServicesCatalogController homeServicesCatalogController;
  final HomeServicesBookingController homeServicesBookingController;
  final HomeServicesFavoritesController homeServicesFavoritesController;
  final CarsRepository carsRepository;
  final CarsController carsController;
  final FashionRepository fashionRepository;
  final FashionController fashionController;
  final FashionCartController fashionCartController;
  final ExploreController exploreController;
  final UnifiedActivityController unifiedActivityController;
  final UnifiedFavoritesController unifiedFavoritesController;
  final ProfileController profileController;

  AppDependencies({
    required this.appConfig,
    required this.logger,
    required this.networkInfo,
    required this.preferencesService,
    required this.secureStorageService,
    required this.tokenProvider,
    required this.apiClient,
    required this.mockDataProvider,
    required this.platformInfo,
    required this.localeController,
    required this.themeController,
    SectorController? sectorController,
    NotificationRepository? notificationRepository,
    NotificationController? notificationController,
    RealEstateFavoritesController? realEstateFavoritesController,
    RealEstateNotificationController? realEstateNotificationController,
    HomeAppliancesCartController? homeAppliancesCartController,
    HomeAppliancesOrderController? homeAppliancesOrderController,
    HomeAppliancesNotificationController? homeAppliancesNotificationController,
    BuildingMaterialsCartController? buildingMaterialsCartController,
    BuildingMaterialsOrderController? buildingMaterialsOrderController,
    BuildingMaterialsNotificationController?
    buildingMaterialsNotificationController,
    HomeServicesRepository? homeServicesRepository,
    HomeServicesBookingRepository? homeServicesBookingRepository,
    HomeServicesFavoritesRepository? homeServicesFavoritesRepository,
    HomeServicesCatalogController? homeServicesCatalogController,
    HomeServicesBookingController? homeServicesBookingController,
    HomeServicesFavoritesController? homeServicesFavoritesController,
    CarsRepository? carsRepository,
    CarsController? carsController,
    FashionRepository? fashionRepository,
    FashionController? fashionController,
    FashionCartController? fashionCartController,
    ExploreController? exploreController,
    UnifiedActivityController? unifiedActivityController,
    UnifiedFavoritesController? unifiedFavoritesController,
    ProfileController? profileController,
  }) : sectorController =
           sectorController ??
           SectorController(preferencesService: preferencesService),
       notificationRepository =
           notificationRepository ?? NotificationRepositoryImpl(),
       notificationController =
           notificationController ??
           NotificationController(
             repository: notificationRepository ?? NotificationRepositoryImpl(),
           ),
       realEstateFavoritesController =
           realEstateFavoritesController ?? RealEstateFavoritesController(),
       realEstateNotificationController =
           realEstateNotificationController ??
           RealEstateNotificationController(),
       homeAppliancesCartController =
           homeAppliancesCartController ?? HomeAppliancesCartController(),
       homeAppliancesOrderController =
           homeAppliancesOrderController ?? HomeAppliancesOrderController(),
       homeAppliancesNotificationController =
           homeAppliancesNotificationController ??
           HomeAppliancesNotificationController(),
       buildingMaterialsCartController =
           buildingMaterialsCartController ?? BuildingMaterialsCartController(),
       buildingMaterialsOrderController =
           buildingMaterialsOrderController ??
           BuildingMaterialsOrderController(),
       buildingMaterialsNotificationController =
           buildingMaterialsNotificationController ??
           BuildingMaterialsNotificationController(
             repository: notificationRepository ?? NotificationRepositoryImpl(),
           ),
       homeServicesRepository =
           homeServicesRepository ?? HomeServicesRepositoryImpl(),
       homeServicesBookingRepository =
           homeServicesBookingRepository ?? HomeServicesBookingRepositoryImpl(),
       homeServicesFavoritesRepository =
           homeServicesFavoritesRepository ??
           HomeServicesFavoritesRepositoryImpl(),
       homeServicesCatalogController =
           homeServicesCatalogController ??
           HomeServicesCatalogController(
             repository: homeServicesRepository ?? HomeServicesRepositoryImpl(),
           ),
       homeServicesBookingController =
           homeServicesBookingController ??
           HomeServicesBookingController(
             repository:
                 homeServicesBookingRepository ??
                 HomeServicesBookingRepositoryImpl(),
           ),
       homeServicesFavoritesController =
           homeServicesFavoritesController ??
           HomeServicesFavoritesController(
             favoritesRepository:
                 homeServicesFavoritesRepository ??
                 HomeServicesFavoritesRepositoryImpl(),
             servicesRepository:
                 homeServicesRepository ?? HomeServicesRepositoryImpl(),
           ),
       carsRepository = carsRepository ?? MockCarsRepository(),
       carsController =
           carsController ??
           CarsController(
             repository: carsRepository ?? MockCarsRepository(),
           ),
       fashionRepository = fashionRepository ?? MockFashionRepository(),
       fashionController =
           fashionController ??
           FashionController(
             repository: fashionRepository ?? MockFashionRepository(),
           ),
       fashionCartController =
           fashionCartController ?? FashionCartController(),
       exploreController = exploreController ?? ExploreController(),
       unifiedActivityController =
           unifiedActivityController ?? UnifiedActivityController(),
       unifiedFavoritesController =
           unifiedFavoritesController ?? UnifiedFavoritesController(),
       profileController = profileController ?? ProfileController();

  static AppDependencies of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    if (scope == null) {
      throw StateError('AppDependenciesScope not found in widget tree.');
    }
    return scope.dependencies;
  }

  static AppDependencies? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    return scope?.dependencies;
  }
}

class AppDependenciesScope extends InheritedWidget {
  final AppDependencies dependencies;

  const AppDependenciesScope({
    super.key,
    required this.dependencies,
    required super.child,
  });

  @override
  bool updateShouldNotify(AppDependenciesScope oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}
