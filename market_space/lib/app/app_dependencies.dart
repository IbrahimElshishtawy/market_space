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
import '../features/building_materials/presentation/controllers/building_materials_cart_controller.dart';
import '../features/building_materials/presentation/controllers/building_materials_notification_controller.dart';
import '../features/building_materials/presentation/controllers/building_materials_order_controller.dart';
import '../features/home_appliances/cart/presentation/controllers/home_appliances_cart_controller.dart';
import '../features/home_appliances/notifications/presentation/controllers/home_appliances_notification_controller.dart';
import '../features/home_appliances/orders/presentation/controllers/home_appliances_order_controller.dart';
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
           );

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
