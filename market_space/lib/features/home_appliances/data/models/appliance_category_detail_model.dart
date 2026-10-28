class ApplianceCategoryDetailModel {
  final String id;
  final String title;
  final String subtitle;
  final List<String> filterChips;

  const ApplianceCategoryDetailModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.filterChips = const ['الكل', 'السعر ˅', 'الحجم ˅', 'الماركة ˅'],
  });
}
