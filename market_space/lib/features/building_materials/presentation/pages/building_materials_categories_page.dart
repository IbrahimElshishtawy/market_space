import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../data/models/building_material_category_model.dart';
import '../../data/repositories/building_materials_repository.dart';
import '../../navigation/building_materials_navigation_config.dart';

class BuildingMaterialsCategoriesPage extends StatefulWidget {
  final BuildingMaterialsRepository? repository;

  const BuildingMaterialsCategoriesPage({super.key, this.repository});

  @override
  State<BuildingMaterialsCategoriesPage> createState() =>
      _BuildingMaterialsCategoriesPageState();
}

class _BuildingMaterialsCategoriesPageState
    extends State<BuildingMaterialsCategoriesPage> {
  late final BuildingMaterialsRepository _repository;
  bool _isLoading = true;
  String? _errorMessage;
  List<BuildingMaterialCategoryModel> _categories = [];
  String _searchQuery = '';
  int _selectedTabIndex = 1; // الأقسام

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const BuildingMaterialsRepositoryImpl();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _repository.getAllTenCategories();
      setState(() {
        _categories = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BuildingMaterialCategoryModel> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return _categories;
    final q = _searchQuery.trim().toLowerCase();
    return _categories.where((c) {
      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.subcategories.any((sub) => sub.name.toLowerCase().contains(q));
    }).toList();
  }

  void _onBottomNavSelected(int index) {
    if (index == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = index);

    final config = BuildingMaterialsNavigationConfig.config;
    final item = config.items[index];
    context.go(item.destination);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: const Text(
            'تصنيفات مواد البناء',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.slate900,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.buildingMaterials);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'السلة',
              onPressed: () => context.push(RouteNames.buildingMaterialsCart),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigation(
          config: BuildingMaterialsNavigationConfig.config,
          currentIndex: _selectedTabIndex,
          onTabSelected: _onBottomNavSelected,
        ),
        body: _isLoading
            ? const Center(child: AppLoadingIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _fetchCategories,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchCategories,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // شريط البحث
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: AppRadii.md,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.slate200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.slate900,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن أسمنت، حديد، سيراميك، دهانات...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.slate500,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? AppColors.darkTextMuted : AppColors.slate600,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 18,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.slate600,
                                  ),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'التصنيفات المعتمدة (${_filteredCategories.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (_filteredCategories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: AppEmptyState(
                          title: 'لا توجد تصنيفات مطابقة',
                          message: 'جرب البحث باسم مادة أخرى أو تفقد باقي الأقسام.',
                        ),
                      )
                    else
                      ..._filteredCategories.map((cat) {
                        return _buildCategoryCard(context, cat, isDark);
                      }),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    BuildingMaterialCategoryModel category,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.slate200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: category.iconColor.withValues(alpha: 0.15),
              borderRadius: AppRadii.md,
            ),
            child: Icon(category.icon, color: category.iconColor, size: 26),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.slate900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceSecondary : AppColors.slate100,
                  borderRadius: AppRadii.full,
                ),
                child: Text(
                  '${category.productsCount} منتج',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.slate700,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              category.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.slate600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          children: [
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.slate200,
              height: 1,
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الأنواع والتصنيفات الفرعية:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.slate700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: category.subcategories.map((sub) {
                return ActionChip(
                  label: Text('${sub.name} (${sub.productsCount})'),
                  backgroundColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.slate50,
                  side: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.slate300,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.slate800,
                  ),
                  onPressed: () {
                    context.push(
                      '${RouteNames.buildingMaterialCategoryDetail}?categoryId=${category.id}',
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.emerald400 : AppColors.emerald700,
                  side: BorderSide(
                    color: isDark ? AppColors.emerald500 : AppColors.emerald600,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.md,
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('تصفح كافة منتجات ${category.title}'),
                onPressed: () {
                  context.push(
                    '${RouteNames.buildingMaterialCategoryDetail}?categoryId=${category.id}',
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
  }
}
