import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../mock/mock_real_estate_data.dart';
import '../models/real_estate_detail_model.dart';
import '../models/real_estate_filter_model.dart';
import '../models/real_estate_listing_model.dart';

abstract class RealEstateRepository {
  Future<List<RealEstateListingModel>> getListings({
    RealEstateFilterModel? filter,
  });
  Future<RealEstateDetailModel> getListingDetails(String listingId);
  Future<bool> toggleFavorite(String listingId);
}

class ApiRealEstateRepository implements RealEstateRepository {
  final ApiClient apiClient;
  final MockRealEstateRepository _fallback = MockRealEstateRepository();

  ApiRealEstateRepository({required this.apiClient});

  @override
  Future<List<RealEstateListingModel>> getListings({
    RealEstateFilterModel? filter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'categorySlug': 'real-estate',
        'limit': 50,
      };

      if (filter != null) {
        if (filter.selectedType == RealEstateType.forSale) {
          queryParams['categorySlug'] = 'apartments-for-sale';
        } else if (filter.selectedType == RealEstateType.forRent) {
          queryParams['categorySlug'] = 'apartments-for-rent';
        }

        if (filter.searchQuery.trim().isNotEmpty) {
          queryParams['q'] = filter.searchQuery.trim();
        }
      }

      final response = await apiClient.get(
        '/listings',
        queryParameters: queryParams,
      );

      final dynamic resData = response.data;
      List<dynamic> items = [];
      if (resData is Map && resData['data'] is List) {
        items = resData['data'] as List;
      } else if (resData is List) {
        items = resData;
      }

      if (items.isEmpty) {
        return await _fallback.getListings(filter: filter);
      }

      final formatter = NumberFormat.decimalPattern();
      return items.map<RealEstateListingModel>((item) {
        final Map<String, dynamic> data =
            item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);

        final num priceNum = data['price'] is num
            ? data['price']
            : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);
        final priceFormatted = '${formatter.format(priceNum)} ج.م';
        final isRent = data['listingKind'] == 'rent';
        final attrs = data['attributes'] is Map
            ? Map<String, dynamic>.from(data['attributes'])
            : <String, dynamic>{};

        final rooms = attrs['rooms'] is int
            ? attrs['rooms'] as int
            : (int.tryParse(attrs['rooms']?.toString() ?? '3') ?? 3);
        final baths = attrs['baths'] is int
            ? attrs['baths'] as int
            : (int.tryParse(attrs['baths']?.toString() ?? '2') ?? 2);
        final area = attrs['area_sqm'] is int
            ? attrs['area_sqm'] as int
            : (int.tryParse(attrs['area_sqm']?.toString() ?? '150') ?? 150);
        final floor = attrs['floor'] != null
            ? 'الدور ${attrs['floor']}'
            : 'الدور الثاني';
        final finishing = attrs['finishing']?.toString() ?? 'سوبر لوكس';

        final mediaList = data['media'] as List?;
        final imageUrl = data['primaryImageUrl']?.toString() ??
            data['imageUrl']?.toString() ??
            (mediaList != null && mediaList.isNotEmpty
                ? mediaList[0]['publicUrl']?.toString()
                : null) ??
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=800&q=80';

        return RealEstateListingModel(
          id: data['id']?.toString() ?? '',
          title: data['title']?.toString() ?? 'عقار مميز',
          location: data['location']?.toString() ??
              data['areaName']?.toString() ??
              'القاهرة الجديدة',
          priceFormatted: priceFormatted,
          pricePeriod: isRent ? 'شهرياً' : null,
          type: isRent ? RealEstateType.forRent : RealEstateType.forSale,
          totalPhotos: mediaList?.length ?? 1,
          isFavorite: false,
          bedsCount: rooms,
          bathsCount: baths,
          areaM2: area,
          finishType: finishing,
          floorLevel: floor,
          imageUrl: imageUrl,
        );
      }).toList();
    } catch (_) {
      return _fallback.getListings(filter: filter);
    }
  }

  @override
  Future<RealEstateDetailModel> getListingDetails(String listingId) async {
    try {
      final response = await apiClient.get('/listings/$listingId');
      final dynamic resData = response.data;
      final Map<String, dynamic> data = (resData is Map && resData['data'] is Map)
          ? Map<String, dynamic>.from(resData['data'])
          : (resData is Map ? Map<String, dynamic>.from(resData) : {});

      if (data.isEmpty) {
        return await _fallback.getListingDetails(listingId);
      }

      final formatter = NumberFormat.decimalPattern();
      final num priceNum = data['price'] is num
          ? data['price']
          : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);
      final priceFormatted = '${formatter.format(priceNum)} ج.م';
      final isRent = data['listingKind'] == 'rent';

      final attrs = data['attributes'] is Map
          ? Map<String, dynamic>.from(data['attributes'])
          : <String, dynamic>{};

      final rooms = attrs['rooms']?.toString() ?? '3';
      final baths = attrs['baths']?.toString() ?? '2';
      final area = attrs['area_sqm']?.toString() ?? '150';
      final floor = attrs['floor'] != null ? 'الدور ${attrs['floor']}' : 'الدور الثاني';
      final finishing = attrs['finishing']?.toString() ?? 'سوبر لوكس';

      final mediaList = data['media'] as List?;
      final images = mediaList != null && mediaList.isNotEmpty
          ? mediaList.map((m) => m['publicUrl']?.toString() ?? '').where((u) => u.isNotEmpty).toList()
          : <String>[
              'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=800&q=80',
            ];

      final account = data['account'] is Map ? data['account'] as Map : {};
      final owner = account['owner'] is Map ? account['owner'] as Map : {};

      final advertiser = AdvertiserModel(
        id: account['id']?.toString() ?? 'demo-seller',
        name: account['displayName']?.toString() ?? data['sellerName']?.toString() ?? 'شركة الأهرام للتطوير العقاري',
        role: 'وسيط عقاري معتمد',
        avatarUrl: account['logoUrl']?.toString() ?? 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=400&q=80',
        phone: owner['phone']?.toString() ?? data['sellerPhone']?.toString() ?? '+201001122331',
        whatsapp: owner['phone']?.toString() ?? data['sellerPhone']?.toString() ?? '+201001122331',
      );

      final specs = [
        PropertySpecItem(label: '$rooms غرف', iconType: PropertySpecIconType.bed),
        PropertySpecItem(label: '$baths حمام', iconType: PropertySpecIconType.bath),
        PropertySpecItem(label: '$area م²', iconType: PropertySpecIconType.area),
        PropertySpecItem(label: finishing, iconType: PropertySpecIconType.finish),
        PropertySpecItem(label: floor, iconType: PropertySpecIconType.floor),
      ];

      return RealEstateDetailModel(
        id: data['id']?.toString() ?? listingId,
        title: data['title']?.toString() ?? 'شقة فاخرة للبيع',
        location: data['location']?.toString() ?? data['areaName']?.toString() ?? 'القاهرة الجديدة',
        priceFormatted: priceFormatted,
        pricePeriod: isRent ? 'شهرياً' : null,
        type: isRent ? RealEstateType.forRent : RealEstateType.forSale,
        images: images,
        specs: specs,
        aboutProperty: data['description']?.toString() ?? 'وحدة عقارية راقية متكاملة المرافق.',
        spaceDetails: '$area م² إجمالي المساحة الصافية مقسمة لـ $rooms غرف و $baths حمام وريسبشن واسع.',
        bathAndKitchenDetails: 'أطقم صحية مستوردة وخلاطات فاخرة، مطبخ واسع مجهز بوصلات الغاز والصرف.',
        featuresList: const [
          'غاز طبيعي',
          'عداد كهرباء رسمي',
          'حصة بالأرض وجراج خاص',
          'مصعد إيطالي حديث',
          'أمن وحراسة 24 ساعة',
        ],
        advertiser: advertiser,
      );
    } catch (_) {
      return _fallback.getListingDetails(listingId);
    }
  }

  @override
  Future<bool> toggleFavorite(String listingId) async {
    try {
      final res = await apiClient.post('/favorites/$listingId');
      final data = res.data;
      if (data is Map && data['data'] != null && data['data']['favorited'] != null) {
        return data['data']['favorited'] as bool;
      }
      return true;
    } catch (_) {
      return _fallback.toggleFavorite(listingId);
    }
  }
}

