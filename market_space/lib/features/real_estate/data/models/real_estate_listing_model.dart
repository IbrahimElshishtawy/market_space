enum RealEstateType {
  all('الكل', 'all'),
  forSale('شقق للبيع', 'for_sale'),
  forRent('شقق للإيجار', 'for_rent');

  final String label;
  final String code;

  const RealEstateType(this.label, this.code);
}

class RealEstateListingModel {
  final String id;
  final String title;
  final String location;
  final String priceFormatted;
  final String? pricePeriod;
  final RealEstateType type;
  final int totalPhotos;
  final int currentPhotoIndex;
  final bool isFavorite;
  final int bedsCount;
  final String finishType;
  final String floorLevel;
  final int areaM2;
  final int bathsCount;
  final String imageUrl;

  const RealEstateListingModel({
    required this.id,
    required this.title,
    required this.location,
    required this.priceFormatted,
    this.pricePeriod,
    required this.type,
    required this.totalPhotos,
    this.currentPhotoIndex = 1,
    this.isFavorite = false,
    required this.bedsCount,
    required this.finishType,
    required this.floorLevel,
    required this.areaM2,
    required this.bathsCount,
    required this.imageUrl,
  });

  RealEstateListingModel copyWith({
    String? id,
    String? title,
    String? location,
    String? priceFormatted,
    String? pricePeriod,
    RealEstateType? type,
    int? totalPhotos,
    int? currentPhotoIndex,
    bool? isFavorite,
    int? bedsCount,
    String? finishType,
    String? floorLevel,
    int? areaM2,
    int? bathsCount,
    String? imageUrl,
  }) {
    return RealEstateListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      type: type ?? this.type,
      totalPhotos: totalPhotos ?? this.totalPhotos,
      currentPhotoIndex: currentPhotoIndex ?? this.currentPhotoIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      bedsCount: bedsCount ?? this.bedsCount,
      finishType: finishType ?? this.finishType,
      floorLevel: floorLevel ?? this.floorLevel,
      areaM2: areaM2 ?? this.areaM2,
      bathsCount: bathsCount ?? this.bathsCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
