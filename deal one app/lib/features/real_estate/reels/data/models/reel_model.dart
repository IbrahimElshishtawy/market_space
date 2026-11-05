import 'package:market_space/features/real_estate/data/models/real_estate_detail_model.dart';
import 'package:market_space/features/real_estate/data/models/real_estate_listing_model.dart';

enum ReelType { photo, video }

class ReelModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final String priceFormatted;
  final String? pricePeriod;
  final RealEstateType propertyType;
  final ReelType type;
  final List<String> mediaUrls;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final AdvertiserModel advertiser;
  final int bedsCount;
  final int bathsCount;
  final int areaM2;
  final String finishType;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savesCount;
  final int viewsCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  const ReelModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.priceFormatted,
    this.pricePeriod,
    required this.propertyType,
    required this.type,
    required this.mediaUrls,
    this.videoUrl,
    this.thumbnailUrl,
    required this.caption,
    required this.advertiser,
    required this.bedsCount,
    required this.bathsCount,
    required this.areaM2,
    required this.finishType,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.savesCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    required this.createdAt,
  });

  ReelModel copyWith({
    String? id,
    String? propertyId,
    String? propertyTitle,
    String? propertyLocation,
    String? priceFormatted,
    String? pricePeriod,
    RealEstateType? propertyType,
    ReelType? type,
    List<String>? mediaUrls,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    AdvertiserModel? advertiser,
    int? bedsCount,
    int? bathsCount,
    int? areaM2,
    String? finishType,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? savesCount,
    int? viewsCount,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return ReelModel(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      propertyLocation: propertyLocation ?? this.propertyLocation,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      propertyType: propertyType ?? this.propertyType,
      type: type ?? this.type,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      advertiser: advertiser ?? this.advertiser,
      bedsCount: bedsCount ?? this.bedsCount,
      bathsCount: bathsCount ?? this.bathsCount,
      areaM2: areaM2 ?? this.areaM2,
      finishType: finishType ?? this.finishType,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      savesCount: savesCount ?? this.savesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
