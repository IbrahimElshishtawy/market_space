import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/config/app_config.dart';
import 'package:market_space/core/config/config_validator.dart';
import 'package:market_space/core/config/environment.dart';

void main() {
  group('ConfigValidator', () {
    test('passes for valid development configuration', () {
      final config = AppConfig.development();
      expect(() => ConfigValidator.validate(config), returnsNormally);
    });

    test('throws ArgumentError when apiBaseUrl is empty', () {
      const config = AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: '',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        enableLogging: true,
        enableMockMode: true,
      );
      expect(() => ConfigValidator.validate(config), throwsArgumentError);
    });

    test('throws ArgumentError when apiBaseUrl is malformed', () {
      const config = AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'not_a_valid_url',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        enableLogging: true,
        enableMockMode: true,
      );
      expect(() => ConfigValidator.validate(config), throwsArgumentError);
    });

    test('throws ArgumentError when timeout is zero or negative', () {
      const config = AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: 'https://api.marketspace.eg',
        connectTimeout: Duration.zero,
        receiveTimeout: Duration(seconds: 10),
        enableLogging: true,
        enableMockMode: true,
      );
      expect(() => ConfigValidator.validate(config), throwsArgumentError);
    });
  });
}
