class ApiEndpoints {
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/token/refresh';
  static const String logout = '/auth/logout';

  static const String categories = '/categories';
  static String categoryFields(String categorySlug) => '/categories/$categorySlug/fields';

  static const String listings = '/listings';
  static String listingDetails(String listingId) => '/listings/$listingId';
  static const String myFavorites = '/listings/favorites';
  static String toggleFavorite(String listingId) => '/listings/$listingId/favorite';

  static const String uploadPresignedUrls = '/media/upload-urls';
  static const String videoStreamToken = '/media/video-token';
  static const String videoFeed = '/videos/feed';

  static const String checkoutSession = '/payments/checkout';
}
