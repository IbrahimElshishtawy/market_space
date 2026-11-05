class CarBrandModel {
  final String id;
  final String name;
  final String nameAr;
  final String logoUrl;
  final String originCountry;
  final int availableListingsCount;

  const CarBrandModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logoUrl,
    required this.originCountry,
    required this.availableListingsCount,
  });
}
