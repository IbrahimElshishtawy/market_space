import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_network_image.dart';

import '../../data/models/fashion_category_model.dart';
import '../../data/models/fashion_product_model.dart';
import '../../data/repositories/fashion_repository.dart';
import '../controllers/fashion_controller.dart';

class FashionCategoriesPage extends StatefulWidget {
  final FashionController controller;

  const FashionCategoriesPage({
    super.key,
    required this.controller,
  });

  @override
  State<FashionCategoriesPage> createState() => _FashionCategoriesPageState();
}

class _FashionCategoriesPageState extends State<FashionCategoriesPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FashionRepository _repository = MockFashionRepository();
  List<FashionCategoryModel> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final list = await _repository.getCategories();
    if (mounted) {
      setState(() {
        _allCategories = list;
        _isLoading = false;
      });
    }
  }

  List<FashionCategoryModel> _filterByTab(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return _allCategories.where((c) => c.department == FashionDepartment.men).toList();
      case 2:
        return _allCategories.where((c) => c.department == FashionDepartment.women).toList();
      case 3:
        return _allCategories.where((c) => c.department == FashionDepartment.kids).toList();
      default:
        return _allCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أقسام الأزياء والموضة', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'رجالي'),
            Tab(text: 'حريمي'),
            Tab(text: 'أطفال'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final currentList = _filterByTab(_tabController.index);

                return GridView.builder(
                  padding: const EdgeInsetsDirectional.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final cat = currentList[index];
                    return InkWell(
                      onTap: () {
                        widget.controller.setDepartment(cat.department);
                        widget.controller.setCategory(cat.nameAr);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(
                              imageUrl: cat.imageUrl,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.checkroom,
                            ),
                            // Gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                            // Details
                            PositionedDirectional(
                              bottom: 12,
                              start: 12,
                              end: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cat.nameAr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${cat.itemsCount} قطعة متوفرة',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
