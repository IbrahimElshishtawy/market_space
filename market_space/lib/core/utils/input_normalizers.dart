class InputNormalizers {
  static const Map<String, String> _arabicToWesternNumerals = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  static String convertArabicNumeralsToWestern(String input) {
    var result = input;
    _arabicToWesternNumerals.forEach((arabicChar, westernChar) {
      result = result.replaceAll(arabicChar, westernChar);
    });
    return result;
  }

  static String? normalizeEgyptianPhoneNumber(String rawPhoneNumber) {
    var cleanedNumber = convertArabicNumeralsToWestern(rawPhoneNumber)
        .replaceAll(RegExp(r'[\s\-\(\)]'), '')
        .trim();

    if (cleanedNumber.startsWith('0020')) {
      cleanedNumber = '+20${cleanedNumber.substring(4)}';
    } else if (cleanedNumber.startsWith('20') && cleanedNumber.length == 12) {
      cleanedNumber = '+$cleanedNumber';
    } else if (cleanedNumber.startsWith('01') && cleanedNumber.length == 11) {
      cleanedNumber = '+20${cleanedNumber.substring(1)}';
    }

    final isValidEgyptianNumber = RegExp(r'^\+20(10|11|12|15)[0-9]{8}$').hasMatch(cleanedNumber);
    if (!isValidEgyptianNumber) {
      return null;
    }

    return cleanedNumber;
  }

  static String trimAndCollapseSpaces(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
