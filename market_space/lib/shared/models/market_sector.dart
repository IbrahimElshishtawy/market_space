/// Represents the major market sectors in Bazar Jo.
enum MarketSector {
  all('all', 'الكل'),
  realEstate('real_estate', 'العقارات'),
  buildingMaterials('building_materials', 'مواد البناء والمُوَن'),
  services('services', 'الخدمات والمقاولات'),
  investments('investments', 'المشروعات والاستثمار');

  final String key;
  final String titleAr;

  const MarketSector(this.key, this.titleAr);

  static MarketSector fromKey(String? key) {
    return MarketSector.values.firstWhere(
      (sector) => sector.key == key,
      orElse: () => MarketSector.realEstate,
    );
  }
}
