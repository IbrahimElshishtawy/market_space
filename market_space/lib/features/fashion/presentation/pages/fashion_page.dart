import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/widgets/app_bottom_navigation/app_bottom_navigation.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../data/models/fashion_product_model.dart';
import '../../navigation/fashion_navigation_config.dart';
import '../controllers/fashion_cart_controller.dart';
import '../controllers/fashion_controller.dart';
import '../widgets/fashion_product_card.dart';
import 'fashion_categories_page.dart';
import 'fashion_product_detail_page.dart';

class FashionPage extends StatefulWidget {
  final FashionController? controller;
  final FashionCartController? cartController;

  const FashionPage({
    super.key,
    this.controller,
    this.cartController,
  });

  @override
  State<FashionPage> createState() => _FashionPageState();
}

class _FashionPageState extends State<FashionPage> {
  late final FashionController _controller;
  late final FashionCartController _cartController;
  late final TextEditingController _searchFieldController;
  int _tabIndex = 0;
  bool _isNavVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FashionController();
    _cartController = widget.cartController ?? FashionCartController();
    _searchFieldController = TextEditingController(text: _controller.value.searchQuery);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isNavVisible) setState(() => _isNavVisible = false);
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isNavVisible) setState(() => _isNavVisible = true);
    }
    return false;
  }

  void _onNavigationItemSelected(int index) {
    setState(() => _tabIndex = index);
    if (index >= 0 && index < FashionNavigationConfig.config.items.length) {
      final route = FashionNavigationConfig.config.items[index].destination;
      if (route == RouteNames.fashion) {
        // Current tab
      } else if (route == '/fashion/categories') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FashionCategoriesPage(controller: _controller)),
        );
      } else if (route == '/fashion/cart') {
        context.pushNamed(RouteNames.fashionCart);
      } else {
        context.push(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('الملابس والإكسسوارات', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'تصفح الأقسام',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FashionCategoriesPage(controller: _controller)),
              );
            },
          ),
          ValueListenableBuilder<FashionCartState>(
            valueListenable: _cartController,
            builder: (context, cartState, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    tooltip: 'حقيبة التسوق',
                    onPressed: () => context.pushNamed(RouteNames.fashionCart),
                  ),
                  if (cartState.totalItems > 0)
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${cartState.totalItems}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<FashionState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state.errorMessage != null && state.products.isEmpty) {
            return Center(
              child: AppErrorView(
                message: state.errorMessage!,
                onRetry: () => _controller.loadInitialData(),
              ),
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: _onUserScroll,
            child: RefreshIndicator(
              onRefresh: () => _controller.loadInitialData(),
              child: CustomScrollView(
                slivers: [
                  // Search & Filter header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchFieldController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (query) => _controller.setSearchQuery(query),
                              decoration: InputDecoration(
                                hintText: 'ابحث عن قمصان، فساتين، أحذية، ماركات...',
                                hintStyle: const TextStyle(fontSize: 13),
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: _searchFieldController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchFieldController.clear();
                                          _controller.setSearchQuery('');
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            tooltip: 'ترتيب حسب',
                            icon: Container(
                              padding: const EdgeInsetsDirectional.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.sort_rounded, color: theme.colorScheme.primary),
                            ),
                            onSelected: (sort) => _controller.setSortBy(sort),
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'newest', child: Text('الأحدث وصولاً')),
                              const PopupMenuItem(value: 'price_asc', child: Text('السعر: من الأقل للأعلى')),
                              const PopupMenuItem(value: 'price_desc', child: Text('السعر: من الأعلى للأقل')),
                              const PopupMenuItem(value: 'rating', child: Text('الأعلى تقييماً')),
                              const PopupMenuItem(value: 'discount', child: Text('أكبر نسبة خصم')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Department Filter Pills (All, Men, Women, Kids)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                        children: [
                          _buildDeptChip(null, 'الكل', state.selectedDepartment == null),
                          const SizedBox(width: 8),
                          _buildDeptChip(FashionDepartment.men, 'رجال', state.selectedDepartment == FashionDepartment.men),
                          const SizedBox(width: 8),
                          _buildDeptChip(FashionDepartment.women, 'نساء', state.selectedDepartment == FashionDepartment.women),
                          const SizedBox(width: 8),
                          _buildDeptChip(FashionDepartment.kids, 'أطفال', state.selectedDepartment == FashionDepartment.kids),
                        ],
                      ),
                    ),
                  ),

                  // Promotional Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 8),
                      child: Container(
                        padding: const EdgeInsetsDirectional.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade700,
                              Colors.pink.shade600,
                            ],
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'عروض الموسم الجديد',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'خصم يصل إلى 40% على أرقى الأزياء',
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'استخدم كود FASHION20 لخصم إضافي %20 عند الدفع',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.local_mall_outlined, size: 48, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Best Sellers Section Header
                  if (state.bestSellers.isNotEmpty && state.searchQuery.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'الأكثر مبيعاً هذا الأسبوع',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.local_fire_department_rounded, color: Colors.orange.shade700, size: 20),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                          itemCount: state.bestSellers.length,
                          separatorBuilder: (context, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = state.bestSellers[index];
                            return SizedBox(
                              width: 170,
                              child: FashionProductCard(
                                product: item,
                                onTap: () => _openDetail(item),
                                onFavoriteToggle: () => _controller.toggleFavorite(item.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Product Catalog Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.selectedDepartment == null
                                ? 'كل المعروضات (${state.products.length})'
                                : '${state.selectedDepartment!.titleAr} (${state.products.length})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (state.selectedCategory != null)
                            Chip(
                              label: Text(state.selectedCategory!),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () => _controller.setCategory(null),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Product Grid
                  if (state.products.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyState(
                        title: 'لم يتم العثور على أزياء تطابق بحثك',
                        message: 'جرب البحث بكلمات أخرى أو تغيير الفلتر',
                        icon: Icons.checkroom_outlined,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = state.products[index];
                            return FashionProductCard(
                              product: item,
                              onTap: () => _openDetail(item),
                              onFavoriteToggle: () => _controller.toggleFavorite(item.id),
                            );
                          },
                          childCount: state.products.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _isNavVisible ? Offset.zero : const Offset(0, 1),
        child: AppBottomNavigation(
          config: FashionNavigationConfig.config,
          currentIndex: _tabIndex,
          onTabSelected: _onNavigationItemSelected,
        ),
      ),
    );
  }

  Widget _buildDeptChip(FashionDepartment? dept, String label, bool isSelected) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: theme.colorScheme.primaryContainer,
      onSelected: (_) => _controller.setDepartment(dept),
    );
  }

  void _openDetail(FashionProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FashionProductDetailPage(
          product: product,
          repository: _controller.repository,
          cartController: _cartController,
        ),
      ),
    );
  }
}
