/// Represents the major market sectors in Market Space.
enum MarketSector {
  all('all', 'الكل', 'All'),
  realEstate('real_estate', 'العقارات', 'Real Estate'),
  buildingMaterials('building_materials', 'مواد البناء', 'Building Materials'),
  services('services', 'الخدمات المنزلية', 'Home Services'),
  homeAppliances('home_appliances', 'الأجهزة المنزلية', 'Home Appliances'),
  cars('cars', 'السيارات', 'Cars'),
  fashion('fashion', 'الملابس والأزياء', 'Fashion & Clothing'),
  investments('investments', 'المشروعات والاستثمار', 'Investments');

  final String key;
  final String titleAr;
  final String titleEn;

  const MarketSector(this.key, this.titleAr, this.titleEn);

  String localizedTitle(bool isArabic) => isArabic ? titleAr : titleEn;

  static MarketSector fromKey(String? key) {
    return MarketSector.values.firstWhere(
      (sector) => sector.key == key,
      orElse: () => MarketSector.realEstate,
    );
  }
}

