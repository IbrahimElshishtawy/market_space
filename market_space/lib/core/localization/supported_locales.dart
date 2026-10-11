import 'package:flutter/material.dart';

class SupportedLocales {
  static const Locale arabic = Locale('ar', 'EG');
  static const Locale english = Locale('en', 'US');

  static const List<Locale> all = [
    arabic,
    english,
  ];

  static bool isRtl(Locale locale) {
    return locale.languageCode == 'ar';
  }

  static Locale fromLanguageCode(String? code) {
    if (code == 'en') {
      return english;
    }
    return arabic;
  }
}
