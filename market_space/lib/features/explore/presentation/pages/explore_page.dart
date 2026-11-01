import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/explore_search_models.dart';
import '../controllers/explore_controller.dart';

class ExplorePage extends StatefulWidget {
  final ExploreController? controller;

  const ExplorePage({super.key, this.controller});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final ExploreController _controller;
  late final TextEditingController _searchFieldController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ExploreController();
    _searchFieldController = TextEditingController(text: _controller.value.searchQuery);
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    _searchFocusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _navigateToRoute(String route) {
    if (GoRouter.maybeOf(context) != null) {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<ExploreState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.isLoading && state.searchResults.isEmpty && state.categories.isEmpty) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state.errorMessage != null && state.searchResults.isEmpty) {
                return AppErrorView(
                  title: 'تعذر تحميل البيانات',
                  message: state.errorMessage!,
                  onRetry: () => _controller.loadInitialData(),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _controller.loadInitialData(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Header & Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'استكشف المنصة',
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              'ابحث عبر جميع العقارات، مواد البناء، الخدمات والأجهزة',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildSearchBar(state),
                          ],
                        ),
                      ),
                    ),

                    // 2. Sector Filter Chips
                    SliverToBoxAdapter(
                      child: _buildSectorFilterBar(state),
                    ),

                    // 3. Search Results or Main Discovery Sections
                    if (state.isSearching) ...[
                      _buildSearchResultsList(state),
                    ] else ...[
                      // Recent & Popular Searches
                      if (state.recentSearches.isNotEmpty || state.popularSearches.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildSearchesSection(state),
                        ),

                      // Main Categories & Subcategories
                      SliverToBoxAdapter(
                        child: _buildMainCategoriesSection(state),
                      ),

                      // Most Requested Section
                      SliverToBoxAdapter(
                        child: _buildDiscoverySection(
                          title: 'الأكثر طلباً في المنصة',
                          subtitle: 'عناصر وخدمات مميزة يطلبها المستخدمون بكثرة',
                          items: state.mostRequested,
                        ),
                      ),

                      // Current Offers Section
                      SliverToBoxAdapter(
                        child: _buildDiscoverySection(
                          title: 'أقوى العروض والخصومات',
                          subtitle: 'عروض حصرية لفترة محدودة على المنتجات والخدمات',
                          items: state.currentOffers,
                        ),
                      ),

                      // Latest Additions Section
                      SliverToBoxAdapter(
                        child: _buildDiscoverySection(
                          title: 'أحدث الإضافات اليوم',
                          subtitle: 'قوائم ومنتجات مضافة حديثاً في مختلف الأقسام',
                          items: state.latestAdditions,
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
                  ],
                ),
              );
            },
          ),
        ),
    );
  }

  Widget _buildSearchBar(ExploreState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchFieldController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        onChanged: (text) => _controller.onSearchQueryChanged(text),
        onSubmitted: (text) => _controller.submitSearch(text),
        style: TextStyle(
          fontSize: 13.5,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن عقار، حديد تسليح، تكييف، فني سباكة...',
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.iconPrimary,
            size: 22.0,
          ),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 20.0,
                    color: isDark ? AppColors.darkTextSecondary : null,
                  ),
                  onPressed: () {
                    _searchFieldController.clear();
                    _controller.clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 4.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSectorFilterBar(ExploreState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: SectorType.values.map((sector) {
          final isSelected = state.selectedSector == sector;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sector.icon,
                    size: 16.0,
                    color: isSelected ? Colors.white : AppColors.neutral,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    sector.titleAr,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.neutral,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surfaceSecondary,
              selectedColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.full,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              onSelected: (_) => _controller.setSectorFilter(sector),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchesSection(ExploreState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, size: 16.0, color: AppColors.lightTextSecondary),
                    SizedBox(width: 4.0),
                    Text(
                      'عمليات البحث الأخيرة',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _controller.clearAllRecentSearches(),
                  child: const Text('مسح الكل', style: TextStyle(fontSize: 12.0)),
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: state.recentSearches.map((item) {
                return InputChip(
                  label: Text(item, style: const TextStyle(fontSize: 12.0)),
                  onPressed: () {
                    _searchFieldController.text = item;
                    _controller.submitSearch(item);
                  },
                  onDeleted: () => _controller.removeRecentSearch(item),
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.full,
                    side: BorderSide(color: Color(0x1A000000)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (state.popularSearches.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 16.0, color: AppColors.primary),
                SizedBox(width: 4.0),
                Text(
                  'الأكثر بحثاً في منطقتك',
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: state.popularSearches.map((item) {
                return ActionChip(
                  label: Text(item, style: const TextStyle(fontSize: 12.0)),
                  avatar: const Icon(Icons.search_rounded, size: 14.0, color: AppColors.primary),
                  onPressed: () {
                    _searchFieldController.text = item;
                    _controller.submitSearch(item);
                  },
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.full,
                    side: BorderSide(color: Color(0x1A000000)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainCategoriesSection(ExploreState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التصنيفات الرئيسية والأقسام',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...state.categories.map((cat) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0x12000000)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: cat.themeColor.withValues(alpha: 0.12),
                              borderRadius: AppRadii.md,
                            ),
                            child: Icon(cat.icon, color: cat.themeColor, size: 22.0),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            cat.sectorTitle,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _navigateToRoute(cat.targetRoute),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 12.0),
                        label: const Text('دخول القسم', style: TextStyle(fontSize: 12.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 6.0,
                    children: cat.subcategories.map((sub) {
                      return InkWell(
                        onTap: () => _navigateToRoute(sub.targetRoute),
                        borderRadius: AppRadii.full,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF1F5F9),
                            borderRadius: AppRadii.full,
                            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0x0F000000)),
                          ),
                          child: Text(
                            sub.title,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDiscoverySection({
    required String title,
    required String subtitle,
    required List<DiscoveryCardItem> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 240.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return Container(
                  width: 220.0,
                  margin: const EdgeInsets.only(left: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: AppRadii.lg,
                    border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0x14000000)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 10.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _navigateToRoute(item.targetRoute),
                    borderRadius: AppRadii.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16.0),
                              ),
                              child: SafeNetworkImage(
                                imageUrl: item.imageUrl,
                                height: 120.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8.0,
                              right: 8.0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: AppRadii.sm,
                                ),
                                child: Text(
                                  item.badgeText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      item.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (item.price != null)
                                      Text(
                                        '${item.price!.toStringAsFixed(0)} ج.م',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    else
                                      const Text(
                                        'حسب الطلب',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    if (item.rating != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 14.0,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 2.0),
                                          Text(
                                            item.rating!.toString(),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList(ExploreState state) {
    if (state.searchResults.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppEmptyState(
            title: 'لا توجد نتائج مطابقة',
            message: 'لم نعثر على نتائج مطابقة لبحثك عن "${state.searchQuery}". جرب كلمات أخرى أو غير فلتر القسم.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = state.searchResults[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: AppRadii.lg,
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0x14000000)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _navigateToRoute(item.targetRoute),
                borderRadius: AppRadii.lg,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadii.md,
                        child: SafeNetworkImage(
                          imageUrl: item.imageUrl,
                          width: 80.0,
                          height: 80.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: AppRadii.xs,
                                  ),
                                  child: Text(
                                    item.resultType,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  item.sectorName,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              item.formattedPrice,
                              style: const TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.0,
                        color: AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: state.searchResults.length,
        ),
      ),
    );
  }
}
