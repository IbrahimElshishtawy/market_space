import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/security/secure_token_provider.dart';
import 'package:market_space/core/storage/preferences_service.dart';
import 'package:market_space/core/storage/secure_storage_service.dart';

void main() {
  group('InMemoryPreferencesService', () {
    test('stores and retrieves string values', () async {
      final preferencesService = InMemoryPreferencesService();
      await preferencesService.setString('locale', 'ar');
      final retrievedValue = await preferencesService.getString('locale');
      expect(retrievedValue, 'ar');
    });

    test('stores and retrieves boolean values', () async {
      final preferencesService = InMemoryPreferencesService();
      await preferencesService.setBool('is_dark', true);
      final retrievedValue = await preferencesService.getBool('is_dark');
      expect(retrievedValue, isTrue);
    });

    test('removes and clears keys correctly', () async {
      final preferencesService = InMemoryPreferencesService();
      await preferencesService.setString('key1', 'val1');
      await preferencesService.setString('key2', 'val2');

      await preferencesService.remove('key1');
      expect(await preferencesService.getString('key1'), isNull);
      expect(await preferencesService.getString('key2'), 'val2');

      await preferencesService.clear();
      expect(await preferencesService.getString('key2'), isNull);
    });
  });

  group('SecureTokenProvider', () {
    test('saves, retrieves, and clears tokens safely', () async {
      final secureStorageService = InMemorySecureStorageService();
      final tokenProvider = SecureTokenProvider(secureStorageService: secureStorageService);

      expect(await tokenProvider.hasValidToken(), isFalse);

      await tokenProvider.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      expect(await tokenProvider.hasValidToken(), isTrue);
      expect(await tokenProvider.getAccessToken(), 'access_123');
      expect(await tokenProvider.getRefreshToken(), 'refresh_456');

      await tokenProvider.clearTokens();

      expect(await tokenProvider.hasValidToken(), isFalse);
      expect(await tokenProvider.getAccessToken(), isNull);
      expect(await tokenProvider.getRefreshToken(), isNull);
    });
  });
}
