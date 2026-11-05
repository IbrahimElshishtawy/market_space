import 'floating_action_config.dart';
import 'navigation_item_config.dart';

class SectionNavigationConfig {
  final String sectionId;
  final String sectionName;
  final List<NavigationItemConfig> items;
  final FloatingActionConfig? floatingAction;

  const SectionNavigationConfig({
    required this.sectionId,
    required this.sectionName,
    required this.items,
    this.floatingAction,
  });
}
