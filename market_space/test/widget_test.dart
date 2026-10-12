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
import 'package:market_space/shared/state/sector_controller.dart';
import 'package:market_space/shared/widgets/market_home_screen.dart';

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

AppDependencies createTestDependencies() {
  final preferencesService = InMemoryPreferencesService();
  final secureStorageService = InMemorySecureStorageService();
  final tokenProvider = SecureTokenProvider(secureStorageService: secureStorageService);
  final localeController = LocaleController(preferencesService: preferencesService);
  final themeController = ThemeController(preferencesService: preferencesService);
  final sectorController = SectorController(preferencesService: preferencesService);

  return AppDependencies(
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
    sectorController: sectorController,
  );
}

void main() {
  testWidgets('MarketSpaceApp boots and displays Stitch Bazar Jo marketplace screen', (WidgetTester tester) async {
    final dependencies = createTestDependencies();

    await tester.pumpWidget(MarketSpaceApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(find.byType(MarketHomeScreen), findsOneWidget);
    expect(find.text('بازار جو'), findsOneWidget);
    expect(find.text('عقارات • تشطيب ومُوَن • خدمات'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('عقارات للبيع'), findsWidgets);
    expect(find.text('عقارات للإيجار'), findsWidgets);
    expect(find.text('مُوَن وبناء'), findsOneWidget);
    expect(find.text('خدمات وصيانة'), findsOneWidget);
    expect(find.text('طلب مواد البناء والمُوَن والتوريد المباشر إلى موقع مشروعك'), findsOneWidget);
  });

  testWidgets('MarketHomeScreen renders without overflow on compact mobile screen (320x568)', (WidgetTester tester) async {
    final dependencies = createTestDependencies();

    tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MarketSpaceApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    if (exception is FlutterError) {
      for (final line in exception.diagnostics) {
        debugPrint('DIAGNOSTIC: ${line.toStringDeep()}');
      }
    }
    expect(exception, isNull);
    expect(find.text('بازار جو'), findsOneWidget);
  });

  testWidgets('MarketHomeScreen renders without overflow on large mobile screen (430x932)', (WidgetTester tester) async {
    final dependencies = createTestDependencies();

    tester.view.physicalSize = const Size(430 * 3.0, 932 * 3.0);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MarketSpaceApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('بازار جو'), findsOneWidget);
  });

  testWidgets('MarketHomeScreen sector switching persists choice and updates state', (WidgetTester tester) async {
    final dependencies = createTestDependencies();

    await tester.pumpWidget(MarketSpaceApp(dependencies: dependencies));
    await tester.pumpAndSettle();

    final buildingMaterialsChip = find.text('مُوَن ومواد بناء');
    expect(buildingMaterialsChip, findsOneWidget);

    await tester.tap(buildingMaterialsChip);
    await tester.pumpAndSettle();

    expect(dependencies.sectorController.value.titleAr, 'مواد البناء والمُوَن');
  });
}