class MockRealEstateRepository implements RealEstateRepository {
  final List<RealEstateListingModel> _cache = List.from(
    MockRealEstateData.listings,
  );

  @override
  Future<List<RealEstateListingModel>> getListings({
    RealEstateFilterModel? filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var results = List<RealEstateListingModel>.from(_cache);

    if (filter != null) {
      if (filter.selectedType == RealEstateType.forSale) {
        results = results
            .where((item) => item.type == RealEstateType.forSale)
            .toList();
      } else if (filter.selectedType == RealEstateType.forRent) {
        results = results
            .where((item) => item.type == RealEstateType.forRent)
            .toList();
      }

      if (filter.searchQuery.trim().isNotEmpty) {
        final query = filter.searchQuery.trim().toLowerCase();
        results = results.where((item) {
          return item.title.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query);
        }).toList();
      }

      if (filter.selectedRoomCounts.isNotEmpty) {
        results = results.where((item) {
          final countStr = item.bedsCount.toString();
          return filter.selectedRoomCounts.contains(countStr) ||
              (filter.selectedRoomCounts.contains('+5') && item.bedsCount >= 5);
        }).toList();
      }

      if (filter.selectedFinishTypes.isNotEmpty) {
        results = results.where((item) {
          return filter.selectedFinishTypes.contains(item.finishType);
        }).toList();
      }
    }

    return results;
  }

  @override
  Future<RealEstateDetailModel> getListingDetails(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final detail = MockRealEstateData.getDetailById(listingId);
    final cachedItem = _cache.firstWhere(
      (element) => element.id == listingId,
      orElse: () => _cache.first,
    );
    return detail.copyWith(isFavorite: cachedItem.isFavorite);
  }

  @override
  Future<bool> toggleFavorite(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _cache.indexWhere((element) => element.id == listingId);
    if (index != -1) {
      final current = _cache[index];
      _cache[index] = current.copyWith(isFavorite: !current.isFavorite);
      return _cache[index].isFavorite;
    }
    return false;
  }
}
