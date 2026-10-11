class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String acceptLanguage = 'Accept-Language';
  static const String authorization = 'Authorization';
  static const String requestId = 'X-Request-ID';

  static const String applicationJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  static Map<String, String> defaultHeaders({String languageCode = 'ar'}) {
    return {
      contentType: applicationJson,
      accept: applicationJson,
      acceptLanguage: languageCode,
    };
  }
}
