import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataProvider {
  static const String categoriesAssetPath = 'assets/mock_data/categories.json';
  static const String listingsFeedAssetPath = 'assets/mock_data/listings_feed.json';
  static const String listingDetailAssetPath = 'assets/mock_data/listing_detail.json';
  static const String authSuccessAssetPath = 'assets/mock_data/auth_success.json';
  static const String apiErrorAssetPath = 'assets/mock_data/api_error.json';
  static const String videoFeedAssetPath = 'assets/mock_data/video_feed.json';
  static const String locationsAssetPath = 'assets/mock_data/locations.json';

  final AssetBundle assetBundle;

  MockDataProvider({
    AssetBundle? assetBundle,
  }) : assetBundle = assetBundle ?? rootBundle;

  Future<Map<String, dynamic>> loadJson(String assetPath) async {
    final jsonString = await assetBundle.loadString(assetPath);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCategories() async {
    return loadJson(categoriesAssetPath);
  }

  Future<Map<String, dynamic>> getListingsFeed() async {
    return loadJson(listingsFeedAssetPath);
  }

  Future<Map<String, dynamic>> getListingDetail() async {
    return loadJson(listingDetailAssetPath);
  }

  Future<Map<String, dynamic>> getAuthSuccess() async {
    return loadJson(authSuccessAssetPath);
  }

  Future<Map<String, dynamic>> getApiError() async {
    return loadJson(apiErrorAssetPath);
  }

  Future<Map<String, dynamic>> getVideoFeed() async {
    return loadJson(videoFeedAssetPath);
  }

  Future<Map<String, dynamic>> getLocations() async {
    return loadJson(locationsAssetPath);
  }
}
