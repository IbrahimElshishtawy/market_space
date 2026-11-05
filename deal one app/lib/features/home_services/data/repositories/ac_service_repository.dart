import '../mock/mock_ac_service_data.dart';
import '../models/ac_part_item_model.dart';
import '../models/ac_promo_banner_model.dart';
import '../models/ac_service_item_model.dart';

abstract class AcServiceRepository {
  Future<AcPromoBannerModel> getPromoBanner();
  Future<List<String>> getFilterChips();
  Future<List<AcServiceItemModel>> getServices({String? category});
  Future<List<AcPartItemModel>> getParts();
}

class AcServiceRepositoryImpl implements AcServiceRepository {
  final Duration networkDelay;

  const AcServiceRepositoryImpl({
    this.networkDelay = const Duration(milliseconds: 300),
  });

  @override
  Future<AcPromoBannerModel> getPromoBanner() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockAcServiceData.promoBanner;
  }

  @override
  Future<List<String>> getFilterChips() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockAcServiceData.filterChips;
  }

  @override
  Future<List<AcServiceItemModel>> getServices({String? category}) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    final all = MockAcServiceData.services;
    if (category == null || category.isEmpty || category == 'الكل') {
      return all;
    }
    return all.where((s) => s.category == category).toList();
  }

  @override
  Future<List<AcPartItemModel>> getParts() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockAcServiceData.parts;
  }
}
