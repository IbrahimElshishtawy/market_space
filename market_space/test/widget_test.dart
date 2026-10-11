import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/app/app.dart';
import 'package:market_space/app/app_dependencies.dart';
import 'package:market_space/app/app_theme.dart';
import 'package:market_space/core/config/app_config.dart';
import 'package:market_space/core/localization/locale_controller.dart';
import 'package:market_space/core/logging/app_logger.dart';
import 'package:market_space/core/mock_data/mock_data_provider.dart';
import 'package:market_space/core/network/api_client.dart';
import 'package:market_space/core/network/network_info.dart';
import 'package:market_space/core/platform/platform_info.dart';
import 'package:market_space/core/security/secure_token_provider.dart';
import 'package:market_space/core/storage/preferences_service.dart';
import 'package:market_space/core/storage/secure_storage_service.dart';

class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class FakeApiClient implements ApiClient {
  @override
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('MarketSpaceApp boots and displays foundation root placeholder', (WidgetTester tester) async {
    final preferencesService = InMemoryPreferencesService();
    final secureStorageService = InMemorySecureStorageService();
    final tokenProvider = SecureTokenProvider(secureStorageService: secureStorageService);
    final localeController = LocaleController(preferencesService: preferencesService);
    final themeController = ThemeController(preferencesService: preferencesService);

    final dependencies = AppDependencies(
      appConfig: AppConfig.development(),
      logger: const AppLoggerImpl(isLoggingEnabled: false),
      networkInfo: FakeNetworkInfo(),
      preferencesService: preferencesService,
      secureStorageService: secureStorageService,
      tokenProvider: tokenProvider,
      apiClient: FakeApiClient(),
      mockDataProvider: MockDataProvider(),
      platformInfo: const PlatformInfoImpl(),
      localeController: localeController,
      themeController: themeController,
    );

    await tester.pumpWidget(MarketSpaceApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byIcon(Icons.storefront_rounded), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
  });
}
