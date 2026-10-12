import 'package:flutter/widgets.dart';
import '../core/config/app_config.dart';
import '../core/localization/locale_controller.dart';
import '../core/logging/app_logger.dart';
import '../core/mock_data/mock_data_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/platform/platform_info.dart';
import '../core/security/token_provider.dart';
import '../core/storage/preferences_service.dart';
import '../core/storage/secure_storage_service.dart';
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
  }) : sectorController = sectorController ?? SectorController(preferencesService: preferencesService);

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppDependenciesScope>();
    if (scope == null) {
      throw StateError('AppDependenciesScope not found in widget tree.');
    }
    return scope.dependencies;
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
