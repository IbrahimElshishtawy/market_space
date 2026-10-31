enum CarCondition {
  newCar('جديدة', 'New'),
  used('مستعملة', 'Used');

  final String titleAr;
  final String titleEn;
  const CarCondition(this.titleAr, this.titleEn);
}

enum CarTransmission {
  automatic('أوتوماتيك', 'Automatic'),
  manual('مانيوال', 'Manual');

  final String titleAr;
  final String titleEn;
  const CarTransmission(this.titleAr, this.titleEn);
}

enum CarFuelType {
  petrol('بنزين', 'Petrol'),
  diesel('ديزل', 'Diesel'),
  electric('كهرباء', 'Electric'),
  hybrid('هايبرد', 'Hybrid');

  final String titleAr;
  final String titleEn;
  const CarFuelType(this.titleAr, this.titleEn);
}

enum CarBodyType {
  suv('SUV / دفع رباعي', 'SUV'),
  sedan('سيدان', 'Sedan'),
  sports('رياضية / كوبيه', 'Sports'),
  electric('كهربائية بالكامل', 'Electric'),
  family('عائلية / 7 راكب', 'Family 7-Seater'),
  economy('اقتصادية / هاتشباك', 'Economy Hatchback'),
  commercial('نقل وتجارية', 'Commercial');

  final String titleAr;
  final String titleEn;
  const CarBodyType(this.titleAr, this.titleEn);
}

class CarListingModel {
  final String id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String formattedPrice;
  final CarCondition condition;
  final int mileageKm;
  final CarTransmission transmission;
  final CarFuelType fuelType;
  final CarBodyType bodyType;
  final String color;
  final String governorate;
  final String city;
  final String description;
  final String sellerName;
  final String sellerPhone;
  final String sellerType; // تاجر معتمد، مالك أول، معرض
  final double sellerRating;
  final List<String> images;
  final int engineCapacityCc;
  final bool isFeatured;
  final bool isFavorite;
  final DateTime createdAt;
  final String listingStatus;

  const CarListingModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.formattedPrice,
    required this.condition,
    required this.mileageKm,
    required this.transmission,
    required this.fuelType,
    required this.bodyType,
    required this.color,
    required this.governorate,
    required this.city,
    required this.description,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerType,
    required this.sellerRating,
    required this.images,
    required this.engineCapacityCc,
    this.isFeatured = false,
    this.isFavorite = false,
    required this.createdAt,
    this.listingStatus = 'متاح للبيع',
  });

  CarListingModel copyWith({
    bool? isFavorite,
    String? listingStatus,
  }) {
    return CarListingModel(
      id: id,
      brand: brand,
      model: model,
      year: year,
      price: price,
      formattedPrice: formattedPrice,
      condition: condition,
      mileageKm: mileageKm,
      transmission: transmission,
      fuelType: fuelType,
      bodyType: bodyType,
      color: color,
      governorate: governorate,
      city: city,
      description: description,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      sellerType: sellerType,
      sellerRating: sellerRating,
      images: images,
      engineCapacityCc: engineCapacityCc,
      isFeatured: isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      listingStatus: listingStatus ?? this.listingStatus,
    );
  }

  String get fullTitle => '$brand $model $year';
}
