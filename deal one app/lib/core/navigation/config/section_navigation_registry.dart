import '../../../features/building_materials/navigation/building_materials_navigation_config.dart';
import '../../../features/cars/navigation/cars_navigation_config.dart';
import '../../../features/fashion/navigation/fashion_navigation_config.dart';
import '../../../features/home_appliances/navigation/home_appliances_navigation_config.dart';
import '../../../features/home_services/navigation/home_services_navigation_config.dart';
import '../../../features/real_estate/navigation/real_estate_navigation_config.dart';
import 'section_navigation_config.dart';

class SectionNavigationRegistry {
  static final Map<String, SectionNavigationConfig> _registry = {
    RealEstateNavigationConfig.sectionId: RealEstateNavigationConfig.config,
    BuildingMaterialsNavigationConfig.sectionId:
        BuildingMaterialsNavigationConfig.config,
    HomeServicesNavigationConfig.sectionId: HomeServicesNavigationConfig.config,
    HomeAppliancesNavigationConfig.sectionId:
        HomeAppliancesNavigationConfig.config,
    CarsNavigationConfig.sectionId: CarsNavigationConfig.config,
    FashionNavigationConfig.sectionId: FashionNavigationConfig.config,
  };

  static SectionNavigationConfig getConfig(String sectionId) {
    return _registry[sectionId] ?? RealEstateNavigationConfig.config;
  }

  static List<SectionNavigationConfig> get allConfigs =>
      _registry.values.toList();
}
