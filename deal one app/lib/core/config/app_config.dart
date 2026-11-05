import 'environment.dart';

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;
  final bool enableMockMode;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableLogging,
    required this.enableMockMode,
  });

  factory AppConfig.development() {
    return const AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://localhost:3000/api/v1',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      enableLogging: true,
      enableMockMode: true,
    );
  }

  factory AppConfig.staging() {
    return const AppConfig(
      environment: AppEnvironment.staging,
      apiBaseUrl: 'https://staging-api.marketspace.eg/api/v1',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      enableLogging: true,
      enableMockMode: false,
    );
  }

  factory AppConfig.production() {
    return const AppConfig(
      environment: AppEnvironment.production,
      apiBaseUrl: 'https://api.marketspace.eg/api/v1',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      enableLogging: false,
      enableMockMode: false,
    );
  }
}
