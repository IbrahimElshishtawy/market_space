import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('formats ISO date to yyyy-MM-dd correctly', () {
      final dateTime = DateTime(2026, 10, 11, 14, 30);
      final formattedDate = DateTimeUtils.formatIsoDate(dateTime);
      expect(formattedDate, '2026-10-11');
    });

    test('parses ISO date string safely', () {
      final parsed = DateTimeUtils.tryParseIsoDate('2026-10-11T14:30:00Z');
      expect(parsed, isNotNull);
      expect(parsed?.year, 2026);
      expect(parsed?.month, 10);
      expect(parsed?.day, 11);
    });

    test('returns null for invalid or empty date strings', () {
      expect(DateTimeUtils.tryParseIsoDate(null), isNull);
      expect(DateTimeUtils.tryParseIsoDate(''), isNull);
      expect(DateTimeUtils.tryParseIsoDate('invalid-date'), isNull);
    });
  });
}
