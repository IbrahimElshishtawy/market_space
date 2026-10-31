import 'car_listing_model.dart';

enum CarSortBy {
  newest('الأحدث أولاً', 'Newest First'),
  priceLowToHigh('السعر: من الأقل للأعلى', 'Price: Low to High'),
  priceHighToLow('السعر: من الأعلى للأقل', 'Price: High to Low'),
  mileageLowest('المسافة: الأقل أولاً', 'Mileage: Lowest First'),
  yearNewest('سنة الصنع: الأحدث', 'Year: Newest First');

  final String titleAr;
  final String titleEn;
  const CarSortBy(this.titleAr, this.titleEn);
}

class CarFilterModel {
  final String? brand;
  final String? model;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final CarCondition? condition;
  final int? maxMileage;
  final CarTransmission? transmission;
  final CarFuelType? fuelType;
  final CarBodyType? bodyType;
  final String? governorate;
  final CarSortBy sortBy;
  final String? searchQuery;

  const CarFilterModel({
    this.brand,
    this.model,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.condition,
    this.maxMileage,
    this.transmission,
    this.fuelType,
    this.bodyType,
    this.governorate,
    this.sortBy = CarSortBy.newest,
    this.searchQuery,
  });

  CarFilterModel copyWith({
    String? brand,
    bool clearBrand = false,
    String? model,
    bool clearModel = false,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    CarCondition? condition,
    bool clearCondition = false,
    int? maxMileage,
    CarTransmission? transmission,
    bool clearTransmission = false,
    CarFuelType? fuelType,
    bool clearFuel = false,
    CarBodyType? bodyType,
    bool clearBodyType = false,
    String? governorate,
    bool clearGovernorate = false,
    CarSortBy? sortBy,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return CarFilterModel(
      brand: clearBrand ? null : (brand ?? this.brand),
      model: clearModel ? null : (model ?? this.model),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      condition: clearCondition ? null : (condition ?? this.condition),
      maxMileage: maxMileage ?? this.maxMileage,
      transmission: clearTransmission ? null : (transmission ?? this.transmission),
      fuelType: clearFuel ? null : (fuelType ?? this.fuelType),
      bodyType: clearBodyType ? null : (bodyType ?? this.bodyType),
      governorate: clearGovernorate ? null : (governorate ?? this.governorate),
      sortBy: sortBy ?? this.sortBy,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasActiveFilters =>
      brand != null ||
      model != null ||
      minPrice != null ||
      maxPrice != null ||
      minYear != null ||
      maxYear != null ||
      condition != null ||
      maxMileage != null ||
      transmission != null ||
      fuelType != null ||
      bodyType != null ||
      governorate != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}
