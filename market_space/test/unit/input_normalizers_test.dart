import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/utils/input_normalizers.dart';

void main() {
  group('InputNormalizers', () {
    test('converts Arabic numerals to Western digits', () {
      final converted = InputNormalizers.convertArabicNumeralsToWestern('٠١٠١٢٣٤٥٦٧٨');
      expect(converted, '01012345678');
    });

    test('normalizes standard 010 Egyptian mobile number to +20 format', () {
      final normalized = InputNormalizers.normalizeEgyptianPhoneNumber('01012345678');
      expect(normalized, '+201012345678');
    });

    test('normalizes 0020 Egyptian mobile number to +20 format', () {
      final normalized = InputNormalizers.normalizeEgyptianPhoneNumber('00201112345678');
      expect(normalized, '+201112345678');
    });

    test('preserves valid +20 Egyptian mobile number', () {
      final normalized = InputNormalizers.normalizeEgyptianPhoneNumber('+201212345678');
      expect(normalized, '+201212345678');
    });

    test('returns null for invalid phone numbers', () {
      expect(InputNormalizers.normalizeEgyptianPhoneNumber('12345'), isNull);
      expect(InputNormalizers.normalizeEgyptianPhoneNumber('01912345678'), isNull);
    });

    test('trims and collapses redundant white spaces', () {
      final result = InputNormalizers.trimAndCollapseSpaces('   سيارة   هيونداي   موديل  2022  ');
      expect(result, 'سيارة هيونداي موديل 2022');
    });
  });
}
